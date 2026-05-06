import Foundation

final class QuestionService {
    static let shared = QuestionService()
    private init() {}

    private lazy var _all: [Question] = {
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
    }()

    func loadAll() -> [Question] { _all }

    func questions(for unitId: String) -> [Question] {
        _all.filter { $0.unit == unitId }
    }

    func trainingQuestions(for unitId: String) -> [Question] {
        questions(for: unitId).filter { $0.type == .multipleChoice }
    }

    func masterQuestions(for unitId: String) -> [Question] {
        questions(for: unitId).filter { $0.type == .freeText }
    }

    /// 旧API互換
    func loadQuestions() -> [Question] { loadAll() }
}

private struct QuestionsContainer: Codable {
    let questions: [Question]
}
