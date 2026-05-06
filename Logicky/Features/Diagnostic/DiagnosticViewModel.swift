import Foundation
import SwiftUI

@MainActor
final class DiagnosticViewModel: ObservableObject {

    enum Phase: Equatable { case start, quiz, result }

    @Published private(set) var phase: Phase = .start
    @Published private(set) var questions: [Question] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var selectedAnswers: [String?] = []
    @Published private(set) var lastAnswerCorrect: Bool? = nil
    @Published private(set) var result: DiagnosticResult?
    @Published var profile = DiagnosticProfile()
    @Published private(set) var displayScore: Int = 0

    private let service = DiagnosticService.shared

    // MARK: - Start

    func startDiagnostic() {
        questions = service.selectQuestions()
        selectedAnswers = Array(repeating: nil, count: questions.count)
        currentIndex = 0
        lastAnswerCorrect = nil
        phase = .quiz
    }

    // MARK: - Quiz State

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progressRatio: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var isAnswered: Bool {
        guard currentIndex < selectedAnswers.count else { return false }
        return selectedAnswers[currentIndex] != nil
    }

    func isSelected(_ choiceId: String) -> Bool {
        guard currentIndex < selectedAnswers.count else { return false }
        return selectedAnswers[currentIndex] == choiceId
    }

    func isCorrectChoice(_ choiceId: String) -> Bool {
        currentQuestion?.correctChoiceId == choiceId
    }

    func selectAnswer(_ choiceId: String) {
        guard currentIndex < selectedAnswers.count,
              selectedAnswers[currentIndex] == nil else { return }
        selectedAnswers[currentIndex] = choiceId
        let isCorrect = choiceId == currentQuestion?.correctChoiceId
        lastAnswerCorrect = isCorrect

        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            advance()
        }
    }

    private func advance() {
        lastAnswerCorrect = nil
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            let r = service.buildResult(questions: questions, answers: selectedAnswers)
            result = r
            service.save(r)
            phase = .result
            animateScore(to: r.totalScore)
        }
    }

    // MARK: - Result

    func updateProfile() {
        guard var r = result else { return }
        r.profile = profile
        result = r
        // Re-save with updated profile
        var all = service.allResults
        if let idx = all.firstIndex(where: { $0.id == r.id }) {
            all[idx] = r
            if let data = try? JSONEncoder().encode(all) {
                UserDefaults.standard.set(data, forKey: "logicky_diagnostic_results_v1")
            }
        }
    }

    private func animateScore(to target: Int) {
        displayScore = 0
        guard target > 0 else { return }
        Task {
            for i in 1...target {
                try? await Task.sleep(nanoseconds: 18_000_000)
                displayScore = i
            }
        }
    }

    var previousResult: DiagnosticResult? {
        service.allResults.dropFirst().first
    }

    var scoreDelta: Int? {
        guard let prev = previousResult, let curr = result else { return nil }
        return curr.totalScore - prev.totalScore
    }

    var organizeScoreDelta: Int? {
        guard let prev = previousResult, let curr = result else { return nil }
        return curr.organizeScore - prev.organizeScore
    }

    var reasonScoreDelta: Int? {
        guard let prev = previousResult, let curr = result else { return nil }
        return curr.reasonScore - prev.reasonScore
    }

    var judgeScoreDelta: Int? {
        guard let prev = previousResult, let curr = result else { return nil }
        return curr.judgeScore - prev.judgeScore
    }

    // MARK: - Rank Helpers

    func rankLabel(for score: Int) -> String {
        switch score {
        case 90...100: return "S"
        case 80..<90:  return "A"
        case 70..<80:  return "B+"
        case 60..<70:  return "B"
        case 50..<60:  return "C"
        default:       return "D"
        }
    }

    func rankDescription(for score: Int) -> String {
        switch score {
        case 90...100: return "論理思考のエキスパート"
        case 80..<90:  return "実践レベルの思考力"
        case 70..<80:  return "応用力が身についている"
        case 60..<70:  return "基礎は習得できている"
        case 50..<60:  return "もう少しで基礎レベル"
        default:       return "基礎から鍛え直そう"
        }
    }

    func rankColor(for score: Int) -> Color {
        return .tiffany
    }
}
