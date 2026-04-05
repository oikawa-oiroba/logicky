import SwiftUI

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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct MainNavigationView: View {
    @StateObject private var quizViewModel = QuizViewModel()
    @StateObject private var attemptService = AttemptService.shared
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .quiz(let unitId):
                        QuizContainerView(unitId: unitId, navigationPath: $navigationPath)
                    case .result:
                        ResultView(navigationPath: $navigationPath)
                    case .history:
                        HistoryView(navigationPath: $navigationPath)
                    }
                }
        }
        .environmentObject(quizViewModel)
        .environmentObject(attemptService)
    }
}

enum AppRoute: Hashable {
    case quiz(unitId: String)
    case result
    case history
}
