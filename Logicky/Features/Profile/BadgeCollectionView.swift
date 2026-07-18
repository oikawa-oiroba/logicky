import SwiftUI

/// バッジコレクション。スキルバッジ（単元ごと）と実績バッジ（累計pt・連続学習など）。
/// 未獲得のバッジもグレー表示で「あと何をすれば獲得できるか」が分かる。
struct BadgeCollectionView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                skillBadgeSection
                achievementSection
            }
            .padding(20)
        }
        .background(Color.appBg)
        .navigationTitle("バッジ")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Skill Badges

    private enum SkillState {
        case none, cleared, acquired
    }

    private func skillState(for unit: UnitModel) -> SkillState {
        if let badge = SkillBadgeService.shared.badge(for: unit), badge.level != .learning {
            return .acquired
        }
        if SkillBadgeService.shared.clearedUnitIds.contains(unit.id) {
            return .cleared
        }
        return .none
    }

    private var skillBadgeSection: some View {
        let clearedCount = UnitModel.all.filter { skillState(for: $0) != .none }.count
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("スキルバッジ")
                    .font(.headline)
                    .foregroundStyle(Color.appText)
                Spacer()
                Text("\(clearedCount) / \(UnitModel.all.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appSub)
            }
            Text("セッション正答率80%でクリア。単元の全問題に正解で「習得」バッジ獲得")
                .font(.caption2)
                .foregroundStyle(Color.appGray)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(UnitModel.all) { unit in
                    let state = skillState(for: unit)
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(state == .none ? Color.appBg : Color.tiffany.opacity(state == .acquired ? 0.15 : 0.08))
                                .frame(width: 52, height: 52)
                            Image(systemName: state == .acquired ? "checkmark.seal.fill" : "rosette")
                                .font(.system(size: 22))
                                .foregroundStyle(state == .none ? Color.cardBorder : Color.tiffany)
                        }
                        Text(unit.displayName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(state == .none ? Color.appGray : Color.appText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 26, alignment: .top)
                        Text(state == .acquired ? "習得" : state == .cleared ? "クリア" : "未獲得")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(state == .none ? Color.appGray : Color.tiffany)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background((state == .none ? Color.appGray : Color.tiffany).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
                    .opacity(state == .none ? 0.75 : 1)
                }
            }
        }
    }

    // MARK: - Achievement Badges

    private struct Achievement: Identifiable {
        let id: String
        let icon: String
        let title: String
        let condition: String
        let achieved: Bool
        let progressText: String?
    }

    private var totalPoints: Int {
        attemptService.attempts.reduce(0) { $0 + $1.totalScore }
    }

    private var totalAnswered: Int {
        attemptService.attempts.reduce(0) { sum, a in
            sum + a.questionResults.filter { !$0.isSkipped }.count
        }
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        if !attemptService.attempts.contains(where: { calendar.isDateInToday($0.date) }) {
            guard let y = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = y
        }
        var streak = 0
        while attemptService.attempts.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private var maxStreakEver: Int {
        // 記録上の最長連続（全attemptsの日付集合から計算）
        let calendar = Calendar.current
        let days = Set(attemptService.attempts.map { calendar.startOfDay(for: $0.date) }).sorted()
        var best = 0
        var current = 0
        var prev: Date? = nil
        for day in days {
            if let p = prev, calendar.date(byAdding: .day, value: 1, to: p) == day {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
            prev = day
        }
        return best
    }

    private var clearedCount: Int {
        UnitModel.all.filter { skillState(for: $0) != .none }.count
    }

    private var diagnosticCount: Int {
        DiagnosticService.shared.allResults.count
    }

    private var achievements: [Achievement] {
        let pt = totalPoints
        let ans = totalAnswered
        let streak = maxStreakEver
        let cleared = clearedCount
        let diag = diagnosticCount

        func progress(_ current: Int, _ target: Int, unit: String) -> String? {
            current >= target ? nil : "\(current) / \(target)\(unit)"
        }

        return [
            Achievement(id: "first_step", icon: "figure.walk", title: "はじめの一歩",
                        condition: "初めてトレーニングを完了", achieved: !attemptService.attempts.isEmpty,
                        progressText: nil),
            Achievement(id: "first_diag", icon: "brain.head.profile", title: "自分を知る",
                        condition: "ロジッキー診断を完了", achieved: diag >= 1, progressText: nil),
            Achievement(id: "pt500", icon: "star.fill", title: "500pt達成",
                        condition: "総合ロジカルスコア500pt", achieved: pt >= 500,
                        progressText: progress(pt, 500, unit: "pt")),
            Achievement(id: "pt1000", icon: "star.circle.fill", title: "1,000pt達成",
                        condition: "総合ロジカルスコア1,000pt", achieved: pt >= 1000,
                        progressText: progress(pt, 1000, unit: "pt")),
            Achievement(id: "pt5000", icon: "sparkles", title: "5,000pt達成",
                        condition: "総合ロジカルスコア5,000pt", achieved: pt >= 5000,
                        progressText: progress(pt, 5000, unit: "pt")),
            Achievement(id: "streak3", icon: "flame", title: "3日連続",
                        condition: "3日連続で学習", achieved: streak >= 3,
                        progressText: progress(streak, 3, unit: "日")),
            Achievement(id: "streak10", icon: "flame.fill", title: "10日連続",
                        condition: "10日連続で学習", achieved: streak >= 10,
                        progressText: progress(streak, 10, unit: "日")),
            Achievement(id: "streak30", icon: "calendar.badge.checkmark", title: "習慣の達人",
                        condition: "30日連続で学習", achieved: streak >= 30,
                        progressText: progress(streak, 30, unit: "日")),
            Achievement(id: "ans100", icon: "checkmark.circle.fill", title: "100問クリア",
                        condition: "累計100問に回答", achieved: ans >= 100,
                        progressText: progress(ans, 100, unit: "問")),
            Achievement(id: "ans500", icon: "checkmark.seal.fill", title: "500問クリア",
                        condition: "累計500問に回答", achieved: ans >= 500,
                        progressText: progress(ans, 500, unit: "問")),
            Achievement(id: "basic_complete", icon: "book.closed.fill", title: "基礎マスター",
                        condition: "基礎編14単元をすべてクリア",
                        achieved: UnitModel.basic.allSatisfy { skillState(for: $0) != .none },
                        progressText: progress(UnitModel.basic.filter { skillState(for: $0) != .none }.count, UnitModel.basic.count, unit: "単元")),
            Achievement(id: "all_complete", icon: "crown.fill", title: "全単元制覇",
                        condition: "全\(UnitModel.all.count)単元をクリア", achieved: cleared >= UnitModel.all.count,
                        progressText: progress(cleared, UnitModel.all.count, unit: "単元")),
        ]
    }

    private var achievementSection: some View {
        let list = achievements
        let achievedCount = list.filter { $0.achieved }.count
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("実績バッジ")
                    .font(.headline)
                    .foregroundStyle(Color.appText)
                Spacer()
                Text("\(achievedCount) / \(list.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appSub)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(list) { a in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(a.achieved ? Color.tiffany.opacity(0.12) : Color.appBg)
                                .frame(width: 42, height: 42)
                            Image(systemName: a.icon)
                                .font(.system(size: 17))
                                .foregroundStyle(a.achieved ? Color.tiffany : Color.cardBorder)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(a.achieved ? Color.appText : Color.appGray)
                                .lineLimit(1)
                            Text(a.progressText ?? a.condition)
                                .font(.system(size: 9))
                                .foregroundStyle(Color.appGray)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(a.achieved ? Color.tiffany.opacity(0.35) : Color.cardBorder, lineWidth: 1))
                    .opacity(a.achieved ? 1 : 0.8)
                }
            }
        }
    }
}
