import SwiftUI

struct LogoHeaderView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image("IceCube")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)

            Image("LogoText")
                .resizable()
                .scaledToFit()
                .frame(height: 28)
        }
    }
}

#Preview {
    LogoHeaderView()
}
