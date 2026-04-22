import SwiftUI

struct TimerRunningView: View {
    @Bindable var viewModel: TimerViewModel
    @State private var showAbortAlert = false

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 로고
                HStack {
                    LogoHeaderView()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // 상태 텍스트
                Text("\(viewModel.cupSize.rawValue) 얼음컵")
                    .font(AppFont.headline())
                    .foregroundColor(AppColor.textSecondary)

                Text(statusMessage)
                    .font(AppFont.title2())
                    .foregroundColor(AppColor.primary)
                    .padding(.top, 4)

                // 얼음 녹는 애니메이션
                IceMeltingView(progress: viewModel.progress)
                    .frame(height: 340)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Spacer()

                // 하단 3버튼
                controlButtons
                    .padding(.bottom, 24)
            }
        }
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
        let p = viewModel.progress
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

    private var controlButtons: some View {
        HStack(spacing: 48) {
            // 집중모드 (화면 꺼짐 방지)
            Button {
                viewModel.toggleFocusMode()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isFocusMode ? AppColor.primary : Color(hex: "E8E8E8"))
                        .frame(width: 48, height: 48)
                    Image(systemName: viewModel.isFocusMode ? "moon.fill" : "moon")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.isFocusMode ? .white : AppColor.textSecondary)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isFocusMode)

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
