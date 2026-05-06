import SwiftUI

struct MultipleChoiceView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var showHint = false

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 16) {
                        questionCard(question)
                        choicesList(question)
                        Spacer(minLength: 80)
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
            }
        }
    }

    private func hintMethod(for question: Question) -> ThinkingMethod? {
        guard let unitId = question.unit else { return nil }
        return ThinkingMethodService.shared.all.first { $0.unitId == unitId }
    }

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

            if hintMethod(for: question) != nil {
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    private func choicesList(_ question: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(question.choices ?? []) { choice in
                ChoiceButton(
                    choice: choice,
                    isSelected: viewModel.currentAnswer.selectedChoiceId == choice.id
                ) {
                    viewModel.selectChoice(choice.id)
                }
            }
        }
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appGray)
                }
            }

            Divider()
                .background(Color.cardBorder)

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

// MARK: - Choice Button

private struct ChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.tiffany : Color.cardBorder, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.tiffany)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(choice.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.appText)

                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.tiffany.opacity(0.07) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.tiffany : Color.cardBorder, lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
