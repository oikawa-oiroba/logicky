import SwiftUI

struct UnitDetailView: View {
    let unitId: String
    let levelId: Int
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService
    @EnvironmentObject var premiumService: PremiumService
    @State private var showPaywall = false

    private var unit: UnitModel? { UnitModel.all.first { $0.id == unitId } }

    private var mcCompleted: Bool {
        guard let unit else { return false }
        let mcQuestions = QuestionService.shared.questions(for: unit.id).filter { $0.type == .multipleChoice }
        guard !mcQuestions.isEmpty else { return false }
        let mcIds = Set(mcQuestions.map { $0.id })
        return attemptService.attempts(for: unit.id).contains { attempt in
            let answeredIds = Set(attempt.questionResults
                .filter { !$0.isSkipped && mcIds.contains($0.questionId) }
                .map { $0.questionId })
            return answeredIds.count >= mcQuestions.count
        }
    }

    private var hasMasterMode: Bool {
        guard let unit else { return false }
        return !QuestionService.shared.questions(for: unit.id).filter { $0.type == .freeText }.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let unit {
                        Text(unit.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 4)

                        modeInfoCard(unit: unit)
                    }
                    Spacer(minLength: 120)
                }
                .padding(24)
            }

            actionButtons
        }
        .navigationTitle(unit?.displayName ?? "")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Mode Info

    private func modeInfoCard(unit: UnitModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("トレーニングモード", systemImage: "4.square.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                Spacer()
                Text("4択・1回5問")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if mcCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.tiffany)
                    Text("トレーニング完了！")
                        .font(.subheadline)
                        .foregroundStyle(Color.tiffany)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 12) {
                Button {
                    if premiumService.canStartTrainingSession(attemptService: attemptService) {
                        navigationPath.append(AppRoute.quiz(unitId: unitId, mode: .training))
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Text(mcCompleted ? "もう一度トレーニング" : "トレーニング開始")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tiffany)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
}
