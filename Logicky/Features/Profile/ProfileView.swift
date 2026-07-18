import SwiftUI

struct ProfileView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var attemptService: AttemptService
    @EnvironmentObject var premiumService: PremiumService

    @AppStorage("logicky_nickname") private var nickname: String = ""
    @State private var nicknameDraft = ""
    @State private var editingNickname = false
    @State private var showPaywall = false

    // 総合ロジカルスコア：全トレーニングのスコア累計
    private var totalLogicalScore: Int {
        attemptService.attempts.reduce(0) { $0 + $1.totalScore }
    }

    private var totalAnswered: Int {
        attemptService.attempts.reduce(0) { sum, attempt in
            sum + attempt.questionResults.filter { !$0.isSkipped }.count
        }
    }

    private var studyDays: Int {
        let calendar = Calendar.current
        return Set(attemptService.attempts.map { calendar.startOfDay(for: $0.date) }).count
    }

    private var badgeCount: Int {
        UnitModel.all.filter { SkillBadgeService.shared.badge(for: $0) != nil }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                nicknameCard
                scoreCard
                statsGrid
                premiumCard
            }
            .padding(20)
        }
        .background(Color.appBg)
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("ニックネーム", isPresented: $editingNickname) {
            TextField("ニックネーム", text: $nicknameDraft)
            Button("保存") {
                nickname = String(nicknameDraft.trimmingCharacters(in: .whitespacesAndNewlines).prefix(12))
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ホーム画面とシェアカードに表示されます")
        }
    }

    private var nicknameCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.tiffany.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.tiffany)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(nickname.isEmpty ? "ニックネーム未設定" : nickname)
                    .font(.headline)
                    .foregroundStyle(nickname.isEmpty ? Color.appGray : Color.appText)
                Text(premiumService.isPremium ? "プレミアム会員" : "無料プラン")
                    .font(.caption)
                    .foregroundStyle(premiumService.isPremium ? Color.tiffany : Color.appSub)
            }
            Spacer()
            Button {
                nicknameDraft = nickname
                editingNickname = true
            } label: {
                Text("編集")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.tiffany.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
    }

    private var scoreCard: some View {
        VStack(spacing: 6) {
            Text("総合ロジカルスコア")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appSub)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(totalLogicalScore)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
                    .contentTransition(.numericText())
                Text("pt")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSub)
            }
            Text("トレーニングのスコア累計。学ぶほど積み上がります")
                .font(.caption2)
                .foregroundStyle(Color.appGray)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
    }

    private var statsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            statCell(icon: "checkmark.circle.fill", value: "\(totalAnswered)", label: "累計回答数")
            statCell(icon: "calendar", value: "\(studyDays)日", label: "学習日数")
            Button {
                navigationPath.append(AppRoute.badges)
            } label: {
                statCell(icon: "rosette", value: "\(badgeCount)個", label: "獲得バッジ →")
            }
            .buttonStyle(.plain)
            statCell(icon: "flame.fill", value: "\(streakDays)日", label: "連続学習")
        }
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        let hasToday = attemptService.attempts.contains { calendar.isDateInToday($0.date) }
        if !hasToday {
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

    private func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.tiffany)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.appText)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private var premiumCard: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(premiumService.isPremium ? Color.tiffany : .white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(premiumService.isPremium
                         ? "プレミアム有効"
                         : PremiumService.freePromotionActive
                            ? "プレミアム機能・現在無料開放中"
                            : "プレミアムにアップグレード")
                        .font(.subheadline.weight(.bold))
                    Text(premiumService.isPremium
                         ? "ご利用ありがとうございます"
                         : PremiumService.freePromotionActive
                            ? "正式版では月額980円（初月無料）の予定"
                            : "トレーニングやり放題・月額980円（初月無料）")
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(premiumService.isPremium ? Color.appText : .white)
            .padding(16)
            .background(premiumService.isPremium ? Color.white : Color.tiffany)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(premiumService.isPremium ? Color.tiffany.opacity(0.4) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
