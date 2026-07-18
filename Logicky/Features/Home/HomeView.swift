import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var attemptService: AttemptService
    @EnvironmentObject var premiumService: PremiumService

    @State private var showDiagnostic = false
    @State private var skillTab: Int = 0
    @State private var showPaywall = false

    @AppStorage("logicky_nickname") private var nickname: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                logoHeader
                statusBar
                skillStatusSection
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
            DiagnosticStartView { unitId in
                startTraining(unitId: unitId)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // 無料プランは1日1トレーニングまで。超過時はペイウォールを表示
    private func startTraining(unitId: String) {
        if premiumService.canStartTrainingSession(attemptService: attemptService) {
            navigationPath.append(AppRoute.quiz(unitId: unitId, mode: .training))
        } else {
            showPaywall = true
        }
    }

    // MARK: - Skill Status Section

    private var skillStatusSection: some View {
        let strengths = viewModel.topStrengthSkills()
        let weak = viewModel.weakSkills()
        let untried = viewModel.untriedSkills()
        let hasAnyAttempt = !strengths.isEmpty || !weak.isEmpty

        if !hasAnyAttempt {
            return AnyView(
                Button {
                    showDiagnostic = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.tiffany)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("まずは診断を受けよう")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appText)
                            Text("得意・苦手スキルを発見できます")
                                .font(.caption)
                                .foregroundStyle(Color.appSub)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.tiffany)
                    }
                    .padding(16)
                    .background(Color.tiffany.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tiffany.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)
            )
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                Text("スキル状況")
                    .font(.headline)
                    .foregroundStyle(Color.appText)

                // 苦手を先頭にして、復習から入る導線にする
                Picker("タブ", selection: $skillTab) {
                    Text("苦手（\(weak.count)）").tag(0)
                    Text("未習得（\(untried.count)）").tag(1)
                    Text("得意（\(strengths.count)）").tag(2)
                }
                .pickerStyle(.segmented)

                if skillTab == 0 {
                    skillList(weak, emptyMessage: "苦手スキルはありません！", showRate: true)
                } else if skillTab == 1 {
                    skillList(untried, emptyMessage: "全単元に挑戦済みです！", showRate: false)
                } else {
                    skillList(strengths, emptyMessage: "まだ得意スキルはありません", showRate: true)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
        )
    }

    private func skillList(_ infos: [HomeViewModel.UnitSkillInfo], emptyMessage: String, showRate: Bool) -> some View {
        Group {
            if infos.isEmpty {
                Text(emptyMessage)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 6) {
                    ForEach(infos) { info in
                        Button {
                            startTraining(unitId: info.unit.id)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: badgeIcon(for: info.badge?.level))
                                    .font(.system(size: 14))
                                    .foregroundStyle(badgeColor(for: info.badge?.level))
                                    .frame(width: 20)
                                Text(info.unit.displayName)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appText)
                                Spacer()
                                if showRate, let badge = info.badge {
                                    Text("\(Int(badge.correctRate * 100))%")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(badgeColor(for: badge.level))
                                }
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.appGray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.appBg)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func badgeIcon(for level: BadgeLevel?) -> String {
        switch level {
        case .master:   return "star.fill"
        case .acquired: return "checkmark.seal.fill"
        case .learning: return "circle.dotted"
        case nil:       return "circle"
        }
    }

    private func badgeColor(for level: BadgeLevel?) -> Color {
        switch level {
        case .master:   return Color(red: 0.83, green: 0.69, blue: 0.22)
        case .acquired: return Color.tiffany
        case .learning: return Color.appSub
        case nil:       return Color.appGray
        }
    }

    // MARK: - Diagnostic Banner

    private var diagnosticBanner: some View {
        let latest = DiagnosticService.shared.latestResult
        return VStack(spacing: 0) {
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
                        if let result = latest {
                            HStack(spacing: 6) {
                                Text("前回 \(result.totalScore)点")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.tiffany)
                                Text("·")
                                    .foregroundStyle(Color.appGray)
                                Text(formattedDate(result.date))
                                    .font(.caption)
                                    .foregroundStyle(Color.appSub)
                            }
                        } else {
                            Text("まだ診断を受けていません")
                                .font(.caption)
                                .foregroundStyle(Color.appSub)
                        }
                    }
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.tiffany)
                    Text("再診断")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.tiffany)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if let result = latest {
                Divider().padding(.horizontal, 16)
                Button {
                    navigationPath.append(AppRoute.diagnosticDetail(result: result))
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                        Text("前回結果を見る（\(result.totalScore)点）")
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.tiffany)
                .frame(width: 3)
                .padding(.vertical, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M月d日"
        return f.string(from: date)
    }

    // MARK: - Logo

    private var logoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                Button {
                    navigationPath.append(AppRoute.profile)
                } label: {
                    Image(systemName: nickname.isEmpty ? "person.crop.circle.badge.plus" : "person.crop.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(nickname.isEmpty ? Color.appGray : Color.tiffany)
                }
            }

            if !nickname.isEmpty {
                Text("ようこそ！\(nickname)さん")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSub)
            }
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
                startTraining(unitId: unit.id)
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
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            QuickActionCard(icon: "book.fill", title: "学習を始める", isHighlighted: true) {
                navigationPath.append(AppRoute.categorySelection)
            }
            QuickActionCard(icon: "chart.line.uptrend.xyaxis", title: "成長記録") {
                navigationPath.append(AppRoute.history)
            }
            QuickActionCard(icon: "book.closed.fill", title: "思考法辞典") {
                navigationPath.append(AppRoute.dictionaryList)
            }
            QuickActionCard(icon: "exclamationmark.triangle.fill", title: "認知バイアス辞典") {
                navigationPath.append(AppRoute.cognitiveBiasList)
            }
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
                        isUnlocked: true
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
    var isHighlighted: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isDisabled ? Color.appGray : Color.tiffany)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isDisabled ? Color.appGray : Color.appText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isHighlighted ? Color.tiffany.opacity(0.08) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHighlighted ? Color.tiffany.opacity(0.3) : Color.cardBorder, lineWidth: isHighlighted ? 1.5 : 1)
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
