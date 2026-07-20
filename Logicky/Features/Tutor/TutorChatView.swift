import SwiftUI

/// AI家庭教師「ロジ先生」とのチャット画面。問題の文脈を持った状態で質問できる。
struct TutorChatView: View {
    let context: TutorService.QuestionContext?
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [TutorService.ChatMessage] = []
    @State private var input = ""
    @State private var isSending = false
    @State private var errorMessage: String? = nil

    private let suggestions = [
        "なんでこれが正解なの？",
        "もっとやさしく説明して",
        "似た例をもう1つ教えて",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            greetingBubble

                            ForEach(messages) { message in
                                bubble(for: message)
                            }

                            if isSending {
                                HStack(spacing: 8) {
                                    avatar
                                    Text("考え中…")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appGray)
                                }
                            }

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(16)
                    }
                    .onChange(of: messages) { _, _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                // クイック質問
                if messages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { s in
                                Button {
                                    input = s
                                    Task { await send() }
                                } label: {
                                    Text(s)
                                        .font(.caption)
                                        .foregroundStyle(Color.tiffany)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.tiffany.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }

                // 入力欄
                HStack(spacing: 8) {
                    TextField("ロジ先生に質問する…", text: $input, axis: .vertical)
                        .font(.subheadline)
                        .lineLimit(1...3)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(Color.appBg)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    Button {
                        Task { await send() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(canSend ? Color.tiffany : Color.appGray)
                    }
                    .disabled(!canSend)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .background(Color.white)
            .navigationTitle("ロジ先生")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appSub)
                }
            }
        }
    }

    private var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.tiffany.opacity(0.12))
                .frame(width: 30, height: 30)
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.tiffany)
        }
    }

    private var greetingBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            avatar
            Text(context?.questionBody != nil
                 ? "この問題について、なんでも聞いてください！わかりにくいところを一緒に整理しましょう。"
                 : "ロジ先生です！論理的思考について、なんでも聞いてください。")
                .font(.subheadline)
                .foregroundStyle(Color.appText)
                .lineSpacing(4)
                .padding(12)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    @ViewBuilder
    private func bubble(for message: TutorService.ChatMessage) -> some View {
        if message.role == "user" {
            HStack {
                Spacer(minLength: 40)
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineSpacing(4)
                    .padding(12)
                    .background(Color.tiffany)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        } else {
            HStack(alignment: .top, spacing: 8) {
                avatar
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(Color.appText)
                    .lineSpacing(4)
                    .padding(12)
                    .background(Color.appBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 40)
            }
        }
    }

    private func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }
        input = ""
        errorMessage = nil
        messages.append(TutorService.ChatMessage(role: "user", content: text))
        isSending = true

        let result = await TutorService.shared.send(messages: messages, context: context)
        isSending = false
        switch result {
        case .reply(let reply):
            messages.append(TutorService.ChatMessage(role: "assistant", content: reply))
        case .failure(let message):
            errorMessage = message
        }
    }
}
