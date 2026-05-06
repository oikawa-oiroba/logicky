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
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.appBg)

            if selectedTab == 0 {
                quizHistoryTab
            } else {
                diagnosticHistoryTab
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
                List {
                    ForEach(sortedAttempts) { attempt in
                        AttemptRow(attempt: attempt)
                    }
                }
                .listStyle(.insetGrouped)
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

// MARK: - AttemptRow

private struct AttemptRow: View {
    let attempt: QuizAttempt

    private var unitName: String {
        UnitModel.all.first { $0.id == attempt.unitId }?.name ?? attempt.unitId
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
