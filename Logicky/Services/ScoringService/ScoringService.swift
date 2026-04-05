import Foundation

final class ScoringService {
    static let shared = ScoringService()
    private init() {}

    func score(answer: SessionAnswer, question: Question) -> Int {
        guard !answer.isSkipped else { return 0 }
        switch question.type {
        case .multipleChoice:
            guard let selected = answer.selectedChoiceId,
                  let correct = question.correctChoiceId else { return 0 }
            return selected == correct ? 100 : 0
        case .freeText:
            return answer.freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 70
        }
    }

    func buildResult(
        unitId: String,
        questions: [Question],
        sessionAnswers: [SessionAnswer]
    ) -> QuizResult {
        let feedbacks: [QuestionFeedback] = zip(questions, sessionAnswers).map { question, answer in
            let s = score(answer: answer, question: question)
            let correct: Bool? = question.type == .multipleChoice
                ? (!answer.isSkipped ? answer.selectedChoiceId == question.correctChoiceId : nil)
                : nil
            return QuestionFeedback(question: question, answer: answer, isCorrect: correct, score: s)
        }

        let scores = feedbacks.map { $0.score }
        let total = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count

        // 3軸スコア: abilityAxisで振り分け、なければtotalを使用
        let structureScore = axisScore(feedbacks: feedbacks, axis: "構造化", fallback: total)
        let logicScore     = axisScore(feedbacks: feedbacks, axis: "因果理解", fallback: total)
        let specificityScore = axisScore(feedbacks: feedbacks, axis: "具体性", fallback: total)

        return QuizResult(
            unitId: unitId,
            totalScore: total,
            structureScore: structureScore,
            logicScore: logicScore,
            specificityScore: specificityScore,
            feedbacks: feedbacks
        )
    }

    private func axisScore(feedbacks: [QuestionFeedback], axis: String, fallback: Int) -> Int {
        let matching = feedbacks.filter { $0.question.abilityAxis == axis }
        guard !matching.isEmpty else { return fallback }
        return matching.map { $0.score }.reduce(0, +) / matching.count
    }
}
