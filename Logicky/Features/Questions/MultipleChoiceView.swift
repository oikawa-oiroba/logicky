import SwiftUI

struct MultipleChoiceView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var showHint = false
    @State private var showTutor = false
    @State private var answeredChoiceId: String? = nil
    @State private var showExplanation = false
    @State private var showConfetti = false
    @State private var shakeOffset: CGFloat = 0

    private var isAnswered: Bool { answeredChoiceId != nil }

    private var isCorrect: Bool {
        guard let q = viewModel.currentQuestion, let id = answeredChoiceId else { return false }
        return id == q.correctChoiceId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 16) {
                        questionCard(question)
                        choicesList(question)
                        Spacer(minLength: showExplanation ? 480 : 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .background(Color.appBg)
                .sheet(isPresented: $showHint) {
                    if let method = hintMethod(for: question) {
                        HintSheetView(method: method)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                }
                .sheet(isPresented: $showTutor) {
                    TutorChatView(context: tutorContext(for: question))
                }

                if showExplanation {
                    explanationCard(question)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(10)
                }

                if showConfetti {
                    ConfettiView()
                        .zIndex(20)
                }
            }
        }
        .onChange(of: viewModel.currentIndex) { _, _ in
            withAnimation(.spring(response: 0.3)) {
                showExplanation = false
            }
            answeredChoiceId = nil
            showConfetti = false
            shakeOffset = 0
        }
    }

    // MARK: - Choice tap handler

    private func handleChoiceTap(_ choiceId: String, question: Question) {
        guard !isAnswered else { return }
        viewModel.selectChoice(choiceId)
        answeredChoiceId = choiceId

        let correct = choiceId == question.correctChoiceId
        withAnimation(.spring(response: 0.4)) {
            showExplanation = true
        }
        if correct {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showConfetti = false
            }
        } else {
            withAnimation(.default) {
                shakeOffset = 8
            }
            withAnimation(.default.delay(0.1)) {
                shakeOffset = -8
            }
            withAnimation(.default.delay(0.2)) {
                shakeOffset = 4
            }
            withAnimation(.default.delay(0.3)) {
                shakeOffset = 0
            }
        }
    }

    // MARK: - Question Card

    private func questionCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("4択問題")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.tiffany.opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
            }

            Text(question.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appSub)

            Text(question.body)
                .font(.body)
                .foregroundStyle(Color.appText)
                .lineSpacing(6)

            if !isAnswered, hintMethod(for: question) != nil {
                Button {
                    showHint = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                        Text("ヒント：この考え方とは？")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.tiffany.opacity(0.08))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Choices List

    private func choicesList(_ question: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(question.choices ?? []) { choice in
                AnswerChoiceButton(
                    choice: choice,
                    state: choiceState(choice, question: question)
                ) {
                    handleChoiceTap(choice.id, question: question)
                }
                .offset(x: !isAnswered || choice.id == answeredChoiceId ? 0 : 0)
                .offset(x: choice.id == answeredChoiceId && !isCorrect ? shakeOffset : 0)
            }
        }
    }

    private func choiceState(_ choice: Choice, question: Question) -> ChoiceState {
        guard let answeredId = answeredChoiceId else { return .normal }
        if choice.id == question.correctChoiceId { return .correct }
        if choice.id == answeredId { return .wrong }
        return .faded
    }

    // MARK: - Explanation Card

    private func explanationCard(_ question: Question) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.cardBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 6)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Correct / incorrect header
                    HStack(spacing: 10) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(isCorrect ? Color.tiffany : Color.appGray)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isCorrect ? "正解！" : "不正解")
                                .font(.title3.bold())
                                .foregroundStyle(isCorrect ? Color.tiffany : Color.appText)
                            if !isCorrect, let correctChoice = question.choices?.first(where: { $0.id == question.correctChoiceId }) {
                                Text("正解：\(correctChoice.text)")
                                    .font(.caption)
                                    .foregroundStyle(Color.tiffany)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                    }

                    Divider().background(Color.cardBorder)

                    // Explanation
                    if let explanation = question.explanation {
                        Text(explanation)
                            .font(.subheadline)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(5)
                    }

                    // Badges row
                    badgesRow(question)

                    // ロジ先生（AI家庭教師）に質問
                    Button {
                        showTutor = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "graduationcap.fill")
                            Text("ロジ先生に質問する")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.tiffany)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.tiffany.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Feedback（問題への意見）
                    QuestionFeedbackForm(
                        questionId: question.id,
                        unit: question.unit ?? "",
                        selectedChoiceId: answeredChoiceId
                    )
                    .id(question.id)

                    // Next button
                    Button {
                        viewModel.goNext()
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.isLastQuestion ? "結果を見る" : "次の問題へ")
                                .font(.headline)
                            Image(systemName: viewModel.isLastQuestion ? "flag.checkered" : "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.tiffany)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .frame(maxHeight: 420)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 20, y: -4)
        // 下部の進捗バーと被らないように持ち上げる
        .padding(.bottom, 44)
    }

    @ViewBuilder
    private func badgesRow(_ question: Question) -> some View {
        let unitId = question.unit ?? ""
        let method = ThinkingMethodService.shared.all.first { $0.unitId == unitId }
        let biases = (question.relatedBiases ?? []).compactMap { CognitiveBiasService.shared.bias(for: $0) }

        if method != nil || !biases.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let method {
                        BadgeChip(icon: "book.closed.fill", text: method.name, color: Color.tiffany)
                    }
                    ForEach(biases) { bias in
                        BadgeChip(icon: "exclamationmark.triangle.fill", text: bias.technicalName, color: Color.appGray)
                    }
                }
            }
        }
    }

    private func hintMethod(for question: Question) -> ThinkingMethod? {
        guard let unitId = question.unit else { return nil }
        return ThinkingMethodService.shared.all.first { $0.unitId == unitId }
    }

    private func tutorContext(for question: Question) -> TutorService.QuestionContext {
        let unit = UnitModel.all.first { $0.id == question.unit }
        return TutorService.QuestionContext(
            unitName: unit?.displayName,
            methodName: unit?.name,
            questionBody: question.body,
            choices: question.choices,
            correctChoiceId: question.correctChoiceId,
            selectedChoiceId: answeredChoiceId,
            explanation: question.explanation
        )
    }
}

