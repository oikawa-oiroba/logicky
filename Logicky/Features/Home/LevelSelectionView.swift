import SwiftUI

struct LevelSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(LevelModel.all) { level in
                    let unlocked = isLevelUnlocked(level)
                    LevelCard(
                        level: level,
                        completedUnits: completedUnitCount(for: level),
                        isUnlocked: unlocked
                    ) {
                        if unlocked {
                            navigationPath.append(AppRoute.unitSelection(levelId: level.id))
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("レベルを選択")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    private func isLevelUnlocked(_ level: LevelModel) -> Bool {
        if level.id == 1 { return true }
        guard let prev = LevelModel.all.first(where: { $0.id == level.id - 1 }) else { return false }
        return prev.units.allSatisfy { isMCCompleted($0) }
    }

    private func completedUnitCount(for level: LevelModel) -> Int {
        level.units.filter { isMCCompleted($0) }.count
    }

    private func isMCCompleted(_ unit: UnitModel) -> Bool {
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
}

// MARK: - Level Card

private struct LevelCard: View {
    let level: LevelModel
    let completedUnits: Int
    let isUnlocked: Bool
    let onTap: () -> Void

    private var totalUnits: Int { level.units.count }
    private var progress: Double {
        guard totalUnits > 0 else { return 0 }
        return Double(completedUnits) / Double(totalUnits)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                levelBadge

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(level.name)
                            .font(.headline)
                            .foregroundStyle(isUnlocked ? Color.appText : Color.appGray)
                        Text(level.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.appSub)
                        Spacer()
                        Text("\(completedUnits)/\(totalUnits) 単元")
                            .font(.caption)
                            .foregroundStyle(Color.appSub)
                    }

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

                    if !isUnlocked {
                        Text("前のレベルをすべてクリアすると解放されます")
                            .font(.caption)
                            .foregroundStyle(Color.appGray)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isUnlocked ? Color.cardBorder : Color.cardBorder.opacity(0.5), lineWidth: 1)
            )
            .opacity(isUnlocked ? 1.0 : 0.55)
        }
        .disabled(!isUnlocked)
        .buttonStyle(.plain)
    }

    private var levelBadge: some View {
        ZStack {
            Circle()
                .fill(isUnlocked ? Color.tiffany.opacity(0.1) : Color.cardBorder)
                .frame(width: 52, height: 52)
            if isUnlocked {
                Text("\(level.id)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.appGray)
            }
        }
    }
}
