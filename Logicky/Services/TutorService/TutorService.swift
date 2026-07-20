import Foundation

/// AI家庭教師「ロジ先生」。logicky.app/api/tutor 経由でClaudeに質問する。
/// APIキーはサーバー側にのみ存在し、端末には持たない。
final class TutorService {
    static let shared = TutorService()
    private init() {}

    private let endpoint = URL(string: "https://logicky.app/api/tutor")!

    struct ChatMessage: Codable, Identifiable, Equatable {
        var id: UUID = UUID()
        let role: String // "user" | "assistant"
        let content: String

        enum CodingKeys: String, CodingKey {
            case role, content
        }
    }

    struct QuestionContext: Codable {
        let unitName: String?
        let methodName: String?
        let questionBody: String?
        let choices: [Choice]?
        let correctChoiceId: String?
        let selectedChoiceId: String?
        let explanation: String?
    }

    enum TutorResult {
        case reply(String)
        case failure(message: String)
    }

    func send(
        messages: [ChatMessage],
        context: QuestionContext?
    ) async -> TutorResult {
        struct Payload: Encodable {
            let deviceId: String
            let messages: [ChatMessage]
            let context: QuestionContext?
        }
        struct Response: Decodable {
            let reply: String?
            let error: String?
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        do {
            let deviceId = await PremiumService.shared.deviceId
            request.httpBody = try JSONEncoder().encode(
                Payload(deviceId: deviceId, messages: messages, context: context)
            )
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            if let reply = decoded.reply, !reply.isEmpty {
                return .reply(reply)
            }
            return .failure(message: decoded.error ?? "応答を取得できませんでした")
        } catch {
            return .failure(message: "通信に失敗しました。ネットワークを確認してください")
        }
    }
}
