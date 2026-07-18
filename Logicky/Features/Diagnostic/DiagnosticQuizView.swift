import SwiftUI

struct DiagnosticQuizView: View {
    @ObservedObject var vm: DiagnosticViewModel
    @State private var showHint = false

    private func hintMethod(for question: Question) -> ThinkingMethod? {
        guard let unitId = question.unit else { return nil }
        return ThinkingMethodService.shared.all.first { $0.unitId == unitId }
    }

    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            // 問題は上揃え（長文でもスクロールで読める）
            if let q = vm.currentQuestion {
                ScrollView {
                    questionBody(q)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                }
            }
            Spacer(minLength: 0)
        }
        .background(Color.appBg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showHint) {
            if let q = vm.currentQuestion, let method = hintMethod(for: q) {
                HintSheetView(method: method)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Q\(vm.currentIndex + 1) / \(vm.questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appSub)
                Spacer()
                Text("ロジッキー診断")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cardBorder)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.tiffany)
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
            VStack(alignment: .leading, spacing: 10) {
                Text(q.title)
                    .font(.headline)
                    .foregroundStyle(Color.appSub)
                Text(q.body)
                    .font(.body)
                    .foregroundStyle(Color.appText)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                if hintMethod(for: q) != nil {
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
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))

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
            guard answered else { return Color.white }
            if selected && isCorrect { return Color.tiffany.opacity(0.12) }
            if selected && !isCorrect { return Color.appGray.opacity(0.1) }
            if isCorrect { return Color.tiffany.opacity(0.07) }
            return Color.white
        }()

        let borderColor: Color = {
            guard answered else { return Color.cardBorder }
            if selected && isCorrect { return Color.tiffany }
            if selected && !isCorrect { return Color.appGray }
            if isCorrect { return Color.tiffany.opacity(0.5) }
            return Color.cardBorder
        }()

        return Button {
            vm.selectAnswer(choice.id)
        } label: {
            HStack(spacing: 12) {
                Text(choice.text)
                    .font(.subheadline)
                    .foregroundStyle(answered ? (selected || isCorrect ? Color.appText : Color.appGray) : Color.appText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if answered {
                    if selected && isCorrect {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.tiffany)
                    } else if selected && !isCorrect {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.appGray)
                    } else if isCorrect {
                        Image(systemName: "checkmark.circle").foregroundStyle(Color.tiffany)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: answered ? 1.5 : 1)
            )
        }
        .disabled(answered)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: answered)
    }
}
