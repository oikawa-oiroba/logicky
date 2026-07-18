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

    // トレーニング完了＝単元の全問題を正解済み
    func isMCCompleted(for unit: UnitModel) -> Bool {
        SkillBadgeService.shared.isUnitCompleted(unit.id)
    }

    func hasMasterMode(for unit: UnitModel) -> Bool {
        !QuestionService.shared.questions(for: unit.id).filter { $0.type == .freeText }.isEmpty
    }

    // MARK: - Level Unlock (all levels always unlocked)

    func isLevelUnlocked(_ level: LevelModel) -> Bool {
        return true
    }

    // MARK: - Streak

    var streakDays: Int {
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        let hasStudiedToday = attemptService.attempts.contains { calendar.isDateInToday($0.date) }
        if !hasStudiedToday {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        var streak = 0
        while true {
            let studied = attemptService.attempts.contains { calendar.isDate($0.date, inSameDayAs: checkDate) }
            guard studied else { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    var streakMessage: String {
        streakDays == 0 ? "今日から始めよう!" : "\(streakDays)日連続"
    }

    // MARK: - Today's Unit

    var isAllUnitsCompleted: Bool {
        UnitModel.all.allSatisfy { isMCCompleted(for: $0) }
    }

    var todayUnit: UnitModel? {
        if isAllUnitsCompleted {
            return UnitModel.all.min { bestMCScore(for: $0) < bestMCScore(for: $1) }
        }
        return UnitModel.all.first { !isMCCompleted(for: $0) }
    }

    private func bestMCScore(for unit: UnitModel) -> Int {
        attemptService.attempts(for: unit.id).map { $0.totalScore }.max() ?? 0
    }

    func todayUnitAnsweredCount() -> Int {
        guard let unit = todayUnit else { return 0 }
        return min(mcAnsweredCount(for: unit), todayUnitMCCount())
    }

    // 「今日の5問」のセッションは5問なので、分母も単元の全問数ではなく5に揃える
    func todayUnitMCCount() -> Int {
        guard let unit = todayUnit else { return 0 }
        return min(5, QuestionService.shared.trainingQuestions(for: unit.id).count)
    }

    // MARK: - Growth / Level Progress

    func abilityName(for level: LevelModel) -> String {
        switch level.id {
        case 0: return "基礎力"
        case 1: return "整理する力"
        case 2: return "分析する力"
        case 3: return "検証する力"
        default: return level.description
        }
    }

    func levelProgress(for level: LevelModel) -> Double {
        let total = level.units.count
        guard total > 0 else { return 0 }
        let completed = level.units.filter { isMCCompleted(for: $0) }.count
        return Double(completed) / Double(total)
    }

    // MARK: - Skill Status

    struct UnitSkillInfo: Identifiable {
        let unit: UnitModel
        let badge: SkillBadge?
        var id: String { unit.id }
        var correctRate: Double { badge?.correctRate ?? 0 }
    }

    func basicUnitSkillInfos() -> [UnitSkillInfo] {
        UnitModel.basic.map { UnitSkillInfo(unit: $0, badge: SkillBadgeService.shared.badge(for: $0)) }
    }

    func topStrengthSkills() -> [UnitSkillInfo] {
        Array(basicUnitSkillInfos()
            .filter { $0.badge != nil }
            .sorted { $0.correctRate > $1.correctRate }
            .prefix(3))
    }

    func weakSkills() -> [UnitSkillInfo] {
        Array(basicUnitSkillInfos()
            .filter { info in
                guard let badge = info.badge else { return false }
                return badge.level == .learning
            }
            .sorted { $0.correctRate < $1.correctRate }
            .prefix(3))
    }

    func untriedSkills() -> [UnitSkillInfo] {
        basicUnitSkillInfos().filter { $0.badge == nil }
    }

    // MARK: - Legacy aliases

    func answeredCount(for unit: UnitModel) -> Int { mcAnsweredCount(for: unit) }
    func isUnitCompleted(_ unit: UnitModel) -> Bool { isMCCompleted(for: unit) }

    var todayScore: Int? { attemptService.todayScore }
    var totalAnsweredCount: Int { attemptService.totalAnsweredCount }
}
