import Foundation

struct SessionAnswer {
    var selectedChoiceId: String?
    var freeText: String = ""
    var isSkipped: Bool = false

    var hasAnswer: Bool {
        selectedChoiceId != nil || !freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct QuestionFeedback {
    let question: Question
    let answer: SessionAnswer
    let isCorrect: Bool?
    let score: Int
}

struct QuizResult {
    let unitId: String
    let totalScore: Int
    let structureScore: Int
    let logicScore: Int
    let specificityScore: Int
    let feedbacks: [QuestionFeedback]
}
