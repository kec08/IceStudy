import WidgetKit
import SwiftUI

// MARK: - Shared Data

struct WidgetData: Codable {
    var filledMl: Int
    var goalMl: Int
    var totalMinutes: Int
    var weeklyMinutes: [Int]
    var lastUpdated: Date

    static let empty = WidgetData(
        filledMl: 0, goalMl: 3000, totalMinutes: 0,
        weeklyMinutes: [0, 0, 0, 0, 0, 0, 0], lastUpdated: Date()
    )
}

enum WidgetDataStore {
    static let appGroupId = "group.com.silver.icestudy"

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    static func save(_ data: WidgetData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }

    static func load() -> WidgetData {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }
}

// MARK: - 양동이 위젯 (Small)

struct BucketProvider: TimelineProvider {
    func placeholder(in context: Context) -> BucketEntry {
        BucketEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (BucketEntry) -> Void) {
        completion(BucketEntry(date: Date(), data: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BucketEntry>) -> Void) {
        let data = WidgetDataStore.load()
        let entry = BucketEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct BucketEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct BucketWidgetView: View {
    let entry: BucketEntry

    private var fillRatio: CGFloat {
        guard entry.data.goalMl > 0 else { return 0 }
        return min(CGFloat(entry.data.filledMl) / CGFloat(entry.data.goalMl), 1.0)
    }

    private var hours: Int { entry.data.totalMinutes / 60 }
    private var minutes: Int { entry.data.totalMinutes % 60 }

    var body: some View {
        VStack(spacing: 0) {
            Text("채운 물양")
                .font(.system(size: 8))
                .foregroundColor(Color(hex: "9E9E9E"))
                .padding(.top, 12)

            Text("\(entry.data.filledMl)ml")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "48C7FF"))
                .padding(.top, 2)
                .padding(.bottom, -4)

            GeometryReader { geo in
                let cupWidth = geo.size.width * 0.5
                let cupHeight = cupWidth * 1.0

                ZStack {
                    WidgetCupShape()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: cupWidth, height: cupHeight)

                    if fillRatio > 0 {
                        WidgetCupShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "48C7FF").opacity(0.15),
                                        Color(hex: "48C7FF").opacity(0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: cupWidth, height: cupHeight)
                            .mask(
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(height: cupHeight * fillRatio)
                                }
                                .frame(height: cupHeight)
                            )
                    }

                    WidgetCupShape()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "C6E8F9").opacity(0.7),
                                    Color(hex: "A0D4ED").opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .frame(width: cupWidth, height: cupHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.vertical, -10)
            .frame(height: 90)
            

            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("이번주 목표량")
                        .font(.system(size: 7))
                        .foregroundColor(Color(hex: "9E9E9E"))
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(entry.data.goalMl)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "48C7FF"))
                        Text("ml")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "212121"))
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 2) {
                    Text("이번주 공부 시간")
                        .font(.system(size: 7))
                        .foregroundColor(Color(hex: "9E9E9E"))
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(hours)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "48C7FF"))
                        Text("시간")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "212121"))
                        Text("\(minutes)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "48C7FF"))
                        Text("분")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "212121"))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 14)
        }
        .containerBackground(for: .widget) {
            Color(hex: "EAF9FF")
        }
    }
}

struct IceStudyWidget: Widget {
    let kind = "BucketWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BucketProvider()) { entry in
            BucketWidgetView(entry: entry)
        }
        .configurationDisplayName("채운 물양")
        .description("이번 주 채운 물양을 확인해요")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - 일일 평균 위젯 (Medium)

struct DailyAverageProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyAverageEntry {
        DailyAverageEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyAverageEntry) -> Void) {
        completion(DailyAverageEntry(date: Date(), data: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyAverageEntry>) -> Void) {
        let data = WidgetDataStore.load()
        let entry = DailyAverageEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct DailyAverageEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct DailyAverageWidgetView: View {
    let entry: DailyAverageEntry
    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    private var dailyAverage: Int {
        let total = entry.data.weeklyMinutes.reduce(0, +)
        let activeDays = entry.data.weeklyMinutes.filter { $0 > 0 }.count
        return activeDays > 0 ? total / activeDays : 0
    }

    private var maxMinutes: Int {
        max(entry.data.weeklyMinutes.max() ?? 1, 1)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 바 차트 (하단 고정)
            VStack {
                Spacer()

                GeometryReader { geo in
                    let chartHeight = geo.size.height - 20

                    ZStack(alignment: .bottom) {
                        // 평균 점선
                        let avgRatio = CGFloat(dailyAverage) / CGFloat(maxMinutes)

                        Path { path in
                            let lineY = chartHeight * (1.0 - avgRatio)
                            path.move(to: CGPoint(x: 16, y: lineY))
                            path.addLine(to: CGPoint(x: geo.size.width - 16, y: lineY))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundColor(Color(hex: "48C7FF").opacity(0.35))
                        .frame(height: chartHeight)

                        // 바
                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(0..<7, id: \.self) { index in
                                VStack(spacing: 5) {
                                    let ratio = CGFloat(entry.data.weeklyMinutes[index]) / CGFloat(maxMinutes)
                                    let barHeight = max(chartHeight * ratio, 8)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "B8E8FF").opacity(0.5),
                                                    Color(hex: "7DD4FF").opacity(0.65),
                                                    Color(hex: "48C7FF").opacity(0.8)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: barHeight)
                                    
                                    Text(dayLabels[index])
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(Color(hex: "9E9E9E"))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(height: 100)
                .padding(.bottom, -10)
            }

            // 일일 평균 텍스트
            VStack(alignment: .leading, spacing: 2) {
                Text("일일 평균")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "9E9E9E"))

                let h = dailyAverage / 60
                let m = dailyAverage % 60
                Text(h > 0 ? "\(h)시간 \(m)분" : "\(m)분")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "212121"))
            }
            .padding(.top, -6)
            .padding(.leading, 16)
        }
        .containerBackground(for: .widget) {
            Color(hex: "EAF9FF")
        }
    }
}

struct DailyAverageWidget: Widget {
    let kind = "DailyAverageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyAverageProvider()) { entry in
            DailyAverageWidgetView(entry: entry)
        }
        .configurationDisplayName("일일 평균")
        .description("이번 주 공부 패턴을 확인해요")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Cup Shape

struct WidgetCupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let topInset = w * 0.03
        let bottomInset = w * 0.12

        path.move(to: CGPoint(x: topInset, y: 0))
        path.addLine(to: CGPoint(x: w - topInset, y: 0))
        path.addLine(to: CGPoint(x: w - bottomInset, y: h))
        path.addLine(to: CGPoint(x: bottomInset, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Color hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
