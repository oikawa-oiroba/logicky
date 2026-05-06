import Foundation

struct ThinkingMethod: Identifiable, Codable {
    let id: String
    let name: String
    let tagline: String
    let icon: String
    let explanation: String
    let example: String
    let commonMistakes: [String]
    let unitId: String?
}
