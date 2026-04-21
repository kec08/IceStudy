import SwiftUI

struct StudyCalendarView: View {
    @Environment(\.dismiss) var dismiss

    // 임시 데이터: 날짜별 (공부 분, 물 ml)
    private let studyData: [String: (minutes: Int, ml: Int)] = {
        var data: [String: (Int, Int)] = [:]
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // 1월~4월 임시 데이터 생성
        let startComponents = DateComponents(year: 2026, month: 1, day: 1)
        guard let startDate = calendar.date(from: startComponents) else { return data }

        var current = startDate
        let today = Date()

        while current <= today {
            let key = formatter.string(from: current)
            let dayOfWeek = calendar.component(.weekday, from: current)
            // 주말은 적게, 평일은 많게 (랜덤 느낌)
            let hash = key.hashValue
            let isWeekend = dayOfWeek == 1 || dayOfWeek == 7
            let baseMinutes = isWeekend ? 30 : 90
            let variance = abs(hash % 150)
            let minutes = max(0, baseMinutes + variance % 180)
            let ml = Int(Double(minutes) / 60.0 * 355.0)

            if minutes > 15 { // 15분 이하는 기록 없음 처리
                data[key] = (minutes, ml)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return data
    }()

    private let months: [(year: Int, month: Int)] = {
        var result: [(Int, Int)] = []
        for m in 1...4 {
            result.append((2026, m))
        }
        return result
    }()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // 네비바
                ZStack {
                    Text("공부 기록")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // 요일 헤더
                weekdayHeader
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                // 달력 스크롤
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(months, id: \.month) { item in
                            monthSection(year: item.year, month: item.month)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - 요일 헤더
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(day == "일" ? AppColor.danger : AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 월 섹션
    private func monthSection(year: Int, month: Int) -> some View {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let components = DateComponents(year: year, month: month, day: 1)
        let firstDay = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDay) // 1=일, 7=토
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)!.count
        let today = Date()
        let todayString = formatter.string(from: today)

        return VStack(alignment: .leading, spacing: 8) {
            // 월 타이틀
            Text("\(month)월")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColor.textPrimary)
                .padding(.leading, 4)
                .padding(.bottom, 4)

            // 날짜 그리드
            let totalCells = weekday - 1 + daysInMonth
            let rows = (totalCells + 6) / 7

            VStack(spacing: 2) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col
                            let day = index - (weekday - 1) + 1

                            if day >= 1 && day <= daysInMonth {
                                let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
                                let isToday = dateStr == todayString
                                let data = studyData[dateStr]
                                let isFuture: Bool = {
                                    if let d = formatter.date(from: dateStr) {
                                        return d > today
                                    }
                                    return false
                                }()

                                dayCell(day: day, data: data, isToday: isToday, isFuture: isFuture)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 날짜 셀
    private func dayCell(day: Int, data: (minutes: Int, ml: Int)?, isToday: Bool, isFuture: Bool) -> some View {
        VStack(spacing: 2) {
            // 날짜
            Text("\(day)")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? AppColor.primary : (isFuture ? AppColor.textTertiary : AppColor.textPrimary))

            if let data, !isFuture {
                // 공부 시간
                let h = data.minutes / 60
                let m = data.minutes % 60
                Text(h > 0 ? "\(h)h\(m)m" : "\(m)m")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppColor.primary)

                // 물양
                Text("\(data.ml)ml")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(AppColor.textSecondary)
            } else {
                Text("")
                    .font(.system(size: 8))
                Text("")
                    .font(.system(size: 7))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(cellBackground(data: data, isToday: isToday, isFuture: isFuture))
        )
    }

    private func cellBackground(data: (minutes: Int, ml: Int)?, isToday: Bool, isFuture: Bool) -> Color {
        if isToday {
            return AppColor.primary.opacity(0.08)
        }
        guard let data, !isFuture else { return Color.clear }

        // 공부량에 따라 색상 농도 (기본 연하게, 3~4시간 넘으면 진하게)
        let minutes = Double(data.minutes)
        if minutes >= 180 { // 3시간 이상
            let extra = min((minutes - 180) / 60.0, 1.0) // 3~4시간 사이 0→1
            return AppColor.primary.opacity(0.12 + extra * 0.10)
        } else {
            let intensity = minutes / 180.0
            return AppColor.primary.opacity(0.03 + intensity * 0.08)
        }
    }
}

#Preview {
    StudyCalendarView()
}
