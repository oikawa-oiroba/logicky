import Foundation

struct QuizAttempt: Identifiable, Codable {
    let id: UUID
    let unitId: String
    let date: Date
    let questionResults: [QuestionAttemptResult]
    let totalScore: Int
}

struct QuestionAttemptResult: Identifiable, Codable {
    let id: UUID
    let questionId: String
    let isSkipped: Bool
    let selectedChoiceId: String?
    let isCorrect: Bool?
    let freeText: String?
    let score: Int
}
