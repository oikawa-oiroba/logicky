import Foundation

struct SessionAnswer {
    var selectedChoiceId: String?
    var freeText: String = ""
    var isSkipped: Bool = false

    var hasAnswer: Bool {
        selectedChoiceId != nil || !freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct FreeTextScoreDetail {
    let structureScore: Int   // 1-5
    let logicScore: Int       // 1-5
    let specificityScore: Int // 1-5
    let normalizedScore: Int  // 0-100
    let strengths: [String]
    let weaknesses: [String]
    let advice: String
}

struct QuestionFeedback {
    let question: Question
    let answer: SessionAnswer
    let isCorrect: Bool?
    let score: Int
    var freeTextDetail: FreeTextScoreDetail?
}

struct QuizResult {
    let unitId: String
    let totalScore: Int
    let structureScore: Int
    let logicScore: Int
    let specificityScore: Int
    let feedbacks: [QuestionFeedback]
}
