import Foundation

final class DiagnosticService {
    static let shared = DiagnosticService()
    private init() {}

    private let storageKey = "logicky_diagnostic_results_v1"

    // MARK: - Question Selection (10 questions: basic×3, L1×3, L2×2, L3×2, randomized)

    func selectQuestions() -> [Question] {
        let basicUnits = ["grouping", "why_deep", "syllogism", "induction", "analogy",
                          "comparison", "abstraction", "hypothesis", "whole_part", "sequencing",
                          "fact_opinion", "pyramid", "so_what", "5w2h"]
        let l1Units = ["mece", "logic_tree", "matrix"]
        let l2Units = ["3c", "4p", "profit_tree"]
        let l3Units = ["fermi", "causation", "critical", "sanity_check"]

        func pickRandom(_ unitIds: [String], count: Int) -> [Question] {
            let shuffled = unitIds.shuffled()
            var picked: [Question] = []
            for unitId in shuffled {
                guard picked.count < count else { break }
                let qs = QuestionService.shared.trainingQuestions(for: unitId).shuffled()
                if let q = qs.first { picked.append(q) }
            }
            return picked
        }

        let basic = pickRandom(basicUnits, count: 3)
        let l1 = pickRandom(l1Units, count: 3)
        let l2 = pickRandom(l2Units, count: 2)
        let l3 = pickRandom(l3Units, count: 2)

        return (basic + l1 + l2 + l3).shuffled()
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
        if all.count > 20 { all = Array(all.prefix(20)) }
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
