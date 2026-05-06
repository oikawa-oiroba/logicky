import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var levels: [LevelModel] = LevelModel.all
    private let attemptService: AttemptService

    private var cancellables = Set<AnyCancellable>()

    init(attemptService: AttemptService = .shared) {
        self.attemptService = attemptService
        attemptService.$attempts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Training Progress (MC only)

    func mcAnsweredCount(for unit: UnitModel) -> Int {
        let mcIds = Set(QuestionService.shared.questions(for: unit.id)
            .filter { $0.type == .multipleChoice }
            .map { $0.id })
        for attempt in attemptService.attempts(for: unit.id).sorted(by: { $0.date > $1.date }) {
            let answered = attempt.questionResults.filter { !$0.isSkipped && mcIds.contains($0.questionId) }
            if !answered.isEmpty { return answered.count }
        }
        return 0
    }

    func isMCCompleted(for unit: UnitModel) -> Bool {
        let mcQuestions = QuestionService.shared.questions(for: unit.id).filter { $0.type == .multipleChoice }
        guard !mcQuestions.isEmpty else { return false }
        let mcIds = Set(mcQuestions.map { $0.id })
        return attemptService.attempts(for: unit.id).contains { attempt in
            let answeredIds = Set(attempt.questionResults
                .filter { !$0.isSkipped && mcIds.contains($0.questionId) }
                .map { $0.questionId })
            return answeredIds.count >= mcQuestions.count
        }
    }

    func hasMasterMode(for unit: UnitModel) -> Bool {
        !QuestionService.shared.questions(for: unit.id).filter { $0.type == .freeText }.isEmpty
    }

    // MARK: - Level Unlock (MC completion only)

    func isLevelUnlocked(_ level: LevelModel) -> Bool {
        if level.id == 1 { return true }
        guard let prev = LevelModel.all.first(where: { $0.id == level.id - 1 }) else { return false }
        return prev.units.allSatisfy { isMCCompleted(for: $0) }
    }

    // MARK: - Legacy aliases

    func answeredCount(for unit: UnitModel) -> Int { mcAnsweredCount(for: unit) }
    func isUnitCompleted(_ unit: UnitModel) -> Bool { isMCCompleted(for: unit) }

    var todayScore: Int? { attemptService.todayScore }
    var totalAnsweredCount: Int { attemptService.totalAnsweredCount }
}
