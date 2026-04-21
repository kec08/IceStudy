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
        switch viewModel.timerState {
        case .running: "집중을 유지하고 있습니다"
        case .paused: "일시정지 중입니다"
        default: ""
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 48) {
            // 달 (화면 잠금 - 추후)
            Button {
                // 화면 잠금 모드 (추후 구현)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E8E8E8"))
                        .frame(width: 48, height: 48)
                    Image(systemName: "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColor.textSecondary)
                }
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
    }
}

#Preview {
    let vm = TimerViewModel()
    vm.startTimer(size: .tall)
    return TimerRunningView(viewModel: vm)
}
