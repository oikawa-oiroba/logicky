import SwiftUI

struct QuizContainerView: View {
    let unitId: String
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var showExitConfirmation = false

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ZStack(alignment: .bottom) {
                    // 問題ビュー
                    switch question.type {
                    case .multipleChoice:
                        MultipleChoiceView()
                    case .freeText:
                        FreeTextView()
                    }

                    // 画面下部プログレスバー
                    bottomProgressBar
                }
            } else {
                Color.clear
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showExitConfirmation = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                    .font(.subheadline)
                }
            }

            ToolbarItem(placement: .principal) {
                unitNameLabel
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("スキップ") {
                    viewModel.skip()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .confirmationDialog(
            "ホームに戻りますか？",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("戻る", role: .destructive) {
                viewModel.reset()
                navigationPath = NavigationPath()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("進捗が失われますが戻りますか？")
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                navigationPath.append(AppRoute.result)
            }
        }
        .onAppear {
            viewModel.startQuiz(unitId: unitId)
        }
    }

    private var unitNameLabel: some View {
        Text(UnitModel.all.first { $0.id == unitId }?.name ?? "")
            .font(.headline)
    }

    private var bottomProgressBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                // 前へ ボタン
                Button {
                    viewModel.goPrevious()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(viewModel.isFirstQuestion ? Color(.tertiaryLabel) : .indigo)
                }
                .disabled(viewModel.isFirstQuestion)

                Spacer()

                // ページ表示
                HStack(spacing: 6) {
                    ForEach(0..<viewModel.questions.count, id: \.self) { i in
                        Circle()
                            .fill(i == viewModel.currentIndex ? Color.indigo : Color(.systemFill))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(viewModel.progressText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .center)

                Spacer()

                // 次へ / 完了 ボタン
                Button {
                    viewModel.goNext()
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.isLastQuestion ? "完了" : "次へ")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: viewModel.isLastQuestion ? "checkmark" : "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(canAdvance ? Color.indigo : Color(.systemFill))
                    .clipShape(Capsule())
                }
                .disabled(!canAdvance)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }

    private var canAdvance: Bool {
        viewModel.currentAnswer.hasAnswer
    }
}
