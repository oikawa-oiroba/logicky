import SwiftUI

struct HistoryView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    private var sortedAttempts: [QuizAttempt] {
        attemptService.attempts.sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if sortedAttempts.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(sortedAttempts) { attempt in
                        AttemptRow(attempt: attempt)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("過去の結果")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(Color.appGray)
            Text("まだ回答履歴がありません")
                .font(.headline)
                .foregroundStyle(Color.appSub)
            Text("単元を選んで問題に挑戦してみましょう")
                .font(.subheadline)
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

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
