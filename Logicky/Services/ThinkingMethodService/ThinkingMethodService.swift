import Foundation

final class ThinkingMethodService {
    static let shared = ThinkingMethodService()
    private init() {}

    private(set) lazy var all: [ThinkingMethod] = load()

    private func load() -> [ThinkingMethod] {
        guard let url = Bundle.main.url(forResource: "thinking_methods", withExtension: "json") else {
            print("⚠️ thinking_methods.json が見つかりません")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder().decode(Container.self, from: data)
            return container.methods
        } catch {
            print("⚠️ thinking_methods.json のデコードに失敗: \(error)")
            return []
        }
    }

    private struct Container: Codable {
        let methods: [ThinkingMethod]
    }
}
