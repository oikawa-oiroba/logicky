import SwiftUI

/// 自由記述問題画面
struct FreeTextView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 20) {
                        // 進捗バー
                        progressBar

                        // 問題カード
                        questionCard(question)

                        // 回答入力欄
                        answerInputSection

                        // 送信ボタン
                        submitButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("問題 \(viewModel.progressText)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .onTapGesture {
                    isTextEditorFocused = false
                }
            }
        }
    }

    // MARK: - Subviews

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Level \(viewModel.currentQuestion?.level ?? 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.purple.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text("自由記述")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: viewModel.progressRatio)
                .tint(.purple)
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

    private var answerInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("あなたの回答")
                .font(.subheadline.weight(.semibold))

            ZStack(alignment: .topLeading) {
                // プレースホルダー
                if viewModel.freeTextInput.isEmpty {
                    Text("原因と対策を自由に記述してください...")
                        .font(.body)
                        .foregroundStyle(Color(.placeholderText))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                }

                TextEditor(text: $viewModel.freeTextInput)
                    .focused($isTextEditorFocused)
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
            }
            .padding(8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isTextEditorFocused ? Color.purple : Color(.separator),
                        lineWidth: isTextEditorFocused ? 2 : 1
                    )
            )

            // 文字数カウンター
            HStack {
                Spacer()
                Text("\(viewModel.freeTextInput.count) 文字")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var submitButton: some View {
        Button {
            isTextEditorFocused = false
            viewModel.submitFreeText()
            // navigationへの遷移はQuizContainerViewのonChangeで処理
        } label: {
            Text(viewModel.isLastQuestion ? "結果を見る" : "回答して次へ")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.freeTextInput.isEmpty
                        ? Color.gray
                        : Color.purple
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.freeTextInput.isEmpty)
    }
}
