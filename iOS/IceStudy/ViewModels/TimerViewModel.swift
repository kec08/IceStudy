import SwiftUI
import Combine
import WidgetKit

enum TimerState: Sendable, Equatable {
    case idle
    case running
    case paused
    case completed
    case aborted
}

@Observable
class TimerViewModel {
    var cupSize: CupSize = .tall
    var timerState: TimerState = .idle
    var elapsedSeconds: Int = 0
    var isFocusMode: Bool = false

    // 온도
    var currentTemperature: Int? = nil
    var temperatureZone: TemperatureZone? = nil
    var isFetchingTemperature: Bool = false

    // 백색소음
    var isNoiseOn: Bool = false
    var noiseType: NoiseType = .waterDrop
    var noiseVolume: Float = 0.3

    private(set) var totalDuration: Int = 0
    private var timer: AnyCancellable?
    private var backgroundDate: Date?
    private(set) var currentSessionId: Int?

    // MARK: - 세션 영속화 (백그라운드 킬 대응)
    private static let defaults = UserDefaults.standard
    private static let kIsRunning = "timer_isRunning"
    private static let kStartDate = "timer_startDate"
    private static let kTotalDuration = "timer_totalDuration"
    private static let kCupSize = "timer_cupSize"
    private static let kSessionId = "timer_sessionId"

    private func saveSession() {
        Self.defaults.set(true, forKey: Self.kIsRunning)
        Self.defaults.set(Date(), forKey: Self.kStartDate)
        Self.defaults.set(totalDuration, forKey: Self.kTotalDuration)
        Self.defaults.set(cupSize.rawValue, forKey: Self.kCupSize)
        if let id = currentSessionId {
            Self.defaults.set(id, forKey: Self.kSessionId)
        }
    }

    private func clearSession() {
        Self.defaults.removeObject(forKey: Self.kIsRunning)
        Self.defaults.removeObject(forKey: Self.kStartDate)
        Self.defaults.removeObject(forKey: Self.kTotalDuration)
        Self.defaults.removeObject(forKey: Self.kCupSize)
        Self.defaults.removeObject(forKey: Self.kSessionId)
    }

    func restoreSessionIfNeeded() {
        guard Self.defaults.bool(forKey: Self.kIsRunning),
              let startDate = Self.defaults.object(forKey: Self.kStartDate) as? Date,
              let cupRaw = Self.defaults.string(forKey: Self.kCupSize),
              let cup = CupSize(rawValue: cupRaw) else { return }

        let savedDuration = Self.defaults.integer(forKey: Self.kTotalDuration)
        let savedSessionId = Self.defaults.integer(forKey: Self.kSessionId)
        let elapsed = Int(Date().timeIntervalSince(startDate))

        cupSize = cup
        totalDuration = savedDuration
        currentSessionId = savedSessionId > 0 ? savedSessionId : nil

        if elapsed >= savedDuration {
            // 이미 완료됨
            elapsedSeconds = savedDuration
            timerState = .completed
            setFocusMode(false)
            sendComplete()
            clearSession()
        } else {
            // 아직 진행 중
            elapsedSeconds = elapsed
            timerState = .running
            setupTimer()
            observeBackground()
        }
    }

