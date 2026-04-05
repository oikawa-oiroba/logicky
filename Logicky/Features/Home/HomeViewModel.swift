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

    // MARK: - Progress

    func answeredCount(for unit: UnitModel) -> Int {
        attemptService.answeredCount(for: unit.id)
    }

    func isUnitCompleted(_ unit: UnitModel) -> Bool {
        attemptService.isUnitCompleted(unit.id)
    }

    func isLevelUnlocked(_ level: LevelModel) -> Bool {
        if level.id == 1 { return true }
        let prerequisite = LevelModel.all.first { $0.id == level.id - 1 }
        guard let prev = prerequisite else { return false }
        return prev.units.allSatisfy { isUnitCompleted($0) }
    }

    var todayScore: Int? { attemptService.todayScore }
    var totalAnsweredCount: Int { attemptService.totalAnsweredCount }
}
