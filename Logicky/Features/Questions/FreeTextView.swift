import SwiftUI

struct FreeTextView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 16) {
                        // 問題カード
                        questionCard(question)

                        // 回答入力欄
                        answerInput

                        // ボトムバー分余白
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .background(Color(.systemGroupedBackground))
                .onTapGesture { isEditorFocused = false }
            }
        }
    }

    private func questionCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("自由記述")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.tiffany.opacity(0.1))
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

    private var answerInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("あなたの回答")
                .font(.subheadline.weight(.semibold))

            ZStack(alignment: .topLeading) {
                if viewModel.currentAnswer.freeText.isEmpty {
                    Text("ここに回答を入力してください...")
                        .font(.body)
                        .foregroundStyle(Color(.placeholderText))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                }

                TextEditor(text: Binding(
                    get: { viewModel.currentAnswer.freeText },
                    set: { viewModel.updateFreeText($0) }
                ))
                .focused($isEditorFocused)
                .frame(minHeight: 160)
                .scrollContentBackground(.hidden)
            }
            .padding(8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isEditorFocused ? Color.tiffany : Color(.separator),
                        lineWidth: isEditorFocused ? 2 : 1
                    )
            )

            HStack {
                Spacer()
                Text("\(viewModel.currentAnswer.freeText.count) 文字")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