    // MARK: - Computed
    var progress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return min(CGFloat(elapsedSeconds) / CGFloat(totalDuration), 1.0)
    }

    var waterProgress: CGFloat {
        let maxSeconds = CGFloat(cupSize.durationRange.upperBound)
        guard maxSeconds > 0 else { return 0 }
        return min(CGFloat(elapsedSeconds) / maxSeconds, 1.0)
    }

    var waterML: Double {
        Double(waterProgress) * cupSize.maxML
    }

    var elapsedHours: Int {
        elapsedSeconds / 3600
    }

    var elapsedMinutes: Int {
        (elapsedSeconds % 3600) / 60
    }

    // MARK: - 온도
    func fetchTemperature() async {
        guard !isFetchingTemperature else { return }
        await MainActor.run { isFetchingTemperature = true }
        do {
            let location = try await LocationService.shared.requestOnce()
            let celsius = try await IceWeatherService.shared.fetchTemperature(at: location)
            await MainActor.run {
                self.currentTemperature = celsius
                self.temperatureZone = TemperatureZone(celsius: celsius)
                self.isFetchingTemperature = false
            }
        } catch {
            print("온도 가져오기 실패: \(error)")
            await MainActor.run { self.isFetchingTemperature = false }
        }
    }

    // MARK: - Actions
    func startTimer(size: CupSize) {
        cupSize = size
        let raw = size.randomDuration()
        let multiplier = temperatureZone?.multiplier ?? 1.0
        totalDuration = Int(Double(raw) * multiplier)
        elapsedSeconds = 0
        timerState = .running
        setupTimer()
        observeBackground()
        saveSession()

        // 타이머 완료 알림 예약 (백그라운드에서도 알림)
        NotificationManager.scheduleTimerCompleteNotification(after: totalDuration)

        // 서버에 세션 생성
        Task {
            do {
                let response = try await SessionService.shared.createSession(
                    cupSize: size.rawValue,
                    totalDuration: totalDuration
                )
                await MainActor.run {
                    self.currentSessionId = response.sessionId
                    self.saveSession()
                }
            } catch {
                print("세션 생성 실패: \(error.localizedDescription)")
            }
        }
    }

    func pauseTimer() {
        timerState = .paused
        timer?.cancel()
    }

    func resumeTimer() {
        timerState = .running
        setupTimer()
    }

    func abortTimer() {
        timer?.cancel()
        timerState = .aborted
        setFocusMode(false)
        stopNoise()
        NotificationManager.cancelTimerNotification()

        // 서버에 세션 포기 전송
        let elapsed = elapsedSeconds
        let water = waterML
        Task {
            var retries = 0
            while currentSessionId == nil && retries < 10 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                retries += 1
            }
            guard let sessionId = currentSessionId else { return }
            do {
                _ = try await SessionService.shared.abortSession(
                    id: sessionId,
                    elapsedTime: elapsed,
                    waterMl: water
                )
            } catch {
                print("세션 포기 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    func toggleFocusMode() {
        isFocusMode.toggle()
        setFocusMode(isFocusMode)
    }

    // MARK: - 백색소음
    func toggleNoise() {
        if isNoiseOn {
            WhiteNoiseService.shared.stop()
            isNoiseOn = false
        } else {
            WhiteNoiseService.shared.play(type: noiseType)
            isNoiseOn = true
        }
    }

    func changeNoiseType(_ type: NoiseType) {
        noiseType = type
        if isNoiseOn {
            WhiteNoiseService.shared.play(type: type)
        }
    }

    func updateNoiseVolume(_ vol: Float) {
        noiseVolume = vol
        WhiteNoiseService.shared.setVolume(vol)
    }

    func reset() {
        timer?.cancel()
        timerState = .idle
        elapsedSeconds = 0
        totalDuration = 0
        currentSessionId = nil
        setFocusMode(false)
        stopNoise()
        clearSession()
        NotificationManager.cancelTimerNotification()
    }

    private func stopNoise() {
        if isNoiseOn {
            WhiteNoiseService.shared.stop()
            isNoiseOn = false
        }
    }

    private func setFocusMode(_ enabled: Bool) {
        isFocusMode = enabled
        UIApplication.shared.isIdleTimerDisabled = enabled
    }

    // MARK: - Private
    private func setupTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.timerState == .running else { return }
                self.elapsedSeconds += 1
                if self.elapsedSeconds >= self.totalDuration {
                    self.timer?.cancel()
                    self.timerState = .completed
                    self.setFocusMode(false)
                    self.stopNoise()
                    self.clearSession()
                    NotificationManager.cancelTimerNotification()
                    self.sendComplete()
                }
            }
    }

    private func sendComplete() {
        let elapsed = elapsedSeconds
        let water = waterML
        Task {
            // 세션 ID가 아직 없으면 최대 5초 대기
            var retries = 0
            while currentSessionId == nil && retries < 10 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                retries += 1
            }
            guard let sessionId = currentSessionId else {
                print("세션 ID를 받지 못해 완료 전송 실패")
                return
            }
            do {
                _ = try await SessionService.shared.completeSession(
                    id: sessionId,
                    elapsedTime: elapsed,
                    waterMl: water
                )
                // 위젯 갱신
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("세션 완료 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    private func observeBackground() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, self.timerState == .running else { return }
            self.backgroundDate = Date()
            self.timer?.cancel()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, let bg = self.backgroundDate else { return }
            let diff = Int(Date().timeIntervalSince(bg))
            self.elapsedSeconds += diff
            self.backgroundDate = nil

            if self.elapsedSeconds >= self.totalDuration {
                self.elapsedSeconds = self.totalDuration
                self.timerState = .completed
                self.sendComplete()
            } else if self.timerState == .running {
                self.setupTimer()
            }
        }
    }
}
