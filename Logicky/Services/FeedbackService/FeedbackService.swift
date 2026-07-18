import Foundation

/// 問題・アプリへのフィードバックを Web と共通の基盤（logicky.app/api/feedback）に送信する。
/// 送信はユーザーの明示的な操作でのみ行われ、個人情報は含まれない。
final class FeedbackService {
    static let shared = FeedbackService()
    private init() {}

    static let categories = ["わかりづらい", "答えが違うと思う", "誤字・脱字", "その他"]

    private let endpoint = URL(string: "https://logicky.app/api/feedback")!

    struct Payload: Encodable {
        let questionId: String
        let unit: String
        let category: String
        let comment: String
        let selectedChoiceId: String
    }

    func send(
        questionId: String,
        unit: String,
        category: String,
        comment: String,
        selectedChoiceId: String?
    ) async -> Bool {
        let payload = Payload(
            questionId: questionId,
            unit: unit,
            category: category,
            comment: String(comment.prefix(500)),
            selectedChoiceId: selectedChoiceId ?? ""
        )
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        do {
            request.httpBody = try JSONEncoder().encode(payload)
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
