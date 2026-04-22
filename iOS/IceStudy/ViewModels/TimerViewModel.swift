import SwiftUI
import Combine

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

    private(set) var totalDuration: Int = 0
    private var timer: AnyCancellable?
    private var backgroundDate: Date?
    private(set) var currentSessionId: Int?

    // MARK: - Computed
    var progress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return min(CGFloat(elapsedSeconds) / CGFloat(totalDuration), 1.0)
    }

    var waterML: Double {
        Double(progress) * cupSize.maxML
    }

    var elapsedHours: Int {
        elapsedSeconds / 3600
    }

    var elapsedMinutes: Int {
        (elapsedSeconds % 3600) / 60
    }

    // MARK: - Actions
    func startTimer(size: CupSize) {
        cupSize = size
        totalDuration = size.randomDuration()
        elapsedSeconds = 0
        timerState = .running
        setupTimer()
        observeBackground()

        // 서버에 세션 생성
        Task {
            do {
                let response = try await SessionService.shared.createSession(
                    cupSize: size.rawValue,
                    totalDuration: totalDuration
                )
                await MainActor.run {
                    self.currentSessionId = response.sessionId
                }
            } catch {
                print("세션 생성 ���패: \(error.localizedDescription)")
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

        // 서버에 세션 포기 전송
        guard let sessionId = currentSessionId else { return }
        let elapsed = elapsedSeconds
        let water = waterML
        Task {
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

    func reset() {
        timer?.cancel()
        timerState = .idle
        elapsedSeconds = 0
        totalDuration = 0
        currentSessionId = nil
        setFocusMode(false)
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
                    self.sendComplete()
                }
            }
    }

    private func sendComplete() {
        guard let sessionId = currentSessionId else { return }
        let elapsed = elapsedSeconds
        let water = waterML
        Task {
            do {
                _ = try await SessionService.shared.completeSession(
                    id: sessionId,
                    elapsedTime: elapsed,
                    waterMl: water
                )
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
