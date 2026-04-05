import SwiftUI

/// 現在の問題タイプに応じて適切な問題画面を表示するコンテナ
struct QuizContainerView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                switch question.type {
                case .multipleChoice:
                    MultipleChoiceView(navigationPath: $navigationPath)
                case .freeText:
                    FreeTextView(navigationPath: $navigationPath)
                }
            } else {
                // 全問回答済み: onChangeで結果画面へ遷移するため空ビューを表示
                Color.clear
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isAllAnswered) { _, isAnswered in
            if isAnswered {
                navigationPath.append(AppRoute.result)
            }
        }
    }
}
