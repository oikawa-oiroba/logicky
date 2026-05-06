import Foundation

final class CognitiveBiasService {
    static let shared = CognitiveBiasService()
    private init() {}

    private(set) lazy var all: [CognitiveBias] = load()

    func bias(for id: String) -> CognitiveBias? {
        all.first { $0.id == id }
    }

    func biases(for category: String) -> [CognitiveBias] {
        all.filter { $0.category == category }
    }

    private func load() -> [CognitiveBias] {
        guard let url = Bundle.main.url(forResource: "cognitive_biases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let container = try? JSONDecoder().decode(Container.self, from: data)
        else { return [] }
        return container.biases
    }

    private struct Container: Codable {
        let biases: [CognitiveBias]
    }
}
