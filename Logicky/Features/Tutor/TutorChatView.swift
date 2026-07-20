import SwiftUI

/// AI家庭教師「ロジ先生」とのチャット画面。
/// - 問題文を折りたたみで常時参照できる
/// - 会話は端末に自動保存され、同じ問題を開くと続きから再開
/// - バブル長押し/ツールバーからコピー可能
struct TutorChatView: View {
    let context: TutorService.QuestionContext?
    let questionId: String?

    init(context: TutorService.QuestionContext?, questionId: String? = nil) {
        self.context = context
        self.questionId = questionId
    }

    @Environment(\.dismiss) private var dismiss

    @State private var messages: [TutorService.ChatMessage] = []
    @State private var input = ""
    @State private var isSending = false
    @State private var errorMessage: String? = nil
    @State private var showQuestion = false
    @State private var showCopied = false

    private let suggestions = [
        "なんでこれが正解なの？",
        "もっとやさしく説明して",
        "似た例をもう1つ教えて",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 問題文（折りたたみ）— チャット中でも問題を振り返れる
                if let questionBody = context?.questionBody {
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { showQuestion.toggle() }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                Text(showQuestion ? "問題文をとじる" : "問題文をひらく")
                                    .font(.caption.weight(.semibold))
                                Spacer()
                                Image(systemName: showQuestion ? "chevron.up" : "chevron.down")
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundStyle(Color.tiffany)
                        }
                        if showQuestion {
                            ScrollView {
                                Text(questionBody)
                                    .font(.caption)
                                    .foregroundStyle(Color.appText)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 110)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.tiffany.opacity(0.06))
                }

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
                    .onAppear {
                        withAnimation(.none) { proxy.scrollTo("bottom", anchor: .bottom) }
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
                ToolbarItem(placement: .topBarLeading) {
                    if !messages.isEmpty {
                        Button {
                            UIPasteboard.general.string = TutorService.transcript(
                                messages: messages,
                                questionBody: context?.questionBody
                            )
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                showCopied = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                Text(showCopied ? "コピー済み" : "会話をコピー")
                            }
                            .font(.caption)
                            .foregroundStyle(Color.tiffany)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appSub)
                }
            }
            .onAppear {
                // 同じ問題の会話を復元（続きから再開できる）
                if messages.isEmpty,
                   let saved = TutorService.shared.log(forQuestionId: questionId) {
                    messages = saved.messages
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
                bubbleText(message, textColor: .white, background: Color.tiffany)
            }
        } else {
            HStack(alignment: .top, spacing: 8) {
                avatar
                bubbleText(message, textColor: Color.appText, background: Color.appBg)
                Spacer(minLength: 40)
            }
        }
    }

    private func bubbleText(
        _ message: TutorService.ChatMessage,
        textColor: Color,
        background: Color
    ) -> some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundStyle(textColor)
            .lineSpacing(4)
            .padding(12)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contextMenu {
                Button {
                    UIPasteboard.general.string = message.content
                } label: {
                    Label("この発言をコピー", systemImage: "doc.on.doc")
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
            TutorService.shared.saveLog(
                questionId: questionId,
                unitName: context?.unitName,
                questionBody: context?.questionBody,
                messages: messages
            )
        case .failure(let message):
            errorMessage = message
        }
    }
}

// MARK: - ロジ先生ノート（保存済み会話の一覧・詳細）

struct TutorLogListView: View {
    @State private var logs: [TutorService.TutorLog] = []

    var body: some View {
        Group {
            if logs.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "graduationcap")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appGray)
                    Text("まだロジ先生との会話がありません")
                        .font(.headline)
                        .foregroundStyle(Color.appSub)
                    Text("問題の解説画面から質問すると、\n会話がここに残ります")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg)
            } else {
                List {
                    ForEach(logs) { log in
                        NavigationLink {
                            TutorLogDetailView(log: log)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.tiffany)
                                    Text(log.unitName ?? "ロジ先生との会話")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appText)
                                    Spacer()
                                    Text(log.updatedAt.formatted(.dateTime.month().day()))
                                        .font(.caption2)
                                        .foregroundStyle(Color.appGray)
                                }
                                if let body = log.questionBody {
                                    Text(body)
                                        .font(.caption)
                                        .foregroundStyle(Color.appSub)
                                        .lineLimit(2)
                                }
                                Text("\(log.messages.count)件のやり取り")
                                    .font(.caption2)
                                    .foregroundStyle(Color.appGray)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            TutorService.shared.deleteLog(id: logs[index].id)
                        }
                        logs = TutorService.shared.logs
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .onAppear { logs = TutorService.shared.logs }
    }
}

struct TutorLogDetailView: View {
    let log: TutorService.TutorLog
    @State private var showCopied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let body = log.questionBody {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("問題")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.tiffany)
                        Text(body)
                            .font(.subheadline)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(4)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tiffany.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                ForEach(log.messages) { message in
                    HStack(alignment: .top, spacing: 8) {
                        Text(message.role == "user" ? "🙋" : "🎓")
                        Text(message.content)
                            .font(.subheadline)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(message.role == "user" ? Color.tiffany.opacity(0.08) : Color.appBg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .navigationTitle(log.unitName ?? "ロジ先生ノート")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIPasteboard.general.string = TutorService.transcript(
                        messages: log.messages,
                        questionBody: log.questionBody
                    )
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        showCopied = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? "コピー済み" : "コピー")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.tiffany)
                }
            }
        }
    }
}
