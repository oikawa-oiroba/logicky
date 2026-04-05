import Foundation

/// 問題データを提供するサービス（シングルトン）
final class QuestionService {
    static let shared = QuestionService()
    private init() {}

    /// questions.json から問題を読み込んで返す
    func loadQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("⚠️ questions.json が見つかりません")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder().decode(QuestionsContainer.self, from: data)
            return container.questions
        } catch {
            print("⚠️ questions.json のデコードに失敗: \(error)")
            return []
        }
    }
}

/// JSONのトップレベルコンテナ
private struct QuestionsContainer: Codable {
    let questions: [Question]
}
