import Foundation
import Combine

/// クイズ全体の状態を管理するViewModel
final class QuizViewModel: ObservableObject {
    /// 読み込まれた問題一覧
    @Published var questions: [Question] = []
    /// 現在の問題インデックス
    @Published var currentQuestionIndex: Int = 0
    /// ユーザーの回答履歴
    @Published private(set) var answers: [Answer] = []
    /// 選択中の選択肢ID（4択）
    @Published var selectedChoiceId: String? = nil
    /// 自由記述テキスト
    @Published var freeTextInput: String = ""
    /// 回答が公開されているか（4択の正解表示）
    @Published var isAnswerRevealed: Bool = false
    /// 計算済み結果（全問回答後に確定）
    @Published private(set) var quizResult: QuizResult? = nil

    /// 現在の問題。インデックスが範囲外なら nil
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    /// 全問題に回答済みかどうか
    var isAllAnswered: Bool {
        !questions.isEmpty && currentQuestionIndex >= questions.count
    }

    /// 現在が最後の問題かどうか
    var isLastQuestion: Bool {
        guard !questions.isEmpty else { return false }
        return currentQuestionIndex == questions.count - 1
    }

    /// 進捗テキスト（例: "1 / 3"）
    var progressText: String {
        "\(min(currentQuestionIndex + 1, questions.count)) / \(questions.count)"
    }

    /// 進捗率（0.0〜1.0）
    var progressRatio: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    // MARK: - Public Methods

    /// JSONから問題を読み込む
    func loadQuestions() {
        questions = QuestionService.shared.loadQuestions()
    }

    /// 4択で選択肢を選ぶ（回答公開状態にする）
    func selectChoice(_ choiceId: String) {
        guard !isAnswerRevealed else { return }
        selectedChoiceId = choiceId
        isAnswerRevealed = true
    }

    /// 4択の回答を保存して次の問題へ進む
    func submitMultipleChoice() {
        guard let question = currentQuestion,
              let choiceId = selectedChoiceId else { return }
        let isCorrect = choiceId == question.correctChoiceId
        let answer = Answer(
            questionId: question.id,
            selectedChoiceId: choiceId,
            freeText: nil,
            isCorrect: isCorrect
        )
        answers.append(answer)
        advanceToNextQuestion()
    }

    /// 自由記述の回答を保存して次の問題へ進む
    func submitFreeText() {
        guard let question = currentQuestion else { return }
        let answer = Answer(
            questionId: question.id,
            selectedChoiceId: nil,
            freeText: freeTextInput.isEmpty ? nil : freeTextInput,
            isCorrect: nil
        )
        answers.append(answer)
        advanceToNextQuestion()
    }

    /// クイズをリセットする
    func reset() {
        currentQuestionIndex = 0
        answers = []
        selectedChoiceId = nil
        freeTextInput = ""
        isAnswerRevealed = false
        quizResult = nil
    }

    // MARK: - Private

    private func advanceToNextQuestion() {
        currentQuestionIndex += 1
        selectedChoiceId = nil
        freeTextInput = ""
        isAnswerRevealed = false

        // 全問回答済みなら結果を確定
        if isAllAnswered {
            computeAndStoreResult()
        }
    }

    private func computeAndStoreResult() {
        let correctCount = answers.filter { $0.isCorrect == true }.count
        let totalMC = answers.filter { $0.isCorrect != nil }.count
        let score = totalMC > 0 ? Int((Double(correctCount) / Double(totalMC)) * 100) : 50

        // 正答率をベースに3軸スコアを算出（仮実装）
        quizResult = QuizResult(
            totalScore: score,
            structureScore: min(100, max(0, score + Int.random(in: -10...10))),
            logicScore: min(100, max(0, score + Int.random(in: -10...10))),
            specificityScore: min(100, max(0, score + Int.random(in: -10...10))),
            answers: answers
        )
    }
}