// MARK: - Question Feedback Form（結果画面からも利用）

struct QuestionFeedbackForm: View {
    let questionId: String
    let unit: String
    let selectedChoiceId: String?

    private enum SendStatus { case idle, sending, done, error }

    @State private var isOpen = false
    @State private var category: String? = nil
    @State private var comment = ""
    @State private var status: SendStatus = .idle

    var body: some View {
        Group {
            if status == .done {
                Text("フィードバックを送信しました。改善に活用します。ありがとうございます！")
                    .font(.caption)
                    .foregroundStyle(Color.tiffany)
            } else if !isOpen {
                Button {
                    withAnimation { isOpen = true }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left")
                            .font(.caption2)
                        Text("この問題について意見を送る（わかりづらい・答えが違う 等）")
                            .font(.caption)
                            .underline()
                    }
                    .foregroundStyle(Color.appGray)
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(FeedbackService.categories, id: \.self) { c in
                            Button {
                                category = c
                            } label: {
                                Text(c)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(category == c ? Color.tiffany : Color.white)
                                    .foregroundStyle(category == c ? .white : Color.appSub)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(category == c ? Color.tiffany : Color.cardBorder, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("詳しく教えてもらえると助かります（任意）", text: $comment, axis: .vertical)
                        .font(.caption)
                        .lineLimit(2...4)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))

                    HStack(spacing: 12) {
                        Button {
                            submit()
                        } label: {
                            Text(status == .sending ? "送信中…" : "送信する")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(category == nil ? Color.appGray : Color.tiffany)
                                .clipShape(Capsule())
                        }
                        .disabled(category == nil || status == .sending)
                        .buttonStyle(.plain)

                        Button("閉じる") {
                            withAnimation { isOpen = false }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                        .buttonStyle(.plain)

                        if status == .error {
                            Text("送信に失敗しました")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(10)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func submit() {
        guard let category else { return }
        status = .sending
        Task {
            let ok = await FeedbackService.shared.send(
                questionId: questionId,
                unit: unit,
                category: category,
                comment: comment,
                selectedChoiceId: selectedChoiceId
            )
            status = ok ? .done : .error
        }
    }
}

// MARK: - Choice State

private enum ChoiceState {
    case normal, correct, wrong, faded
}

// MARK: - Answer Choice Button

private struct AnswerChoiceButton: View {
    let choice: Choice
    let state: ChoiceState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                stateIcon
                Text(choice.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(textColor)
                Spacer()
            }
            .padding(14)
            .background(bgColor)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: borderWidth))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(state == .faded ? 0.4 : 1.0)
        }
        .disabled(state != .normal)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: state)
    }

    @ViewBuilder
    private var stateIcon: some View {
        switch state {
        case .normal:
            Circle()
                .stroke(Color.cardBorder, lineWidth: 1.5)
                .frame(width: 22, height: 22)
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.tiffany)
        case .wrong:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.appGray)
        case .faded:
            Circle()
                .stroke(Color.cardBorder.opacity(0.5), lineWidth: 1.5)
                .frame(width: 22, height: 22)
        }
    }

    private var bgColor: Color {
        switch state {
        case .normal: return .white
        case .correct: return Color.tiffany.opacity(0.07)
        case .wrong: return Color.appGray.opacity(0.07)
        case .faded: return .white
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal: return Color.cardBorder
        case .correct: return Color.tiffany
        case .wrong: return Color.appGray
        case .faded: return Color.cardBorder.opacity(0.3)
        }
    }

    private var borderWidth: CGFloat {
        switch state {
        case .correct, .wrong: return 1.5
        default: return 1
        }
    }

    private var textColor: Color {
        switch state {
        case .faded: return Color.appGray
        default: return Color.appText
        }
    }
}

// MARK: - Badge Chip

private struct BadgeChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Hint Sheet

struct HintSheetView: View {
    let method: ThinkingMethod
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.displayName)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appText)
                    Group {
                        if let reading = method.reading {
                            Text("\(method.name)（\(reading)）")
                        } else {
                            Text(method.name)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appSub)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appGray)
                }
            }

            Divider().background(Color.cardBorder)

            VStack(alignment: .leading, spacing: 12) {
                Label("どういう考え方？", systemImage: "lightbulb.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                Text(method.hintShort)
                    .font(.body)
                    .foregroundStyle(Color.appText)
                    .lineSpacing(5)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tiffany.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                Label("身近な例", systemImage: "person.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSub)
                Text(method.hintExample)
                    .font(.body)
                    .foregroundStyle(Color.appText)
                    .lineSpacing(5)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("ヒントを見ても採点には影響しません")
                .font(.caption)
                .foregroundStyle(Color.appGray)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
}
