import Foundation

final class ThinkingMethodService {
    static let shared = ThinkingMethodService()
    private init() {}

    private(set) lazy var all: [ThinkingMethod] = load()

    private func load() -> [ThinkingMethod] {
        guard let url = Bundle.main.url(forResource: "thinking_methods", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let container = try? JSONDecoder().decode(Container.self, from: data)
        else { return [] }
        return container.methods
    }

    private struct Container: Codable {
        let methods: [ThinkingMethod]
    }
}
