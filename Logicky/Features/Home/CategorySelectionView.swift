import SwiftUI

struct CategorySelectionView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                categoryCard(
                    title: "思考の基本スキル",
                    subtitle: "考え方のキホンを身につける",
                    icon: "brain",
                    unitCount: UnitModel.basic.count,
                    completedCount: basicCompletedCount,
                    accentColor: Color.tiffany
                ) {
                    navigationPath.append(AppRoute.unitSelection(levelId: 0))
                }

                categoryCard(
                    title: "ビジネスフレームワーク",
                    subtitle: "実務で使える分析手法を学ぶ",
                    icon: "chart.bar.xaxis",
                    unitCount: UnitModel.practical.count,
                    completedCount: practicalCompletedCount,
                    accentColor: Color.appGray
                ) {
                    navigationPath.append(AppRoute.levelSelection)
                }
            }
            .padding(20)
        }
        .navigationTitle("学ぶカテゴリを選択")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    private var basicCompletedCount: Int {
        UnitModel.basic.filter { isMCCompleted($0) }.count
    }

    private var practicalCompletedCount: Int {
        UnitModel.practical.filter { isMCCompleted($0) }.count
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

    private func categoryCard(title: String, subtitle: String, icon: String, unitCount: Int, completedCount: Int, accentColor: Color, onTap: @escaping () -> Void) -> some View {
        let progress = unitCount > 0 ? Double(completedCount) / Double(unitCount) : 0.0
        return Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(accentColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color.appText)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.appSub)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appGray)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(completedCount) / \(unitCount) 単元クリア")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(accentColor)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(accentColor)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.cardBorder).frame(height: 6)
                            RoundedRectangle(cornerRadius: 3).fill(accentColor)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2).fill(accentColor).frame(width: 4)
                    .padding(.vertical, 12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
