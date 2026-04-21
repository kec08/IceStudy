import SwiftUI

struct CupSelectionView: View {
    @State private var selectedCup: CupSize?
    @Bindable var viewModel: TimerViewModel

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

                // 타이틀
                Text("얼음컵을 선택해주세요")
                    .font(AppFont.title2())
                    .foregroundColor(AppColor.primary)
                    .padding(.bottom, 40)

                // 컵 3개
                HStack(spacing: 12) {
                    ForEach(CupSize.allCases, id: \.self) { cup in
                        cupCard(cup)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // 시작하기 버튼
                Button {
                    if let cup = selectedCup {
                        viewModel.startTimer(size: cup)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                        Text("시작하기")
                            .font(.system(size: 26, weight: .bold))
                    }
                    .foregroundColor(selectedCup != nil ? AppColor.primary : AppColor.textTertiary)
                }
                .disabled(selectedCup == nil)
                .padding(.bottom, 80)
            }
        }
    }

    private func cupCard(_ cup: CupSize) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedCup = cup
            }
        } label: {
            VStack(spacing: 10) {
                Image(cup.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)

                Text(cup.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)

                Text(cup.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(cup.color)

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(Int(cup.maxML))")
                        .font(.system(size: 20, weight: .bold))
                    Text("ml")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(cup.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedCup == cup ? cup.color : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(selectedCup == cup ? 1.05 : 1.0)
        }
    }
}

#Preview {
    CupSelectionView(viewModel: TimerViewModel())
}
