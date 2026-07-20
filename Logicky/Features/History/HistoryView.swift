import SwiftUI
import Charts

struct HistoryView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    @State private var selectedTab = 0

    private var sortedAttempts: [QuizAttempt] {
        attemptService.attempts.sorted { $0.date > $1.date }
    }

    private var diagnosticResults: [DiagnosticResult] {
        DiagnosticService.shared.allResults
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("履歴タブ", selection: $selectedTab) {
                Text("学習履歴").tag(0)
                Text("診断履歴").tag(1)
                Text("ロジ先生").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.appBg)

            if selectedTab == 0 {
                quizHistoryTab
            } else if selectedTab == 1 {
                diagnosticHistoryTab
            } else {
                TutorLogListView()
            }
        }
        .navigationTitle("過去の結果")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .background(Color.appBg)
    }

    // MARK: - Quiz History

    private var quizHistoryTab: some View {
        Group {
            if sortedAttempts.isEmpty {
                emptyState(icon: "clock.arrow.circlepath", message: "まだ回答履歴がありません", sub: "単元を選んで問題に挑戦してみましょう")
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        StudyCalendarCard(attempts: sortedAttempts)
                        DailyAnswersChartCard(attempts: sortedAttempts)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("トレーニング履歴")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appText)
                            VStack(spacing: 8) {
                                ForEach(sortedAttempts) { attempt in
                                    AttemptRow(attempt: attempt)
                                        .padding(12)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    // MARK: - Diagnostic History

    private var diagnosticHistoryTab: some View {
        Group {
            if diagnosticResults.isEmpty {
                emptyState(icon: "brain.head.profile", message: "まだ診断履歴がありません", sub: "ホームの診断バナーから挑戦してみましょう")
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if diagnosticResults.count >= 2 {
                            scoreChartCard
                        }
                        ForEach(Array(diagnosticResults.enumerated()), id: \.element.id) { index, result in
                            Button {
                                navigationPath.append(AppRoute.diagnosticDetail(result: result))
                            } label: {
                                DiagnosticResultRow(result: result, prevResult: diagnosticResults.indices.contains(index + 1) ? diagnosticResults[index + 1] : nil)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var scoreChartCard: some View {
        let chartData = diagnosticResults.reversed().suffix(10)
        return VStack(alignment: .leading, spacing: 12) {
            Text("スコア推移")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appText)
            Chart(Array(chartData.enumerated()), id: \.offset) { index, result in
                LineMark(
                    x: .value("回", index + 1),
                    y: .value("スコア", result.totalScore)
                )
                .foregroundStyle(Color.tiffany)
                .interpolationMethod(.catmullRom)
                PointMark(
                    x: .value("回", index + 1),
                    y: .value("スコア", result.totalScore)
                )
                .foregroundStyle(Color.tiffany)
                .symbolSize(40)
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self) {
                            Text("第\(i)回").font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Int.self) { Text("\(v)").font(.caption2) }
                    }
                }
            }
            .frame(height: 160)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Empty State

    private func emptyState(icon: String, message: String, sub: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.appGray)
            Text(message)
                .font(.headline)
                .foregroundStyle(Color.appSub)
            Text(sub)
                .font(.subheadline)
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

// MARK: - Study Calendar

private struct StudyCalendarCard: View {
    let attempts: [QuizAttempt]

    private let calendar: Calendar = {
        var c = Calendar.current
        c.locale = Locale(identifier: "ja_JP")
        return c
    }()

    private var studiedDays: Set<Date> {
        Set(attempts.map { calendar.startOfDay(for: $0.date) })
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月"
        return f.string(from: Date())
    }

    // 今月の日付をカレンダー配置（週ごと・先頭は空白埋め）で返す
    private var dayCells: [Date?] {
        let today = Date()
        guard let interval = calendar.dateInterval(of: .month, for: today) else { return [] }
        let firstDay = interval.start
        let dayCount = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
        let leadingBlanks = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for d in 0..<dayCount {
            cells.append(calendar.date(byAdding: .day, value: d, to: firstDay))
        }
        return cells
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("学習カレンダー")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                Spacer()
                Text(monthTitle)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { w in
                    Text(w)
                        .font(.caption2)
                        .foregroundStyle(Color.appGray)
                }
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let studied = studiedDays.contains(calendar.startOfDay(for: day))
                        let isToday = calendar.isDateInToday(day)
                        Text("\(calendar.component(.day, from: day))")
                            .font(.caption2.weight(studied ? .bold : .regular))
                            .foregroundStyle(studied ? .white : (isToday ? Color.tiffany : Color.appSub))
                            .frame(width: 28, height: 28)
                            .background(studied ? Color.tiffany : Color.clear)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(isToday ? Color.tiffany : Color.clear, lineWidth: 1.5)
                            )
                    } else {
                        Color.clear.frame(width: 28, height: 28)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - Daily Answers Chart

private struct DailyAnswersChartCard: View {
    let attempts: [QuizAttempt]

    private struct DayCount: Identifiable {
        let date: Date
        let count: Int
        var id: Date { date }
    }

    // 直近14日間の日別回答数
    private var dailyCounts: [DayCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var counts: [Date: Int] = [:]
        for attempt in attempts {
            let day = calendar.startOfDay(for: attempt.date)
            counts[day, default: 0] += attempt.questionResults.filter { !$0.isSkipped }.count
        }
        return (0..<14).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DayCount(date: day, count: counts[day] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別の回答数（直近14日）")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appText)

            Chart(dailyCounts) { item in
                BarMark(
                    x: .value("日", item.date, unit: .day),
                    y: .value("回答数", item.count)
                )
                .foregroundStyle(item.count > 0 ? Color.tiffany : Color.cardBorder)
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                    AxisValueLabel(format: .dateTime.day(), centered: true)
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Int.self) { Text("\(v)").font(.caption2) }
                    }
                }
            }
            .frame(height: 130)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - AttemptRow

private struct AttemptRow: View {
    let attempt: QuizAttempt

    private var unit: UnitModel? {
        UnitModel.all.first { $0.id == attempt.unitId }
    }

    private var unitName: String {
        // 「仲間分けする力（分類・グルーピング）」の形式で表示
        guard let unit else { return attempt.unitId }
        return "\(unit.displayName)（\(unit.name)）"
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: attempt.date)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(scoreColor(attempt.totalScore).opacity(0.12))
                    .frame(width: 52, height: 52)
                VStack(spacing: 0) {
                    Text("\(attempt.totalScore)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor(attempt.totalScore))
                    Text("点")
                        .font(.caption2)
                        .foregroundStyle(Color.appSub)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(unitName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)

                let answered = attempt.questionResults.filter { !$0.isSkipped }.count
                let total    = attempt.questionResults.count
                Text("\(answered)/\(total) 問回答")
                    .font(.caption2)
                    .foregroundStyle(Color.appGray)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func scoreColor(_ score: Int) -> Color {
        score >= 70 ? Color.tiffany : Color.appGray
    }
}

// MARK: - DiagnosticResultRow

private struct DiagnosticResultRow: View {
    let result: DiagnosticResult
    let prevResult: DiagnosticResult?

    private var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: result.date)
    }

    private var rankLabel: String {
        switch result.totalScore {
        case 90...100: return "S"
        case 80..<90:  return "A"
        case 70..<80:  return "B+"
        case 60..<70:  return "B"
        case 50..<60:  return "C"
        default:       return "D"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text("\(result.totalScore)点")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.tiffany)
                        Text("ランク \(rankLabel)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.tiffany)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.tiffany.opacity(0.1))
                            .clipShape(Capsule())
                        if let prev = prevResult {
                            let delta = result.totalScore - prev.totalScore
                            HStack(spacing: 2) {
                                Image(systemName: delta >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 9, weight: .bold))
                                Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(delta >= 0 ? Color.tiffany : Color.appGray)
                        }
                    }
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(Color.appSub)
                }
                Spacer()
            }

            HStack(spacing: 0) {
                axisChip(label: "整理力", score: result.organizeScore, prev: prevResult?.organizeScore)
                Divider().frame(height: 32).padding(.horizontal, 8)
                axisChip(label: "推論力", score: result.reasonScore,   prev: prevResult?.reasonScore)
                Divider().frame(height: 32).padding(.horizontal, 8)
                axisChip(label: "判断力", score: result.judgeScore,    prev: prevResult?.judgeScore)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func axisChip(label: String, score: Int, prev: Int?) -> some View {
        VStack(spacing: 2) {
            Text("\(score)%")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tiffany)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appSub)
            if let prev {
                let delta = score - prev
                Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(delta >= 0 ? Color.tiffany : Color.appGray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
