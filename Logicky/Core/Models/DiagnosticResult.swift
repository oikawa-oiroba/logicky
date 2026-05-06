import Foundation

struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalScore: Int
    let organizeScore: Int  // Level1 整理力
    let reasonScore: Int    // Level2 推論力
    let judgeScore: Int     // Level3 判断力
    var profile: DiagnosticProfile
}

struct DiagnosticProfile: Codable {
    var gender: String = "未回答"
    var ageGroup: String = "未回答"
    var position: String = "未回答"
    var industry: String = "未回答"
}
