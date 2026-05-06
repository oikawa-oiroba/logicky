import SwiftUI

struct DiagnosticResultView: View {
    @ObservedObject var vm: DiagnosticViewModel
    let onClose: () -> Void

    @State private var showProfileInput = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scoreCircle
                rankBadge
                if let delta = vm.scoreDelta {
                    deltaLabel(delta: delta)
                }
                axisSection
                profileSection
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appBg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ActivityView(activityItems: [img, shareText])
            }
        }
    }

    // MARK: - Score Circle

    private var scoreCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.cardBorder, lineWidth: 16)
                .frame(width: 160, height: 160)
            Circle()
                .trim(from: 0, to: CGFloat(vm.displayScore) / 100)
                .stroke(Color.tiffany, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.05), value: vm.displayScore)
            VStack(spacing: 2) {
                Text("\(vm.displayScore)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
                    .contentTransition(.numericText())
                Text("点").font(.subheadline).foregroundStyle(Color.appSub)
            }
        }
    }

    // MARK: - Rank Badge

    private var rankBadge: some View {
        let score = vm.result?.totalScore ?? 0
        return VStack(spacing: 6) {
            Text(vm.rankLabel(for: score))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())
            Text(vm.rankDescription(for: score))
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
        }
    }

    // MARK: - Delta Label

    private func deltaLabel(delta: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: delta >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
            Text(delta >= 0 ? "前回より+\(delta)点！" : "前回より\(delta)点")
            Text("成長を続けよう")
                .foregroundStyle(Color.appSub)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(delta >= 0 ? Color.tiffany : Color.appGray)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background((delta >= 0 ? Color.tiffany : Color.appGray).opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Axis Section

    private var axisSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("3軸評価")
                .font(.headline)
                .foregroundStyle(Color.appText)
            VStack(spacing: 12) {
                axisRow(label: "整理力", score: vm.result?.organizeScore ?? 0, delta: vm.organizeScoreDelta)
                axisRow(label: "推論力", score: vm.result?.reasonScore ?? 0,   delta: vm.reasonScoreDelta)
                axisRow(label: "判断力", score: vm.result?.judgeScore ?? 0,    delta: vm.judgeScoreDelta)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func axisRow(label: String, score: Int, delta: Int?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .frame(width: 38, alignment: .leading)
                if let delta {
                    HStack(spacing: 2) {
                        Image(systemName: delta >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        Text(delta >= 0 ? "+\(delta)%" : "\(delta)%")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(delta >= 0 ? Color.tiffany : Color.appGray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((delta >= 0 ? Color.tiffany : Color.appGray).opacity(0.1))
                    .clipShape(Capsule())
                }
                Spacer()
                Text("\(score)%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.tiffany)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.cardBorder).frame(height: 10)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.tiffany)
                        .frame(width: geo.size.width * CGFloat(score) / 100, height: 10)
                        .animation(.easeOut(duration: 0.8), value: score)
                }
            }
            .frame(height: 10)
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation { showProfileInput.toggle() }
            } label: {
                HStack {
                    Label("プロフィール登録（任意）", systemImage: "person.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appText)
                    Spacer()
                    Image(systemName: showProfileInput ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                }
            }
            .buttonStyle(.plain)

            if showProfileInput {
                VStack(spacing: 10) {
                    profilePicker(label: "性別", binding: $vm.profile.gender,
                                  options: ["未回答", "男性", "女性", "その他"])
                    profilePicker(label: "年齢層", binding: $vm.profile.ageGroup,
                                  options: ["未回答", "10代", "20代", "30代", "40代", "50代以上"])
                    profilePicker(label: "職種", binding: $vm.profile.position,
                                  options: ["未回答", "学生", "エンジニア", "営業", "企画・マーケ", "管理職", "その他"])
                    profilePicker(label: "業種", binding: $vm.profile.industry,
                                  options: ["未回答", "IT・テック", "金融", "メーカー", "コンサル", "医療", "その他"])

                    Button {
                        vm.updateProfile()
                        withAnimation { showProfileInput = false }
                    } label: {
                        Text("保存する")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.tiffany)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func profilePicker(label: String, binding: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appSub)
                .frame(width: 50, alignment: .leading)
            Picker(label, selection: binding) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(Color.tiffany)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                generateShareImage()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("結果をシェアする")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                onClose()
            } label: {
                Text("学習を続ける")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.tiffany, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Share

    private var shareText: String {
        let score = vm.result?.totalScore ?? 0
        let rank = vm.rankLabel(for: score)
        return "ロジッキー診断で\(score)点！ランク\(rank)でした #Logicky #論理的思考"
    }

    @MainActor
    private func generateShareImage() {
        guard let result = vm.result else { return }
        let card = ShareCardView(
            score: result.totalScore,
            rank: vm.rankLabel(for: result.totalScore),
            rankDesc: vm.rankDescription(for: result.totalScore),
            organizeScore: result.organizeScore,
            reasonScore: result.reasonScore,
            judgeScore: result.judgeScore
        )
        let renderer = ImageRenderer(content: card.frame(width: 360))
        renderer.scale = UIScreen.main.scale
        shareImage = renderer.uiImage
        showShareSheet = true
    }
}

// MARK: - Share Card View

private struct ShareCardView: View {
    let score: Int
    let rank: String
    let rankDesc: String
    let organizeScore: Int
    let reasonScore: Int
    let judgeScore: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(Color.tiffany)
                Text("ロジッキー診断")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appText)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
                Text("点")
                    .font(.title3)
                    .foregroundStyle(Color.appSub)
            }
            Text("ランク \(rank) — \(rankDesc)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())

            HStack(spacing: 20) {
                axisChip(label: "整理力", score: organizeScore)
                axisChip(label: "推論力", score: reasonScore)
                axisChip(label: "判断力", score: judgeScore)
            }
        }
        .padding(24)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.tiffany.opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func axisChip(label: String, score: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(score)%")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tiffany)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - UIActivityViewController wrapper

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
