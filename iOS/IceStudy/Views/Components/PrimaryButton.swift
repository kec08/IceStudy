import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? AppColor.primary : AppColor.surface)
                .cornerRadius(14)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "시작하기") {}
        PrimaryButton(title: "비활성", isEnabled: false) {}
    }
    .padding()
}
