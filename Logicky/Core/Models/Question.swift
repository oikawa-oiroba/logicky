import Foundation

enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case freeText = "free_text"
}

struct Choice: Codable, Identifiable {
    let id: String
    let text: String
}

struct RubricItem: Codable {
    let structure: String
    let logic: String
    let specificity: String
}

struct Question: Codable, Identifiable {
    let id: String
    let type: QuestionType
    let level: Int
    let unit: String?
    let title: String
    let body: String
    let choices: [Choice]?
    let correctChoiceId: String?
    let explanation: String?
    let tags: [String]?
    let abilityAxis: String?
    let rubricJson: RubricItem?
    let sampleGoodAnswer: String?
    let sampleGoodPoints: [String]?
}
