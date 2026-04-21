import SwiftUI

struct IceTimerFlowView: View {
    @State private var viewModel = TimerViewModel()

    var body: some View {
        Group {
            switch viewModel.timerState {
            case .idle:
                CupSelectionView(viewModel: viewModel)
            case .running, .paused:
                TimerRunningView(viewModel: viewModel)
            case .completed:
                TimerResultView(viewModel: viewModel, isCompleted: true)
            case .aborted:
                TimerResultView(viewModel: viewModel, isCompleted: false)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState == .idle)
        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState == .completed)
        .animation(.easeInOut(duration: 0.3), value: viewModel.timerState == .aborted)
    }
}

#Preview {
    IceTimerFlowView()
}
