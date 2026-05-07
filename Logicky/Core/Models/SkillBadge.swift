import Foundation

enum BadgeLevel: String, Codable {
    case learning  // 学習中: 1問以上回答した
    case acquired  // 習得: 正答率80%以上
    case master    // マスター: 全問正解 + マスターモード完了
}

struct SkillBadge: Codable, Identifiable {
    var id: String { unitCode }
    let unitCode: String
    let level: BadgeLevel
    let acquiredDate: Date?
    let correctRate: Double
}
