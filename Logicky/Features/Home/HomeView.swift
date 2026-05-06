import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = HomeViewModel()

    @State private var showDiagnostic = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                logoHeader
                statusBar
                diagnosticBanner
                todayCard
                quickActionsSection
                growthSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.appBg)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showDiagnostic) {
            DiagnosticStartView()
        }
    }

    // MARK: - Diagnostic Banner

    private var diagnosticBanner: some View {
        Button {
            showDiagnostic = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "target")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.tiffany)
                VStack(alignment: .leading, spacing: 2) {
                    Text("ロジッキー診断")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appText)
                    Text("5分でわかる！あなたの思考力レベル")
                        .font(.caption)
                        .foregroundStyle(Color.appSub)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.tiffany)
                    .frame(width: 3)
                    .padding(.vertical, 8)
                    .offset(x: 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logo

    private var logoHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.tiffany)
                Text("Logicky")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.appText)
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack(spacing: 8) {
            StatBadge(icon: "flame.fill", value: viewModel.streakMessage)
            StatBadge(icon: "star.fill", value: viewModel.todayScore.map { "\($0)点" } ?? "--点")
            StatBadge(icon: "brain.head.profile", value: "\(viewModel.totalAnsweredCount)問")
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
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の5問")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appText)
                Text("思考を整えるトレーニング")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSub)
            }

            Text("\(levelName)：\(unit.displayName)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())

            if viewModel.isAllUnitsCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.tiffany)
                    Text("今日のトレーニング完了！")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.tiffany)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.tiffany.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("進捗")
                            .font(.caption)
                            .foregroundStyle(Color.appSub)
                        Spacer()
                        Text("\(answered) / \(total)問")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appSub)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.cardBorder)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.tiffany)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }

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
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionCard(icon: "book.fill", title: "思考法辞典") {
                navigationPath.append(AppRoute.dictionaryList)
            }
            QuickActionCard(icon: "chart.line.uptrend.xyaxis", title: "成長記録") {
                navigationPath.append(AppRoute.history)
            }
            QuickActionCard(icon: "trophy.fill", title: "実績", isDisabled: true) {}
        }
    }

    // MARK: - Growth Section

    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("あなたの成長")
                .font(.headline)
                .foregroundStyle(Color.appText)

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
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(Color.tiffany)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appSub)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - Quick Action Card

private struct QuickActionCard: View {
    let icon: String
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isDisabled ? Color.appGray : Color.tiffany)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isDisabled ? Color.appGray : Color.appText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                if isDisabled {
                    Text("Coming Soon")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appGray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
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
                            .foregroundStyle(isUnlocked ? Color.appText : Color.appGray)
                        Text(levelName)
                            .font(.caption2)
                            .foregroundStyle(Color.appSub)
                    }
                    Spacer()
                    if isUnlocked {
                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(progress >= 1.0 ? Color.tiffany : Color.appSub)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("ロック中")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.appGray)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(isUnlocked ? Color.appGray : .clear)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.cardBorder)
                            .frame(height: 6)
                        if isUnlocked && progress > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.tiffany)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                }
                .frame(height: 6)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
        .disabled(!isUnlocked)
        .buttonStyle(.plain)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
