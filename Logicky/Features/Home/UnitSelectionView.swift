import SwiftUI

struct UnitSelectionView: View {
    let levelId: Int
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    private var level: LevelModel? { LevelModel.all.first { $0.id == levelId } }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(level?.units ?? []) { unit in
                    UnitProgressCard(
                        unit: unit,
                        mcAnswered: mcAnsweredCount(for: unit),
                        mcCompleted: isMCCompleted(for: unit),
                        hasMaster: hasMasterQuestions(for: unit)
                    ) {
                        navigationPath.append(AppRoute.unitDetail(unitId: unit.id, levelId: levelId))
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(level.map { "\($0.name) · \($0.description)" } ?? "単元を選択")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    private func mcAnsweredCount(for unit: UnitModel) -> Int {
        let mcIds = Set(QuestionService.shared.questions(for: unit.id)
            .filter { $0.type == .multipleChoice }
            .map { $0.id })
        for attempt in attemptService.attempts(for: unit.id).sorted(by: { $0.date > $1.date }) {
            let answered = attempt.questionResults.filter { !$0.isSkipped && mcIds.contains($0.questionId) }
            if !answered.isEmpty { return answered.count }
        }
        return 0
    }

    private func isMCCompleted(for unit: UnitModel) -> Bool {
        // トレーニング完了＝単元の全問題を正解済み
        return SkillBadgeService.shared.isUnitCompleted(unit.id)
    }

    private func hasMasterQuestions(for unit: UnitModel) -> Bool {
        !QuestionService.shared.questions(for: unit.id).filter { $0.type == .freeText }.isEmpty
    }
}

// MARK: - Unit Progress Card

private struct UnitProgressCard: View {
    let unit: UnitModel
    let mcAnswered: Int
    let mcCompleted: Bool
    let hasMaster: Bool
    let onTap: () -> Void

    private var progress: Double {
        guard unit.totalQuestions > 0 else { return 0 }
        return Double(min(mcAnswered, unit.totalQuestions)) / Double(unit.totalQuestions)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unit.displayName)
                            .font(.headline)
                            .foregroundStyle(Color.appText)
                        Text(unit.name)
                            .font(.caption2)
                            .foregroundStyle(Color.appSub)
                    }
                    Spacer()
                    if mcCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.tiffany)
                    }
                }

                Text(unit.description)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)

                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.cardBorder)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.tiffany)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(mcCompleted ? "トレーニング完了" : "トレーニング \(mcAnswered)/\(unit.totalQuestions)")
                        .font(.caption)
                        .foregroundStyle(mcCompleted ? Color.tiffany : Color.appSub)
                }

                if mcCompleted && hasMaster {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil.and.outline")
                            .font(.caption)
                        Text("マスターに挑戦できます")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.tiffany.opacity(0.08))
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
