import Foundation

final class SkillBadgeService {
    static let shared = SkillBadgeService()
    private init() {}

    private let acquiredKey = "logicky_acquired_badges_v1"

    func badge(for unit: UnitModel) -> SkillBadge? {
        let mcIds = Set(QuestionService.shared.trainingQuestions(for: unit.id).map { $0.id })
        let answeredIds = AttemptService.shared.answeredMCQuestionIds(for: unit.id, mcIds: mcIds)
        guard !answeredIds.isEmpty else { return nil }

        let rate = AttemptService.shared.mcCorrectRate(for: unit.id, mcIds: mcIds) ?? 0
        // バッジ（習得）は全問正解が条件
        let level: BadgeLevel = rate >= 1.0 ? .acquired : .learning
        let date = level == .acquired ? acquiredDates[unit.id] : nil
        return SkillBadge(unitCode: unit.id, level: level, acquiredDate: date, correctRate: rate)
    }

    private let clearedKey = "logicky_cleared_badges_v1"

    /// クリア済み単元のID一覧（バッジ画面用）
    var clearedUnitIds: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: clearedKey) ?? [])
    }

    /// 単元を初めてクリア（セッション完了）したらtrue。クリアバッジの演出用
    func checkAndMarkNewlyCleared(for unitId: String) -> Bool {
        var set = Set(UserDefaults.standard.stringArray(forKey: clearedKey) ?? [])
        guard !set.contains(unitId) else { return false }
        set.insert(unitId)
        UserDefaults.standard.set(Array(set), forKey: clearedKey)
        return true
    }

    /// Returns true if this unit just reached 'acquired' for the first time.
    /// バッジ獲得条件はセッション全問正解
    func checkAndMarkNewlyAcquired(for unitId: String, rate: Double) -> Bool {
        guard rate >= 1.0 else { return false }
        var set = acquiredSet
        guard !set.contains(unitId) else { return false }
        set.insert(unitId)
        saveAcquiredSet(set)
        // Store acquisition date
        var dates = acquiredDates
        dates[unitId] = Date()
        if let data = try? JSONEncoder().encode(dates) {
            UserDefaults.standard.set(data, forKey: acquiredKey + "_dates")
        }
        return true
    }

    private var acquiredSet: Set<String> {
        guard let arr = UserDefaults.standard.stringArray(forKey: acquiredKey) else { return [] }
        return Set(arr)
    }

    private func saveAcquiredSet(_ set: Set<String>) {
        UserDefaults.standard.set(Array(set), forKey: acquiredKey)
    }

    private var acquiredDates: [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: acquiredKey + "_dates"),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return [:] }
        return decoded
    }
}
