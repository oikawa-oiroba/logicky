import SwiftUI

/// 4択問題画面
struct MultipleChoiceView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 20) {
                        // 進捗バー
                        progressBar

                        // 問題カード
                        questionCard(question)

                        // 選択肢一覧
                        choicesList(question)

                        // 解説 + 次へボタン（回答後に表示）
                        if viewModel.isAnswerRevealed {
                            explanationAndNextButton(question)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("問題 \(viewModel.progressText)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Subviews

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Level \(viewModel.currentQuestion?.level ?? 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text("4択問題")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: viewModel.progressRatio)
                .tint(.indigo)
        }
    }

    private func questionCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(question.body)
                .font(.body)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func choicesList(_ question: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(question.choices ?? []) { choice in
                ChoiceButton(
                    choice: choice,
                    selectedChoiceId: viewModel.selectedChoiceId,
                    correctChoiceId: question.correctChoiceId,
                    isRevealed: viewModel.isAnswerRevealed
                ) {
                    viewModel.selectChoice(choice.id)
                }
            }
        }
    }

    private func explanationAndNextButton(_ question: Question) -> some View {
        VStack(spacing: 14) {
            // 正解/不正解バナー
            let isCorrect = viewModel.selectedChoiceId == question.correctChoiceId
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                Text(isCorrect ? "正解！" : "不正解")
                    .font(.headline)
            }
            .foregroundStyle(isCorrect ? .green : .red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background((isCorrect ? Color.green : Color.red).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 解説
            if let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    Label("解説", systemImage: "lightbulb.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)

                    Text(explanation)
                        .font(.subheadline)
                        .lineSpacing(5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 次へボタン
            Button {
                viewModel.submitMultipleChoice()
            } label: {
                Text(viewModel.isLastQuestion ? "結果を見る" : "次の問題へ")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

/// 選択肢ボタン
private struct ChoiceButton: View {
    let choice: Choice
    let selectedChoiceId: String?
    let correctChoiceId: String?
    let isRevealed: Bool
    let action: () -> Void

    private var isSelected: Bool { selectedChoiceId == choice.id }
    private var isCorrect: Bool { correctChoiceId == choice.id }

    private var backgroundColor: Color {
        guard isRevealed else {
            return isSelected ? Color.indigo.opacity(0.12) : Color(.systemBackground)
        }
        if isCorrect { return Color.green.opacity(0.12) }
        if isSelected { return Color.red.opacity(0.12) }
        return Color(.systemBackground)
    }

    private var borderColor: Color {
        guard isRevealed else {
            return isSelected ? .indigo : Color(.separator)
        }
        if isCorrect { return .green }
        if isSelected { return .red }
        return Color(.separator)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(choice.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)

                Spacer()

                if isRevealed {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isRevealed)
    }
}
