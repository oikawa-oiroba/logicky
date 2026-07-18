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
        // クリア判定＝正答率80%以上のセッション達成
        guard let unit else { return false }
        return SkillBadgeService.shared.clearedUnitIds.contains(unit.id)
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
                        questionListCard(unit: unit)
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

    // MARK: - Question List（未着手・不正解を優先的に把握できる一覧）

    private func questionListCard(unit: UnitModel) -> some View {
        let questions = QuestionService.shared.trainingQuestions(for: unit.id)
        let correctness = attemptService.latestCorrectness(for: unit.id)
        let unansweredCount = questions.filter { correctness[$0.id] == nil }.count
        let wrongCount = questions.filter { correctness[$0.id] == false }.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("問題リスト")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                Spacer()
                Text("全\(questions.count)問")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if unansweredCount > 0 || wrongCount > 0 {
                Text("未挑戦\(unansweredCount)問・要復習\(wrongCount)問。トレーニングでは未挑戦→不正解の順に優先して出題されます")
                    .font(.caption2)
                    .foregroundStyle(Color.appSub)
            }

            VStack(spacing: 6) {
                ForEach(Array(questions.enumerated()), id: \.element.id) { index, q in
                    HStack(spacing: 10) {
                        statusIcon(for: correctness[q.id])
                        Text("Q\(index + 1)  \(q.body)")
                            .font(.caption)
                            .foregroundStyle(correctness[q.id] == true ? Color.appGray : Color.appText)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func statusIcon(for correct: Bool?) -> some View {
        switch correct {
        case .some(true):
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color.tiffany)
        case .some(false):
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 243/255, green: 183/255, blue: 32/255))
        case .none:
            Image(systemName: "circle.dashed")
                .font(.system(size: 15))
                .foregroundStyle(Color.appGray)
        }
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
