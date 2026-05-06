import Foundation

struct CognitiveBias: Codable, Identifiable {
    let id: String
    let displayName: String
    let technicalName: String
    let reading: String?
    let category: String
    let definition: String
    let description: String
    let businessExample: String
    let dangerScene: String
    let prevention: String
    let relatedUnits: [String]
}
