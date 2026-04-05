import SwiftUI

/// アプリのルートビュー。スプラッシュ→メイン画面への遷移を管理する。
struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                MainNavigationView()
            }
        }
        .onAppear {
            // 2秒後にスプラッシュからホーム画面へ遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

/// NavigationStackとQuizViewModelを保持するメインビュー
struct MainNavigationView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .quiz:
                        QuizContainerView(navigationPath: $navigationPath)
                    case .result:
                        ResultView(navigationPath: $navigationPath)
                    }
                }
        }
        .environmentObject(viewModel)
    }
}

/// アプリ内のナビゲーションルート定義
enum AppRoute: Hashable {
    case quiz
    case result
}
