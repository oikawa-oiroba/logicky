import SwiftUI

struct DiagnosticQuizView: View {
    @ObservedObject var vm: DiagnosticViewModel

    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            Spacer(minLength: 0)
            if let q = vm.currentQuestion {
                questionBody(q)
            }
            Spacer(minLength: 0)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Q\(vm.currentIndex + 1) / \(vm.questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("ロジッキー診断")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.indigo)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemFill))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [.indigo, .purple],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * vm.progressRatio, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: vm.progressRatio)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Question Body

    private func questionBody(_ q: Question) -> some View {
        VStack(spacing: 20) {
            // Question card
            VStack(alignment: .leading, spacing: 10) {
                Text(q.title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(q.body)
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

            // Choices
            VStack(spacing: 10) {
                ForEach(q.choices ?? []) { choice in
                    choiceButton(choice, question: q)
                }
            }
        }
        .padding(.horizontal, 24)
        .id(q.id)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.25), value: q.id)
    }

    // MARK: - Choice Button

    private func choiceButton(_ choice: Choice, question: Question) -> some View {
        let answered = vm.isAnswered
        let selected = vm.isSelected(choice.id)
        let isCorrect = vm.isCorrectChoice(choice.id)

        let bgColor: Color = {
            guard answered else { return Color(.systemBackground) }
            if selected && isCorrect { return Color.green.opacity(0.15) }
            if selected && !isCorrect { return Color.red.opacity(0.12) }
            if isCorrect { return Color.green.opacity(0.08) }
            return Color(.systemBackground)
        }()

        let borderColor: Color = {
            guard answered else { return Color(.separator) }
            if selected && isCorrect { return .green }
            if selected && !isCorrect { return .red }
            if isCorrect { return Color.green.opacity(0.5) }
            return Color(.separator)
        }()

        return Button {
            vm.selectAnswer(choice.id)
        } label: {
            HStack(spacing: 12) {
                Text(choice.text)
                    .font(.subheadline)
                    .foregroundStyle(answered ? (selected || isCorrect ? .primary : .secondary) : .primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if answered {
                    if selected && isCorrect {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    } else if selected && !isCorrect {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                    } else if isCorrect {
                        Image(systemName: "checkmark.circle").foregroundStyle(.green)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: answered ? 1.5 : 0.5)
            )
        }
        .disabled(answered)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: answered)
    }
}
