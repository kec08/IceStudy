import AVFoundation

enum NoiseType: String, CaseIterable {
    case waterDrop = "계곡물"
    case campfire = "모닥불"
    case forest = "숲소리"
    case night = "고요한 밤"

    var icon: String {
        switch self {
        case .waterDrop: "drop.fill"
        case .campfire: "flame.fill"
        case .forest: "leaf.fill"
        case .night: "moon.stars.fill"
        }
    }

    /// 번들 오디오 파일명 (있으면 파일 재생, 없으면 합성)
    var audioFileName: String? {
        switch self {
        case .waterDrop: "stream"
        case .campfire: "campfire"
        case .forest: "forest"
        case .night: "night"
        }
    }
}

final class WhiteNoiseService {
    static let shared = WhiteNoiseService()

    // 파일 재생용
    private var filePlayer: AVAudioPlayer?
    // 합성 재생용
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var noiseBuffer: AVAudioPCMBuffer?

    private(set) var isPlaying = false
    private(set) var currentType: NoiseType = .waterDrop
    var volume: Float = 0.3

    private init() {}

    func play(type: NoiseType = .waterDrop) {
        stop()
        currentType = type

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
            return
        }

        // 번들 파일이 있으면 파일 재생, 없으면 합성
        if let fileName = type.audioFileName, let url = findAudioFile(named: fileName) {
            playFile(url: url)
        } else {
            playSynthesized(type: type)
        }

