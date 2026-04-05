import SwiftUI

struct MultipleChoiceView: View {
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 16) {
                        // 問題カード
                        questionCard(question)

                        // 選択肢
                        choicesList(question)

                        // 次へボタン用の余白（下部バー分）
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    private func questionCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("4択問題")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
            }

            Text(question.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(question.body)
                .font(.body)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func choicesList(_ question: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(question.choices ?? []) { choice in
                ChoiceButton(
                    choice: choice,
                    isSelected: viewModel.currentAnswer.selectedChoiceId == choice.id
                ) {
                    viewModel.selectChoice(choice.id)
                }
            }
        }
    }
}

private struct ChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.indigo : Color(.separator), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(choice.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(14)
            .background(
                isSelected ? Color.indigo.opacity(0.08) : Color(.systemBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo : Color(.separator), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
