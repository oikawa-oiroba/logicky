import SwiftUI

struct DiagnosticHistoryDetailView: View {
    let result: DiagnosticResult
    @Binding var navigationPath: NavigationPath

    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil
    @State private var showDiagnostic = false

    private let vm = DiagnosticViewModel()

    private var prevResult: DiagnosticResult? {
        let all = DiagnosticService.shared.allResults
        guard let idx = all.firstIndex(where: { $0.id == result.id }),
              idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                dateHeader
                scoreCircle
                rankBadge
                if let prev = prevResult {
                    totalDeltaBadge(curr: result.totalScore, prev: prev.totalScore)
                }
                axisSection
                adviceSection
                profileSection
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appBg)
        .navigationTitle("診断結果詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDiagnostic) { DiagnosticStartView() }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ActivityView(activityItems: [img])
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(result.date, style: .date)
                .font(.title2.bold())
                .foregroundStyle(Color.appText)
            Text(result.date, style: .time)
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Score Circle

    private var scoreCircle: some View {
        ZStack {
            Circle().stroke(Color.cardBorder, lineWidth: 16).frame(width: 160, height: 160)
            Circle()
                .trim(from: 0, to: CGFloat(result.totalScore) / 100)
                .stroke(Color.tiffany, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(result.totalScore)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
                Text("点").font(.subheadline).foregroundStyle(Color.appSub)
            }
        }
    }

    // MARK: - Rank Badge

    private var rankBadge: some View {
        let rank = vm.rankLabel(for: result.totalScore)
        let desc = vm.rankDescription(for: result.totalScore)
        return VStack(spacing: 6) {
            Text(rank)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())
            Text(desc)
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
        }
    }

    // MARK: - Total Delta

    private func totalDeltaBadge(curr: Int, prev: Int) -> some View {
        let delta = curr - prev
        return HStack(spacing: 6) {
            Image(systemName: delta >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
            Text(delta >= 0 ? "前回より+\(delta)点！" : "前回より\(delta)点")
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
                axisRow(label: "整理力", score: result.organizeScore, prev: prevResult?.organizeScore)
                axisRow(label: "推論力", score: result.reasonScore,   prev: prevResult?.reasonScore)
                axisRow(label: "判断力", score: result.judgeScore,    prev: prevResult?.judgeScore)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func axisRow(label: String, score: Int, prev: Int?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .frame(width: 38, alignment: .leading)
                if let prev {
                    let delta = score - prev
                    HStack(spacing: 2) {
                        Image(systemName: delta >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        Text(delta >= 0 ? "+\(delta)%" : "\(delta)%")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(delta >= 0 ? Color.tiffany : Color.appGray)
                    .padding(.horizontal, 6).padding(.vertical, 2)
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
                }
            }
            .frame(height: 10)
        }
    }

    // MARK: - Advice Section

    private var adviceSection: some View {
        let scores = [
            ("整理力", result.organizeScore, "mece"),
            ("推論力", result.reasonScore,   "logic_tree"),
            ("判断力", result.judgeScore,    "fermi")
        ]
        let sorted = scores.sorted { $0.1 < $1.1 }
        let strongest = scores.max { $0.1 < $1.1 }
        let weakest = sorted.first

        return VStack(alignment: .leading, spacing: 10) {
            Text("アドバイス")
                .font(.headline)
                .foregroundStyle(Color.appText)

            if let s = strongest {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Color.tiffany)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("あなたの強み")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.tiffany)
                        Text("\(s.0)（\(s.1)%）が最も高いスコアです。この強みを活かして応用問題にも挑戦しましょう。")
                            .font(.caption)
                            .foregroundStyle(Color.appText)
                    }
                }
                .padding(10)
                .background(Color.tiffany.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let w = weakest {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "arrow.up.circle")
                        .font(.caption)
                        .foregroundStyle(Color.appSub)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("伸びしろ")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appSub)
                        Text("\(w.0)（\(w.1)%）がこの回の課題です。関連単元を復習しましょう。")
                            .font(.caption)
                            .foregroundStyle(Color.appText)
                        Button {
                            navigationPath.append(AppRoute.dictionaryList)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 10))
                                Text("思考法辞典で復習する")
                                    .font(.caption.weight(.semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9))
                            }
                            .foregroundStyle(Color.tiffany)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.tiffany.opacity(0.08))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        let p = result.profile
        guard p.gender != "未回答" || p.ageGroup != "未回答" || p.position != "未回答" || p.industry != "未回答"
        else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Label("プロフィール", systemImage: "person.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSub)
                HStack(spacing: 8) {
                    if p.gender != "未回答" { profileChip(p.gender) }
                    if p.ageGroup != "未回答" { profileChip(p.ageGroup) }
                    if p.position != "未回答" { profileChip(p.position) }
                    if p.industry != "未回答" { profileChip(p.industry) }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
        )
    }

    private func profileChip(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Color.appSub)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.appBg)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showDiagnostic = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("もう一度診断する")
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
                generateShareImage()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("結果をシェアする")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(Color.tiffany)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tiffany, lineWidth: 1))
            }

            Button {
                navigationPath = NavigationPath()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                    Text("ホームに戻る")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
    }

    @MainActor
    private func generateShareImage() {
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
