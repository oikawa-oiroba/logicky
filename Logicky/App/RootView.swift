import SwiftUI

enum QuizMode: String, Hashable {
    case training
    case master
}

enum AppRoute: Hashable {
    case categorySelection
    case levelSelection
    case unitSelection(levelId: Int)
    case unitDetail(unitId: String, levelId: Int)
    case quiz(unitId: String, mode: QuizMode)
    case result
    case review
    case history
    case dictionaryList
    case dictionaryDetail(methodId: String)
    case cognitiveBiasList
    case cognitiveBiasDetail(biasId: String)
    case diagnosticDetail(result: DiagnosticResult)
}

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
                    case .categorySelection:
                        CategorySelectionView(navigationPath: $navigationPath)
                    case .levelSelection:
                        LevelSelectionView(navigationPath: $navigationPath)
                    case .unitSelection(let levelId):
                        UnitSelectionView(levelId: levelId, navigationPath: $navigationPath)
                    case .unitDetail(let unitId, let levelId):
                        UnitDetailView(unitId: unitId, levelId: levelId, navigationPath: $navigationPath)
                    case .quiz(let unitId, let mode):
                        QuizContainerView(unitId: unitId, mode: mode, navigationPath: $navigationPath)
                    case .result:
                        ResultView(navigationPath: $navigationPath)
                    case .review:
                        ResultReviewView(navigationPath: $navigationPath)
                    case .history:
                        HistoryView(navigationPath: $navigationPath)
                    case .dictionaryList:
                        DictionaryListView(navigationPath: $navigationPath)
                    case .dictionaryDetail(let methodId):
                        DictionaryDetailView(methodId: methodId, navigationPath: $navigationPath)
                    case .cognitiveBiasList:
                        CognitiveBiasListView(navigationPath: $navigationPath)
                    case .cognitiveBiasDetail(let biasId):
                        CognitiveBiasDetailView(biasId: biasId, navigationPath: $navigationPath)
                    case .diagnosticDetail(let result):
                        DiagnosticHistoryDetailView(result: result, navigationPath: $navigationPath)
                    }
                }
        }
        .environmentObject(quizViewModel)
        .environmentObject(attemptService)
    }
}
