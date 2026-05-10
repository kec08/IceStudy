import SwiftUI

struct TimerRunningView: View {
    @Bindable var viewModel: TimerViewModel
    @State private var showAbortAlert = false
    @State private var showFocusGuide = false
    @State private var showNoisePanel = false
    @AppStorage("hasSeenFocusGuide") private var hasSeenFocusGuide = false

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 로고 + 백색소음 버튼 (오른쪽 상단)
                HStack(spacing: 4) {
                    LogoHeaderView()
                    Spacer()
                    Button {
                        showNoisePanel.toggle()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "waveform")
                                .font(.system(size: 20, weight: .semibold))
                            if viewModel.isNoiseOn {
                                Circle()
                                    .fill(AppColor.primary)
                                    .frame(width: 7, height: 7)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(viewModel.isNoiseOn ? AppColor.primary : AppColor.textSecondary)
                        .frame(width: 44, height: 44)
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isNoiseOn)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // 백색소음 설정 패널 (토글 시 표시)
                if showNoisePanel {
                    noisePanel
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                Spacer()

                // 온도 표시
                if let temp = viewModel.currentTemperature,
                   let zone = viewModel.temperatureZone {
                    Text("현재 온도  \(temp)°")
                        .font(AppFont.headline())
                        .foregroundColor(zone.color)
                        .padding(.bottom, 4)
                }

                // 상태 텍스트
                Text("\(viewModel.cupSize.rawValue) 얼음컵")
                    .font(AppFont.title3())
                    .foregroundColor(AppColor.textSecondary)

                Text(statusMessage)
                    .font(AppFont.title2())
                    .foregroundColor(AppColor.primary)
                    .padding(.top, 4)

                // 얼음 녹는 애니메이션 (컵 사이즈별 비선형 커브 적용)
                IceMeltingView(progress: viewModel.iceVisualProgress)
                    .frame(height: 340)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Spacer()

                // 하단 3버튼
                controlButtons
                    .padding(.bottom, 24)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showNoisePanel)
        .alert("집중을 포기하시겠습니까?", isPresented: $showAbortAlert) {
            Button("계속하기", role: .cancel) {}
            Button("포기하기", role: .destructive) {
                viewModel.abortTimer()
            }
        } message: {
            Text("지금까지의 기록은 저장됩니다.")
        }
    }

    private var statusMessage: String {
        if viewModel.timerState == .paused {
            return "잠깐 쉬어가는 중..."
        }
        let p = viewModel.iceVisualProgress
        switch p {
        case ..<0.1:
            return "얼음이 녹기 시작했어요"
        case 0.1..<0.2:
            return "좋은 시작이에요, 계속 가봐요"
        case 0.2..<0.3:
            return "집중의 흐름을 타고 있어요"
        case 0.3..<0.4:
            return "벌써 꽤 녹았어요, 잘하고 있어요"
        case 0.4..<0.5:
            return "절반 가까이 왔어요!"
        case 0.5..<0.6:
            return "반을 넘겼어요, 대단해요"
        case 0.6..<0.7:
            return "오늘 집중력이 남다르네요"
        case 0.7..<0.8:
            return "거의 다 녹아가고 있어요"
        case 0.8..<0.9:
            return "조금만 더! 끝이 보여요"
        default:
            return "마지막 한 방울까지 화이팅!"
        }
    }

    // MARK: - 백색소음 설정 패널
    private var noisePanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(NoiseType.allCases, id: \.rawValue) { type in
                    let isActive = viewModel.isNoiseOn && viewModel.noiseType == type
                    Button {
                        if isActive {
                            viewModel.toggleNoise()
                        } else {
                            viewModel.changeNoiseType(type)
                            if !viewModel.isNoiseOn { viewModel.toggleNoise() }
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16))
                            Text(type.rawValue)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(isActive ? .white : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isActive ? AppColor.primary : Color(hex: "F5F5F5"))
                        )
                    }
                }
            }

            // 볼륨
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
                Slider(value: Binding(
                    get: { Double(viewModel.noiseVolume) },
                    set: { viewModel.updateNoiseVolume(Float($0)) }
                ), in: 0.05...1.0)
                .tint(AppColor.primary)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    // MARK: - 하단 3버튼
    private var controlButtons: some View {
        HStack(spacing: 48) {
            // 집중모드 (화면 꺼짐 방지)
            Button {
                viewModel.toggleFocusMode()
                if viewModel.isFocusMode && !hasSeenFocusGuide {
                    showFocusGuide = true
                    hasSeenFocusGuide = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isFocusMode ? AppColor.primary : Color(hex: "E8E8E8"))
                        .frame(width: 48, height: 48)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.isFocusMode ? .white : AppColor.textSecondary)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isFocusMode)
            .alert("화면이 꺼지지 않아요", isPresented: $showFocusGuide) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("공부하는 동안 화면이 꺼지지 않습니다.")
            }

            // 재생 / 일시정지
            Button {
                if viewModel.timerState == .running {
                    viewModel.pauseTimer()
                } else {
                    viewModel.resumeTimer()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.primary)
                        .frame(width: 56, height: 56)
                    Image(systemName: viewModel.timerState == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }

            // 정지 (포기)
            Button {
                showAbortAlert = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E8E8E8"))
                        .frame(width: 48, height: 48)
                    Image(systemName: "stop.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    let vm = TimerViewModel()
    vm.startTimer(size: .tall)
    return TimerRunningView(viewModel: vm)
}
