import SwiftUI

/// 위가 넓고 아래가 좁은 실제 유리컵 형태 Shape
struct GlassCupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topInset: CGFloat = rect.width * 0.02
        let bottomInset: CGFloat = rect.width * 0.14
        let cornerRadius: CGFloat = rect.width * 0.08
        let bottomCorner: CGFloat = rect.width * 0.10

        // 시작: 좌상단
        path.move(to: CGPoint(x: topInset + cornerRadius, y: 0))

        // 상단 직선
        path.addLine(to: CGPoint(x: rect.width - topInset - cornerRadius, y: 0))

        // 우상단 코너
        path.addQuadCurve(
            to: CGPoint(x: rect.width - topInset, y: cornerRadius),
            control: CGPoint(x: rect.width - topInset, y: 0)
        )

        // 우측 라인 (안쪽으로 좁아짐)
        path.addLine(to: CGPoint(x: rect.width - bottomInset, y: rect.height - bottomCorner))

        // 우하단 코너
        path.addQuadCurve(
            to: CGPoint(x: rect.width - bottomInset - bottomCorner, y: rect.height),
            control: CGPoint(x: rect.width - bottomInset, y: rect.height)
        )

        // 하단 직선
        path.addLine(to: CGPoint(x: bottomInset + bottomCorner, y: rect.height))

        // 좌하단 코너
        path.addQuadCurve(
            to: CGPoint(x: bottomInset, y: rect.height - bottomCorner),
            control: CGPoint(x: bottomInset, y: rect.height)
        )

        // 좌측 라인 (위로 넓어짐)
        path.addLine(to: CGPoint(x: topInset, y: cornerRadius))

        // 좌상단 코너
        path.addQuadCurve(
            to: CGPoint(x: topInset + cornerRadius, y: 0),
            control: CGPoint(x: topInset, y: 0)
        )

        path.closeSubpath()
        return path
    }
}
