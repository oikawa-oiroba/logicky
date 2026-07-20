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

    // MARK: - 会話ログ（端末保存・復習用）

    struct TutorLog: Codable, Identifiable {
        let id: UUID
        let questionId: String?
        let unitName: String?
        let questionBody: String?
        var messages: [ChatMessage]
        var updatedAt: Date
    }

    private let logsKey = "logicky_tutor_logs_v1"
    private let maxLogs = 100

    var logs: [TutorLog] {
        guard let data = UserDefaults.standard.data(forKey: logsKey),
              let decoded = try? JSONDecoder().decode([TutorLog].self, from: data)
        else { return [] }
        return decoded.sorted { $0.updatedAt > $1.updatedAt }
    }

    func log(forQuestionId questionId: String?) -> TutorLog? {
        guard let questionId else { return nil }
        return logs.first { $0.questionId == questionId }
    }

    /// 会話を保存（同じ問題の会話は上書き＝続きから再開できる）
    func saveLog(
        questionId: String?,
        unitName: String?,
        questionBody: String?,
        messages: [ChatMessage]
    ) {
        guard !messages.isEmpty else { return }
        var all = logs
        if let questionId, let index = all.firstIndex(where: { $0.questionId == questionId }) {
            all[index].messages = messages
            all[index].updatedAt = Date()
        } else {
            all.insert(
                TutorLog(
                    id: UUID(),
                    questionId: questionId,
                    unitName: unitName,
                    questionBody: questionBody,
                    messages: messages,
                    updatedAt: Date()
                ),
                at: 0
            )
        }
        if all.count > maxLogs {
            all = Array(all.sorted { $0.updatedAt > $1.updatedAt }.prefix(maxLogs))
        }
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: logsKey)
        }
    }

    func deleteLog(id: UUID) {
        let all = logs.filter { $0.id != id }
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: logsKey)
        }
    }

    /// 会話をテキスト化（コピー用）
    static func transcript(messages: [ChatMessage], questionBody: String?) -> String {
        var lines: [String] = []
        if let questionBody {
            lines.append("【問題】\(questionBody)")
            lines.append("")
        }
        for m in messages {
            lines.append(m.role == "user" ? "🙋 自分：\(m.content)" : "🎓 ロジ先生：\(m.content)")
            lines.append("")
        }
        lines.append("— Logicky ロジ先生ノート")
        return lines.joined(separator: "\n")
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
