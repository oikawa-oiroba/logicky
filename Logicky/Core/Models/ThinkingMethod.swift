import Foundation

struct ThinkingMethod: Identifiable, Codable {
    let id: String
    let name: String          // technical name: "MECE", "演繹法", etc.
    let displayName: String   // friendly name: "モレなく分ける力"
    let tagline: String
    let icon: String
    let explanation: String
    let example: String
    let commonMistakes: [String]
    let unitId: String?
    let hintShort: String     // ≤50 chars, shown as in-quiz hint
    let hintExample: String   // ≤100 chars, shown as in-quiz example
}
