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
    var position: String = "未回答"
    var industry: String = "未回答"
}
