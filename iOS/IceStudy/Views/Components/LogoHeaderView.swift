import SwiftUI

struct LogoHeaderView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image("IceCube")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            Image("LogoText")
                .resizable()
                .scaledToFit()
                .frame(height: 22)
        }
    }
}

#Preview {
    LogoHeaderView()
}
