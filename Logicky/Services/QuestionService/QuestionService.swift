import Foundation

final class QuestionService {
    static let shared = QuestionService()
    private init() {}

    func loadAll() -> [Question] {
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

    func questions(for unitId: String) -> [Question] {
        loadAll().filter { $0.unit == unitId }
    }

    /// 旧API互換
    func loadQuestions() -> [Question] { loadAll() }
}

private struct QuestionsContainer: Codable {
    let questions: [Question]
}
