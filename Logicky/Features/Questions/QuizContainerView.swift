import SwiftUI

struct QuizContainerView: View {
    let unitId: String
    let mode: QuizMode
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var showExitConfirmation = false

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ZStack(alignment: .bottom) {
                    switch question.type {
                    case .multipleChoice:
                        MultipleChoiceView()
                    case .freeText:
                        FreeTextView()
                    }

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
                    .foregroundStyle(Color.tiffany)
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
                .foregroundStyle(Color.appSub)
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
            viewModel.startQuiz(unitId: unitId, mode: mode)
        }
    }

    private var unitNameLabel: some View {
        VStack(spacing: 1) {
            Text(UnitModel.all.first { $0.id == unitId }?.displayName ?? "")
                .font(.headline)
                .foregroundStyle(Color.appText)
            Text(mode == .training ? "トレーニング" : "マスター")
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
    }

    private var bottomProgressBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.cardBorder)
            HStack(spacing: 12) {
                Button {
                    viewModel.goPrevious()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(viewModel.isFirstQuestion ? Color.cardBorder : Color.tiffany)
                }
                .disabled(viewModel.isFirstQuestion)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<viewModel.questions.count, id: \.self) { i in
                        Circle()
                            .fill(i == viewModel.currentIndex ? Color.tiffany : Color.cardBorder)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(viewModel.progressText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appSub)
                    .frame(width: 40, alignment: .center)

                Spacer()

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
                    .background(canAdvance ? Color.tiffany : Color.cardBorder)
                    .clipShape(Capsule())
                }
                .disabled(!canAdvance)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }

    private var canAdvance: Bool {
        viewModel.currentAnswer.hasAnswer
    }
}