        isPlaying = true
    }

    func stop() {
        filePlayer?.stop()
        filePlayer = nil
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        noiseBuffer = nil
        isPlaying = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func setVolume(_ vol: Float) {
        volume = max(0, min(1, vol))
        filePlayer?.volume = volume
        playerNode?.volume = volume
    }

    // MARK: - 번들 파일 찾기
    private func findAudioFile(named name: String) -> URL? {
        for ext in ["mp3", "m4a", "wav", "aac", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    // MARK: - 파일 기반 재생 (루프)
    private func playFile(url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1  // 무한 루프
            player.volume = volume
            player.prepareToPlay()
            player.play()
            filePlayer = player
        } catch {
            print("오디오 파일 재생 실패: \(error), 합성으로 전환")
            playSynthesized(type: currentType)
        }
    }

    // MARK: - 합성 기반 재생 (폴백)
    private func playSynthesized(type: NoiseType) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        let frameCount = AVAudioFrameCount(44100 * 2)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return }
        fillBuffer(channelData, frameCount: Int(frameCount), type: type)

        do {
            try engine.start()
        } catch {
            print("오디오 엔진 시작 실패: \(error)")
            return
        }

        player.volume = volume
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()

        audioEngine = engine
        playerNode = player
        noiseBuffer = buffer
    }

    // MARK: - 합성 노이즈 생성
    private func fillBuffer(_ data: UnsafeMutablePointer<Float>, frameCount: Int, type: NoiseType) {
        switch type {
        case .waterDrop:
            let sr: Float = 44100
            var brown: Float = 0
            var bp1: Float = 0, bp1prev: Float = 0
            var bp2: Float = 0, bp2prev: Float = 0
            var nextBubble = Int.random(in: 800...4000)
            var bubblePos = 0
            var bubbleFreq: Float = 0
            var bubbleLen = 0

            for i in 0..<frameCount {
                let white = Float.random(in: -1...1)
                brown = (brown + 0.015 * white) / 1.015
                let layer1 = brown * 4.0
                let cutoff1: Float = 300.0 / sr
                let q1: Float = 0.7
                let newBp1 = bp1 + cutoff1 * (white - bp1 - q1 * (bp1 - bp1prev))
                bp1prev = bp1
                bp1 = newBp1
                let layer2 = bp1 * 1.8
                let cutoff2: Float = 1200.0 / sr
                let q2: Float = 0.5
                let newBp2 = bp2 + cutoff2 * (white - bp2 - q2 * (bp2 - bp2prev))
                bp2prev = bp2
                bp2 = newBp2
                let layer3 = bp2 * 0.6
                var bubble: Float = 0
                if i >= nextBubble && bubblePos == 0 {
                    bubbleFreq = Float.random(in: 600...1800)
                    bubbleLen = Int(sr * Float.random(in: 0.008...0.025))
                    bubblePos = 1
                }
                if bubblePos > 0 && bubblePos <= bubbleLen {
                    let t = Float(bubblePos) / sr
                    let env = expf(-t * 120)
                    bubble = sinf(2.0 * .pi * bubbleFreq * t) * env * 0.2
                    bubblePos += 1
                    if bubblePos > bubbleLen {
                        bubblePos = 0
                        nextBubble = i + Int.random(in: 1500...6000)
                    }
                }
                data[i] = (layer1 + layer2 + layer3 + bubble) * 0.12
            }

        case .campfire:
            // 모닥불: 저주파 크래클 + 랜덤 탁탁 스파크
            let sr: Float = 44100
            var brown: Float = 0
            var nextCrackle = Int.random(in: 200...2000)
            var cracklePos = 0
            var crackleLen = 0

            for i in 0..<frameCount {
                let white = Float.random(in: -1...1)

                // 기본 불꽃 윙윙 (깊은 브라운 노이즈)
                brown = (brown + 0.008 * white) / 1.008
                let base = brown * 5.0

                // 랜덤 탁탁 크래클
                var crackle: Float = 0
                if i >= nextCrackle && cracklePos == 0 {
                    crackleLen = Int.random(in: 80...400)
                    cracklePos = 1
                }
                if cracklePos > 0 && cracklePos <= crackleLen {
                    let t = Float(cracklePos) / Float(crackleLen)
                    let env = (1.0 - t) * (1.0 - t) // 빠른 감쇠
                    crackle = Float.random(in: -1...1) * env * 0.4
                    cracklePos += 1
                    if cracklePos > crackleLen {
                        cracklePos = 0
                        nextCrackle = i + Int.random(in: Int(sr * 0.05)...Int(sr * 0.4))
                    }
                }

                data[i] = (base + crackle) * 0.15
            }

        case .forest:
            var b0: Float = 0, b1: Float = 0, b2: Float = 0
            var b3: Float = 0, b4: Float = 0, b5: Float = 0, b6: Float = 0
            for i in 0..<frameCount {
                let white = Float.random(in: -1...1)
                b0 = 0.99886 * b0 + white * 0.0555179
                b1 = 0.99332 * b1 + white * 0.0750759
                b2 = 0.96900 * b2 + white * 0.1538520
                b3 = 0.86650 * b3 + white * 0.3104856
                b4 = 0.55000 * b4 + white * 0.5329522
                b5 = -0.7616 * b5 - white * 0.0168980
                let pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362
                b6 = white * 0.115926
                data[i] = pink * 0.02
            }

        case .night:
            // 고요한 밤: 아주 부드러운 바람 + 간헐적 귀뚜라미
            let sr: Float = 44100
            var brown: Float = 0
            // 귀뚜라미: 주기적 짧은 사인파 처프
            var cricketPhase: Float = 0
            var nextChirp = Int.random(in: Int(sr * 0.6)...Int(sr * 1.5))
            var chirpPos = 0
            let chirpLen = Int(sr * 0.08)

            for i in 0..<frameCount {
                let white = Float.random(in: -1...1)

                // 매우 부드러운 바람 (거의 무음에 가까운 브라운 노이즈)
                brown = (brown + 0.005 * white) / 1.005
                let wind = brown * 1.5

                // 귀뚜라미
                var cricket: Float = 0
                if i >= nextChirp && chirpPos == 0 {
                    chirpPos = 1
                }
                if chirpPos > 0 && chirpPos <= chirpLen {
                    let t = Float(chirpPos) / sr
                    cricketPhase += 2.0 * .pi * 4200.0 / sr
                    let env = sinf(.pi * Float(chirpPos) / Float(chirpLen)) // 부드러운 벨 커브
                    cricket = sinf(cricketPhase) * env * 0.06
                    chirpPos += 1
                    if chirpPos > chirpLen {
                        chirpPos = 0
                        nextChirp = i + Int.random(in: Int(sr * 0.15)...Int(sr * 0.35))
                    }
                }

                data[i] = (wind + cricket) * 0.2
            }
        }
    }
}
