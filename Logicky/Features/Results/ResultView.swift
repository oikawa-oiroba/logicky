import SwiftUI

struct ResultView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleHeader

                if let result = viewModel.quizResult {
                    // 総合スコア
                    totalScoreSection(result)

                    // レーダーチャート
                    radarSection(result)

                    // 問題別フィードバック
                    feedbackSection(result)
                } else {
                    Text("結果を計算中...")
                        .foregroundStyle(.secondary)
                        .padding()
                }

                homeButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Title

    private var titleHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(colors: [.indigo, .purple],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(.top, 28)
            Text("単元クリア！")
                .font(.title.bold())
            Text("結果フィードバック")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Total Score

    private func totalScoreSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.indigo.opacity(0.15), lineWidth: 14)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: CGFloat(result.totalScore) / 100)
                    .stroke(
                        LinearGradient(colors: [.indigo, .purple],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: result.totalScore)

                VStack(spacing: 2) {
                    Text("\(result.totalScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                    Text("点")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(rankLabel(result.totalScore))
                .font(.headline)
                .foregroundStyle(rankColor(result.totalScore))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(rankColor(result.totalScore).opacity(0.12))
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Radar

    private func radarSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            Text("3軸評価")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            RadarChartView(
                values: [
                    Double(result.structureScore) / 100,
                    Double(result.logicScore) / 100,
                    Double(result.specificityScore) / 100
                ],
                labels: ["構造", "論理性", "具体性"]
            )
            .frame(height: 220)

            HStack(spacing: 12) {
                ScoreChip(title: "構造", score: result.structureScore, color: .indigo)
                ScoreChip(title: "論理性", score: result.logicScore, color: .purple)
                ScoreChip(title: "具体性", score: result.specificityScore, color: .teal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Per-Question Feedback

    private func feedbackSection(_ result: QuizResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("問題ごとのフィードバック")
                .font(.headline)

            ForEach(Array(result.feedbacks.enumerated()), id: \.offset) { index, fb in
                questionFeedbackCard(index: index + 1, feedback: fb)
            }
        }
    }

    private func questionFeedbackCard(index: Int, feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Text("Q\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(feedback.question.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                Spacer()

                if feedback.answer.isSkipped {
                    Text("スキップ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.systemFill))
                        .clipShape(Capsule())
                } else {
                    Text("\(feedback.score)点")
                        .font(.subheadline.bold())
                        .foregroundStyle(feedback.score >= 70 ? .green : .red)
                }
            }

            // MC フィードバック
            if feedback.question.type == .multipleChoice {
                mcFeedback(feedback)
            } else {
                ftFeedback(feedback)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func mcFeedback(_ feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 正解/不正解
            if !feedback.answer.isSkipped, let correct = feedback.isCorrect {
                HStack {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                    Text(correct ? "正解！" : "不正解")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(correct ? .green : .red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background((correct ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // 選択した回答
            if let selectedId = feedback.answer.selectedChoiceId,
               let selected = feedback.question.choices?.first(where: { $0.id == selectedId }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(selected.text)
                        .font(.subheadline)
                }
            }

            // 正解
            if let correctId = feedback.question.correctChoiceId,
               let correct = feedback.question.choices?.first(where: { $0.id == correctId }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("正解")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                    Text(correct.text)
                        .font(.subheadline)
                }
            }

            // 解説
            if let explanation = feedback.question.explanation {
                VStack(alignment: .leading, spacing: 6) {
                    Label("解説", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                    Text(explanation)
                        .font(.subheadline)
                        .lineSpacing(4)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func ftFeedback(_ feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 回答内容
            if !feedback.answer.freeText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(feedback.answer.freeText)
                        .font(.subheadline)
                        .lineSpacing(4)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // ルーブリック
            if let rubric = feedback.question.rubricJson {
                VStack(alignment: .leading, spacing: 8) {
                    Label("採点観点", systemImage: "list.bullet.clipboard")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.purple)

                    RubricRow(axis: "構造", description: rubric.structure)
                    RubricRow(axis: "論理性", description: rubric.logic)
                    RubricRow(axis: "具体性", description: rubric.specificity)
                }
                .padding(12)
                .background(Color.purple.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Home Button

    private var homeButton: some View {
        Button {
            viewModel.reset()
            navigationPath = NavigationPath()
        } label: {
            HStack {
                Image(systemName: "house.fill")
                Text("ホームに戻る")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.indigo, .purple],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers

    private func rankLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return "優秀なロジカルシンカー"
        case 60..<80:  return "着実に成長中"
        case 40..<60:  return "まだ伸びしろあり"
        default:       return "基礎から積み上げよう"
        }
    }

    private func rankColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80:  return .blue
        case 40..<60:  return .orange
        default:       return .red
        }
    }
}

// MARK: - Sub-components

private struct ScoreChip: View {
    let title: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
            Text("\(score)").font(.title3.bold()).foregroundStyle(color)
            Text("点").font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct RubricRow: View {
    let axis: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(axis)
                .font(.caption.weight(.bold))
                .foregroundStyle(.purple)
                .frame(width: 40, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
    }
}
