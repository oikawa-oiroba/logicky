import SwiftUI

private extension Color {
    static let appBackground = Color(red: 245/255, green: 245/255, blue: 250/255)
}

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                logoHeader
                statusBar
                todayCard
                quickActionsSection
                growthSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Logo

    private var logoHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.indigo, .purple],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("Logicky")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack(spacing: 8) {
            StatBadge(emoji: "🔥", value: viewModel.streakMessage, color: .orange)
            StatBadge(emoji: "⚡️", value: viewModel.todayScore.map { "\($0)点" } ?? "--点",
                      color: Color(red: 1, green: 0.75, blue: 0))
            StatBadge(emoji: "🧠", value: "\(viewModel.totalAnsweredCount)問", color: .indigo)
            Spacer()
        }
    }

    // MARK: - Today Card

    private var todayCard: some View {
        Group {
            if let unit = viewModel.todayUnit {
                todayCardContent(unit: unit)
            }
        }
    }

    private func todayCardContent(unit: UnitModel) -> some View {
        let levelName = LevelModel.all.first(where: { $0.id == unit.levelId })?.name ?? ""
        let answered  = viewModel.todayUnitAnsweredCount()
        let total     = viewModel.todayUnitMCCount()
        let progress  = total > 0 ? Double(answered) / Double(total) : 0.0

        return VStack(alignment: .leading, spacing: 16) {
            // タイトル
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の5問")
                    .font(.title2.bold())
                Text("思考を整えるトレーニング")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Level・単元タグ
            Text("\(levelName)：\(unit.name)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.indigo)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.indigo.opacity(0.1))
                .clipShape(Capsule())

            if viewModel.isAllUnitsCompleted {
                // 全完了状態
                Text("おめでとう！今日のトレーニング完了 🎉")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.green.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // 進捗バー
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("進捗")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(answered) / \(total)問")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemFill))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(colors: [.indigo, .purple],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }

            // CTAボタン
            Button {
                navigationPath.append(AppRoute.quiz(unitId: unit.id, mode: .training))
            } label: {
                HStack(spacing: 6) {
                    Text(viewModel.isAllUnitsCompleted ? "再挑戦する" : "始める")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.indigo, .purple],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionCard(emoji: "📖", title: "思考法辞典", bgColor: Color.indigo.opacity(0.08)) {
                navigationPath.append(AppRoute.dictionaryList)
            }
            QuickActionCard(emoji: "📈", title: "成長記録", bgColor: Color.teal.opacity(0.08)) {
                navigationPath.append(AppRoute.history)
            }
            QuickActionCard(emoji: "🏆", title: "実績", bgColor: Color(.systemFill), isDisabled: true) {}
        }
    }

    // MARK: - Growth Section

    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("あなたの成長")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(LevelModel.all) { level in
                    LevelProgressRow(
                        abilityName: viewModel.abilityName(for: level),
                        levelName: level.name,
                        progress: viewModel.levelProgress(for: level),
                        isUnlocked: viewModel.isLevelUnlocked(level)
                    ) {
                        navigationPath.append(AppRoute.unitSelection(levelId: level.id))
                    }
                }
            }
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let emoji: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji).font(.system(size: 13))
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Quick Action Card

private struct QuickActionCard: View {
    let emoji: String
    let title: String
    let bgColor: Color
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 28))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                if isDisabled {
                    Text("Coming Soon")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .buttonStyle(.plain)
    }
}

// MARK: - Level Progress Row

private struct LevelProgressRow: View {
    let abilityName: String
    let levelName: String
    let progress: Double
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(abilityName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isUnlocked ? .primary : .secondary)
                        Text(levelName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if isUnlocked {
                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(progress >= 1.0 ? .green : .indigo)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("ロック中")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(isUnlocked ? Color(.tertiaryLabel) : .clear)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemFill))
                            .frame(height: 8)
                        if isUnlocked && progress > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progress >= 1.0 ? Color.green : Color.indigo)
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                }
                .frame(height: 8)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isUnlocked)
        .buttonStyle(.plain)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
