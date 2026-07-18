import Foundation

struct DiagnosticResult: Identifiable, Codable, Hashable {
    static func == (lhs: DiagnosticResult, rhs: DiagnosticResult) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: UUID
    let date: Date
    let totalScore: Int
    let organizeScore: Int  // Level1 整理力
    let reasonScore: Int    // Level2 推論力
    let judgeScore: Int     // Level3 判断力
    var unitResults: [String: Bool]?
    var profile: DiagnosticProfile
}

struct DiagnosticProfile: Codable, Hashable {
    var gender: String = "未回答"
    var ageGroup: String = "未回答"
    var position: String = "未回答"   // 職種
    var role: String = "未回答"       // 役職
    var industry: String = "未回答"

    init() {}

    // roleフィールド追加前の保存データも読めるように decodeIfPresent を使う
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        gender   = try c.decodeIfPresent(String.self, forKey: .gender) ?? "未回答"
        ageGroup = try c.decodeIfPresent(String.self, forKey: .ageGroup) ?? "未回答"
        position = try c.decodeIfPresent(String.self, forKey: .position) ?? "未回答"
        role     = try c.decodeIfPresent(String.self, forKey: .role) ?? "未回答"
        industry = try c.decodeIfPresent(String.self, forKey: .industry) ?? "未回答"
    }
}
