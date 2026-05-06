import SwiftUI

struct ResultReviewView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(reviewItems.enumerated()), id: \.offset) { index, item in
                        reviewCard(index: index + 1, item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))

            bottomBar
        }
        .navigationTitle("回答を振り返る")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Review Items

    private struct ReviewItem {
        let question: Question
        let selectedChoiceId: String?
        let isCorrect: Bool?
        let isSkipped: Bool
    }

    private var reviewItems: [ReviewItem] {
        guard viewModel.questions.count == viewModel.sessionAnswers.count else { return [] }
        return zip(viewModel.questions, viewModel.sessionAnswers).map { q, a in
            let isCorrect: Bool? = q.type == .multipleChoice && !a.isSkipped
                ? a.selectedChoiceId == q.correctChoiceId
                : nil
            return ReviewItem(
                question: q,
                selectedChoiceId: a.selectedChoiceId,
                isCorrect: isCorrect,
                isSkipped: a.isSkipped
            )
        }
    }

    // MARK: - Review Card

    private func reviewCard(index: Int, item: ReviewItem) -> some View {
        let correct = item.isCorrect == true
        let borderColor: Color = item.isSkipped ? .secondary : (correct ? .green : .orange)

        return VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack(spacing: 8) {
                Text("Q\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(borderColor)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                Text(item.question.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if item.isSkipped {
                    Text("スキップ")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemFill))
                        .clipShape(Capsule())
                } else if let isCorrect = item.isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? .green : .orange)
                }
            }

            // Selected answer
            if let choiceId = item.selectedChoiceId,
               let choice = item.question.choices?.first(where: { $0.id == choiceId }) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("あなたの回答")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(choice.text)
                        .font(.subheadline)
                        .foregroundStyle(item.isCorrect == true ? .green : .orange)
                }
            }

            // Correct answer (show when wrong or skipped)
            if item.isCorrect == false || item.isSkipped,
               let correctId = item.question.correctChoiceId,
               let correct = item.question.choices?.first(where: { $0.id == correctId }) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("正解")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                    Text(correct.text)
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }

            // Explanation
            if let explanation = item.question.explanation {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                    Text(explanation)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 9))
            }

            // Thinking method badge
            if let unitId = item.question.unit,
               let method = ThinkingMethodService.shared.all.first(where: { $0.unitId == unitId }) {
                Button {
                    navigationPath.append(AppRoute.dictionaryDetail(methodId: method.id))
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: method.icon)
                            .font(.caption)
                        Text(method.name)
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(borderColor.opacity(0.4), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(borderColor)
                .frame(width: 4)
                .padding(.vertical, 4)
                .offset(x: -1)
        }
        .clipped()
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if let unitId = viewModel.unitId.isEmpty ? nil : viewModel.unitId,
               let method = ThinkingMethodService.shared.all.first(where: { $0.unitId == unitId }) {
                Button {
                    navigationPath.append(AppRoute.dictionaryDetail(methodId: method.id))
                } label: {
                    HStack(spacing: 6) {
                        Text("📖")
                        Text("この単元を学ぶ")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.indigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Button {
                let unitId = viewModel.unitId
                let mode = viewModel.mode
                viewModel.reset()
                navigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    navigationPath.append(AppRoute.quiz(unitId: unitId, mode: mode))
                }
            } label: {
                HStack(spacing: 6) {
                    Text("🔄")
                    Text("もう1回解く")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.indigo, .purple],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}
