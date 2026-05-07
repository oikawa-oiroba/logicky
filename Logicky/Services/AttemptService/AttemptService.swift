import Foundation
import Combine

final class AttemptService: ObservableObject {
    static let shared = AttemptService()

    private let storageKey = "logicky_quiz_attempts_v1"
    @Published private(set) var attempts: [QuizAttempt] = []

    private init() { load() }

    // MARK: - Write

    func save(_ attempt: QuizAttempt) {
        attempts.append(attempt)
        persist()
    }

    // MARK: - Read

    func attempts(for unitId: String) -> [QuizAttempt] {
        attempts.filter { $0.unitId == unitId }
    }

    func isUnitCompleted(_ unitId: String) -> Bool {
        !attempts(for: unitId).isEmpty
    }

    func answeredCount(for unitId: String) -> Int {
        guard let latest = attempts(for: unitId)
            .sorted(by: { $0.date > $1.date }).first else { return 0 }
        return latest.questionResults.filter { !$0.isSkipped }.count
    }

    func answeredMCQuestionIds(for unitId: String, mcIds: Set<String>) -> Set<String> {
        let allResults = attempts(for: unitId).flatMap { $0.questionResults }
        return Set(allResults.filter { !$0.isSkipped && mcIds.contains($0.questionId) }.map { $0.questionId })
    }

    func mcCorrectRate(for unitId: String, mcIds: Set<String>) -> Double? {
        let allResults = attempts(for: unitId)
            .sorted { $0.date < $1.date }
            .flatMap { $0.questionResults }
            .filter { !$0.isSkipped && mcIds.contains($0.questionId) && $0.isCorrect != nil }
        let recent = Array(allResults.suffix(10))
        guard !recent.isEmpty else { return nil }
        let correct = recent.filter { $0.isCorrect == true }.count
        return Double(correct) / Double(recent.count)
    }

    var totalAnsweredCount: Int {
        attempts.reduce(0) { $0 + $1.questionResults.filter { !$0.isSkipped }.count }
    }

    var todayScore: Int? {
        let today = attempts.filter { Calendar.current.isDateInToday($0.date) }
        guard !today.isEmpty else { return nil }
        return today.map { $0.totalScore }.reduce(0, +) / today.count
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([QuizAttempt].self, from: data)
        else { return }
        attempts = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(attempts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
