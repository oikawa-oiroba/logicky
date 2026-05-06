import Foundation
import Combine

@MainActor
final class QuizViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var questions: [Question] = []
    @Published private(set) var currentIndex: Int = 0
    @Published var sessionAnswers: [SessionAnswer] = []
    @Published private(set) var isCompleted: Bool = false
    @Published private(set) var quizResult: QuizResult?
    @Published private(set) var unitId: String = ""
    @Published private(set) var mode: QuizMode = .training

    // MARK: - Computed

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var currentAnswer: SessionAnswer {
        get {
            guard currentIndex < sessionAnswers.count else { return SessionAnswer() }
            return sessionAnswers[currentIndex]
        }
        set {
            guard currentIndex < sessionAnswers.count else { return }
            sessionAnswers[currentIndex] = newValue
        }
    }

    var isFirstQuestion: Bool { currentIndex == 0 }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }
    var progressText: String { "\(currentIndex + 1) / \(questions.count)" }
    var progressRatio: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }

    // MARK: - Session Management

    func startQuiz(unitId: String, mode: QuizMode = .training) {
        self.unitId = unitId
        self.mode = mode
        let all = QuestionService.shared.questions(for: unitId)
        switch mode {
        case .training:
            let mcQuestions = all.filter { $0.type == .multipleChoice }
            self.questions = Self.selectTrainingQuestions(mcQuestions, unitId: unitId)
        case .master:
            self.questions = all.filter { $0.type == .freeText }
        }
        self.sessionAnswers = Array(repeating: SessionAnswer(), count: questions.count)
        self.currentIndex = 0
        self.isCompleted = false
        self.quizResult = nil
    }

    private static func selectTrainingQuestions(_ all: [Question], unitId: String) -> [Question] {
        let sessionSize = 5
        let mcIds = Set(all.map { $0.id })
        let answeredIds = AttemptService.shared.answeredMCQuestionIds(for: unitId, mcIds: mcIds)
        let unanswered = all.filter { !answeredIds.contains($0.id) }
        if unanswered.count >= sessionSize {
            return Array(unanswered.shuffled().prefix(sessionSize))
        }
        let answered = all.filter { answeredIds.contains($0.id) }
        let needed = sessionSize - unanswered.count
        let fill = Array(answered.shuffled().prefix(needed))
        return (unanswered + fill).shuffled()
    }

    func reset() {
        questions = []
        sessionAnswers = []
        currentIndex = 0
        isCompleted = false
        quizResult = nil
        unitId = ""
        mode = .training
    }

    // MARK: - Answer Input

    func selectChoice(_ choiceId: String) {
        guard currentIndex < sessionAnswers.count else { return }
        sessionAnswers[currentIndex].selectedChoiceId = choiceId
        sessionAnswers[currentIndex].isSkipped = false
    }

    func updateFreeText(_ text: String) {
        guard currentIndex < sessionAnswers.count else { return }
        sessionAnswers[currentIndex].freeText = text
        sessionAnswers[currentIndex].isSkipped = false
    }

    // MARK: - Navigation

    func goNext() {
        if isLastQuestion {
            finishQuiz()
        } else {
            currentIndex += 1
        }
    }

    func goPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func skip() {
        guard currentIndex < sessionAnswers.count else { return }
        sessionAnswers[currentIndex].isSkipped = true
        sessionAnswers[currentIndex].selectedChoiceId = nil
        sessionAnswers[currentIndex].freeText = ""
        if isLastQuestion {
            finishQuiz()
        } else {
            currentIndex += 1
        }
    }

    // MARK: - Completion

    private func finishQuiz() {
        let result = ScoringService.shared.buildResult(
            unitId: unitId,
            questions: questions,
            sessionAnswers: sessionAnswers
        )
        quizResult = result

        let attemptResults = zip(questions, sessionAnswers).map { question, answer in
            QuestionAttemptResult(
                id: UUID(),
                questionId: question.id,
                isSkipped: answer.isSkipped,
                selectedChoiceId: answer.selectedChoiceId,
                isCorrect: question.type == .multipleChoice
                    ? (!answer.isSkipped ? answer.selectedChoiceId == question.correctChoiceId : nil)
                    : nil,
                freeText: answer.freeText.isEmpty ? nil : answer.freeText,
                score: ScoringService.shared.score(answer: answer, question: question)
            )
        }

        let attempt = QuizAttempt(
            id: UUID(),
            unitId: unitId,
            date: Date(),
            questionResults: Array(attemptResults),
            totalScore: result.totalScore
        )
        AttemptService.shared.save(attempt)

        isCompleted = true
    }
}
