import Foundation

final class DiagnosticService {
    static let shared = DiagnosticService()
    private init() {}

    private let storageKey = "logicky_diagnostic_results_v1"

    // organizeScore units
    private let organizeUnits = ["grouping", "comparison", "abstraction", "whole_part", "sequencing"]
    // reasonScore units
    private let reasonUnits   = ["syllogism", "induction", "why_deep", "hypothesis", "analogy"]
    // judgeScore units
    private let judgeUnits    = ["fact_opinion", "pyramid", "so_what", "5w2h"]

    // MARK: - Question Selection (1 per each of 14 basic units)

    private let recentQuestionsKey = "logicky_diagnostic_recent_qids"

    func selectQuestions(advanced: Bool = false) -> [Question] {
        let basicUnitIds = ["grouping", "why_deep", "syllogism", "induction", "analogy",
                            "comparison", "abstraction", "hypothesis", "whole_part", "sequencing",
                            "fact_opinion", "pyramid", "so_what", "5w2h"]
        // 直近2回の診断で使った問題はなるべく避ける（毎回同じ問題になる体感を減らす）
        let recent = Set(UserDefaults.standard.stringArray(forKey: recentQuestionsKey) ?? [])
        let selected = basicUnitIds.compactMap { unitId -> Question? in
            var pool = QuestionService.shared.trainingQuestions(for: unitId)
            if advanced {
                // 上級モードは難問プールから出題
                let hard = pool.filter { $0.isHard }
                if !hard.isEmpty { pool = hard }
            }
            let fresh = pool.filter { !recent.contains($0.id) }
            return (fresh.isEmpty ? pool : fresh).shuffled().first
        }.shuffled()

        // 履歴を更新（直近2回分＝最大28問を保持）
        var history = UserDefaults.standard.stringArray(forKey: recentQuestionsKey) ?? []
        history += selected.map { $0.id }
        if history.count > 28 {
            history = Array(history.suffix(28))
        }
        UserDefaults.standard.set(history, forKey: recentQuestionsKey)

        return selected
    }

    // MARK: - Scoring

    func buildResult(questions: [Question], answers: [String?]) -> DiagnosticResult {
        var organizeCorrect = 0, organizeTotal = 0
        var reasonCorrect = 0,   reasonTotal = 0
        var judgeCorrect = 0,    judgeTotal = 0
        var totalCorrect = 0
        var unitResults: [String: Bool] = [:]

        for (q, answer) in zip(questions, answers) {
            let isCorrect = answer != nil && answer == q.correctChoiceId
            if isCorrect { totalCorrect += 1 }
            if let uid = q.unit {
                unitResults[uid] = isCorrect
                if organizeUnits.contains(uid) {
                    organizeTotal += 1; if isCorrect { organizeCorrect += 1 }
                } else if reasonUnits.contains(uid) {
                    reasonTotal += 1; if isCorrect { reasonCorrect += 1 }
                } else if judgeUnits.contains(uid) {
                    judgeTotal += 1; if isCorrect { judgeCorrect += 1 }
                }
            }
        }

        let pct = { (c: Int, t: Int) -> Int in t == 0 ? 0 : c * 100 / t }

        return DiagnosticResult(
            id: UUID(),
            date: Date(),
            totalScore: questions.isEmpty ? 0 : totalCorrect * 100 / questions.count,
            organizeScore: pct(organizeCorrect, organizeTotal),
            reasonScore:   pct(reasonCorrect, reasonTotal),
            judgeScore:    pct(judgeCorrect, judgeTotal),
            unitResults:   unitResults,
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
