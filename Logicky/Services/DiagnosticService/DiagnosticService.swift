import Foundation

final class DiagnosticService {
    static let shared = DiagnosticService()
    private init() {}

    private let storageKey = "logicky_diagnostic_results_v1"

    // MARK: - Question Selection (10 questions: L1×3, L2×4, L3×3)

    func selectQuestions() -> [Question] {
        var selected: [Question] = []

        let l1Units = ["mece", "deduction", "fact_opinion"]
        let l2Units = ["logic_tree", "3c", "5w2h"]
        let l3Units = ["fermi", "causality", "critical"]

        for unitId in l1Units {
            if let q = QuestionService.shared.trainingQuestions(for: unitId).first {
                selected.append(q)
            }
        }
        for unitId in l2Units {
            if let q = QuestionService.shared.trainingQuestions(for: unitId).first {
                selected.append(q)
            }
        }
        // 1 extra Level2 question (second MC from any Level2 unit)
        for unitId in l2Units {
            let qs = QuestionService.shared.trainingQuestions(for: unitId)
            if qs.count > 1 {
                selected.append(qs[1])
                break
            }
        }
        for unitId in l3Units {
            if let q = QuestionService.shared.trainingQuestions(for: unitId).first {
                selected.append(q)
            }
        }

        return selected
    }

    // MARK: - Scoring

    func buildResult(questions: [Question], answers: [String?]) -> DiagnosticResult {
        var l1Correct = 0, l1Total = 0
        var l2Correct = 0, l2Total = 0
        var l3Correct = 0, l3Total = 0
        var totalCorrect = 0

        for (q, answer) in zip(questions, answers) {
            let isCorrect = answer != nil && answer == q.correctChoiceId
            if isCorrect { totalCorrect += 1 }
            switch q.level {
            case 1: l1Total += 1; if isCorrect { l1Correct += 1 }
            case 2: l2Total += 1; if isCorrect { l2Correct += 1 }
            case 3: l3Total += 1; if isCorrect { l3Correct += 1 }
            default: break
            }
        }

        let pct = { (c: Int, t: Int) -> Int in t == 0 ? 0 : c * 100 / t }

        return DiagnosticResult(
            id: UUID(),
            date: Date(),
            totalScore: questions.isEmpty ? 0 : totalCorrect * 100 / questions.count,
            organizeScore: pct(l1Correct, l1Total),
            reasonScore: pct(l2Correct, l2Total),
            judgeScore: pct(l3Correct, l3Total),
            profile: DiagnosticProfile()
        )
    }

    // MARK: - Persistence

    var allResults: [DiagnosticResult] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let results = try? JSONDecoder().decode([DiagnosticResult].self, from: data)
        else { return [] }
        return results.sorted { $0.date > $1.date }
    }

    var latestResult: DiagnosticResult? { allResults.first }

    func save(_ result: DiagnosticResult) {
        var all = allResults
        all.insert(result, at: 0)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
