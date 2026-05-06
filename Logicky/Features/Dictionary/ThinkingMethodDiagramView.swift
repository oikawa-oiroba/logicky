import SwiftUI

struct ThinkingMethodDiagramView: View {
    let method: ThinkingMethod

    var body: some View {
        Group {
            switch method.id {
            case "mece":              MECEDiagram()
            case "deduction":         SyllogismDiagram()
            case "syllogism":         SyllogismDiagram()
            case "fact_opinion":      FactOpinionDiagram()
            case "logic_tree":        LogicTreeDiagram()
            case "3c":                ThreeCDiagram()
            case "5w2h":              FiveW2HDiagram()
            case "fermi":             FermiDiagram()
            case "causality":         CausalityDiagram()
            case "causation":         CausalityDiagram()
            case "critical":          CriticalDiagram()
            case "pyramid_principle": PyramidDiagram()
            case "pyramid":           PyramidPrincipleDiagram()
            case "so_what":           SoWhatDiagram()
            case "4p":                FourPDiagram()
            case "matrix":            MatrixDiagram()
            case "profit_tree":       ProfitTreeDiagram()
            case "sanity_check":      SanityCheckDiagram()
            case "grouping":          GroupingDiagram()
            case "why_deep":          WhyDeepDiagram()
            case "induction":         InductionDiagram()
            case "analogy":           AnalogyDiagram()
            case "comparison":        ComparisonDiagram()
            case "abstraction":       AbstractionDiagram()
            case "hypothesis":        HypothesisDiagram()
            case "whole_part":        WholePartDiagram()
            case "sequencing":        SequencingDiagram()
            default:                  EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - MECE

private struct MECEDiagram: View {
    var body: some View {
        HStack(spacing: 16) {
            diagramSide(title: "良い例", checkmark: true, color: .tiffany,
                        items: ["国産フルーツ", "輸入フルーツ"],
                        note: "重なりなし・漏れなし")
            diagramSide(title: "悪い例", checkmark: false, color: .appGray,
                        items: ["りんご", "輸入フルーツ"],
                        note: "輸入りんごが重複")
        }
    }

    private func diagramSide(title: String, checkmark: Bool, color: Color, items: [String], note: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: checkmark ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
            }
            VStack(spacing: 3) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(color.opacity(0.4), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            Text(note)
                .font(.system(size: 9))
                .foregroundStyle(color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 三段論法（旧: 演繹法）

private struct DeductionDiagram: View {
    var body: some View { SyllogismDiagram() }
}

private struct SyllogismDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            flowBox(label: "前提①", text: "すべての人間は死ぬ", style: .sub)
            arrowDown
            flowBox(label: "前提②", text: "ソクラテスは人間だ", style: .sub)
            arrowDown
            flowBox(label: "結　論", text: "ソクラテスは死ぬ", style: .accent)
        }
    }

    private enum BoxStyle { case sub, accent }

    private func flowBox(label: String, text: String, style: BoxStyle) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(style == .accent ? Color.tiffany : Color.appSub)
                .frame(width: 40)
            Text(text)
                .font(style == .accent ? .caption.weight(.bold) : .caption)
                .foregroundStyle(style == .accent ? Color.tiffany : Color.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(style == .accent ? Color.tiffany.opacity(0.08) : Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var arrowDown: some View {
        Image(systemName: "arrow.down")
            .font(.caption)
            .foregroundStyle(Color.appGray)
    }
}

// MARK: - 事実と意見

private struct FactOpinionDiagram: View {
    var body: some View {
        HStack(spacing: 12) {
            column(title: "事実", icon: "checkmark.circle.fill", color: .tiffany,
                   examples: ["来場者 100名", "売上 +15%", "クレーム 3件"])
            column(title: "意見", icon: "quote.bubble.fill", color: .appGray,
                   examples: ["大盛況だった", "順調に伸びてる", "問題ない水準"])
        }
    }

    private func column(title: String, icon: String, color: Color, examples: [String]) -> some View {
        VStack(spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            VStack(spacing: 4) {
                ForEach(examples, id: \.self) { ex in
                    Text(ex)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ロジックツリー

private struct LogicTreeDiagram: View {
    var body: some View {
        VStack(spacing: 0) {
            treeNode(text: "売上低下", level: 0)
            HStack(spacing: 0) {
                Spacer()
                branchLine
                branchLine
                Spacer()
            }
            HStack(spacing: 8) {
                treeNode(text: "客数減少", level: 1)
                treeNode(text: "客単価低下", level: 1)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                branchLine
                Spacer(minLength: 20)
                branchLine
                Spacer(minLength: 0)
            }
            HStack(spacing: 4) {
                treeNode(text: "新規減", level: 2)
                treeNode(text: "離脱増", level: 2)
                Spacer()
                treeNode(text: "値引き増", level: 2)
            }
        }
    }

    private var branchLine: some View {
        Rectangle()
            .fill(Color.cardBorder)
            .frame(width: 1, height: 12)
    }

    private func treeNode(text: String, level: Int) -> some View {
        Text(text)
            .font(.system(size: level == 0 ? 12 : (level == 1 ? 10 : 9), weight: level == 0 ? .bold : .regular))
            .foregroundStyle(level == 0 ? .white : Color.tiffany)
            .padding(.horizontal, level == 0 ? 12 : 6)
            .padding(.vertical, level == 0 ? 6 : 4)
            .background(level == 0 ? Color.tiffany : Color.tiffany.opacity(0.1 + Double(2 - level) * 0.04))
            .clipShape(RoundedRectangle(cornerRadius: level == 0 ? 8 : 6))
    }
}

// MARK: - 3C分析

private struct ThreeCDiagram: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                circleCard(label: "Customer", subtitle: "顧客")
                circleCard(label: "Competitor", subtitle: "競合")
                circleCard(label: "Company", subtitle: "自社")
            }
            HStack(spacing: 6) {
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
                Text("3つの視点を重ねると")
                    .font(.caption2)
                    .foregroundStyle(Color.appSub)
            }
            Text("「勝てるポイント」が見える")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    private func circleCard(label: String, subtitle: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.tiffany)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.tiffany.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - 5W2H

private struct FiveW2HDiagram: View {
    private let items: [(String, String)] = [
        ("Why", "なぜ"),
        ("What", "何を"),
        ("When", "いつ"),
        ("Where", "どこで"),
        ("Who", "誰が"),
        ("How", "どうやって"),
        ("How much", "いくらで"),
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    if i < 4 { row(item: item) }
                }
            }
            VStack(spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    if i >= 4 { row(item: item) }
                }
            }
        }
    }

    private func row(item: (String, String)) -> some View {
        HStack(spacing: 4) {
            Text(item.0)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.tiffany)
                .frame(width: 44, alignment: .leading)
            Text(item.1)
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tiffany.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - フェルミ推定

private struct FermiDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("市場規模の推定式")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appSub)
            HStack(spacing: 4) {
                formulaBox("世帯数")
                Text("×").font(.caption).foregroundStyle(Color.appGray)
                formulaBox("利用率")
                Text("×").font(.caption).foregroundStyle(Color.appGray)
                formulaBox("頻度")
                Text("×").font(.caption).foregroundStyle(Color.appGray)
                formulaBox("単価")
            }
            HStack(spacing: 4) {
                Image(systemName: "equal")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
                Text("市場規模")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.tiffany)
            }
            Text("正確さより「筋道立てた分解」が大事")
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
    }

    private func formulaBox(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(Color.tiffany)
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
            .background(Color.tiffany.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - 因果関係

private struct CausalityDiagram: View {
    var body: some View {
        VStack(spacing: 12) {
            patternRow(label: "因果関係", a: "暑い夏", arrow: "→", b: "アイス売れる",
                       color: .tiffany, note: "A が B を引き起こす")
            patternRow(label: "相関だけ", a: "アイス売れる", arrow: "↔", b: "溺死増える",
                       color: .appGray, note: "どちらも「夏」が原因（第3要因）")
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
                Text("相関＝因果とは限らない！")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appGray)
            }
        }
    }

    private func patternRow(label: String, a: String, arrow: String, b: String, color: Color, note: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            HStack(spacing: 6) {
                nodeBox(a, color: color)
                Text(arrow).font(.caption).foregroundStyle(color)
                nodeBox(b, color: color)
            }
            Text(note).font(.system(size: 9)).foregroundStyle(Color.appSub)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func nodeBox(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - 批判的思考

private struct CriticalDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("「◯◯を食べると健康になる」")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appText)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 6) {
                questionBubble("サンプル数は？")
                questionBubble("比較対照ある？")
                questionBubble("誰が資金提供？")
            }

            Text("主張を鵜呑みにせず問い直す")
                .font(.caption2)
                .foregroundStyle(Color.appSub)
        }
    }

    private func questionBubble(_ text: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: "questionmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color.tiffany)
            Text(text)
                .font(.system(size: 9))
                .foregroundStyle(Color.tiffany)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.tiffany.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - ピラミッド原則

private struct PyramidDiagram: View {
    var body: some View {
        VStack(spacing: 4) {
            pyramidRow(text: "結　論", isBold: true)
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(Color.appGray)
            HStack(spacing: 6) {
                pyramidRow(text: "理由①", isBold: false)
                pyramidRow(text: "理由②", isBold: false)
                pyramidRow(text: "理由③", isBold: false)
            }
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(Color.appGray)
            HStack(spacing: 4) {
                pyramidRow(text: "根拠・データ・例示", isBold: false)
            }
            Text("「結論 → 理由 → 詳細」の順で伝える")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .padding(.top, 4)
        }
    }

    private func pyramidRow(text: String, isBold: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: isBold ? .bold : .regular))
            .foregroundStyle(isBold ? .white : Color.tiffany)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isBold ? Color.tiffany : Color.tiffany.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - 4P分析

private struct FourPDiagram: View {
    private let items: [(String, String, String)] = [
        ("Product", "製　品", "何を売るか"),
        ("Price", "価　格", "いくらで"),
        ("Place", "流通・場所", "どこで"),
        ("Promotion", "販　促", "どう知らせる"),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 3) {
                    Text(item.0)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    Text(item.1)
                        .font(.caption2)
                        .foregroundStyle(Color.appText)
                    Text(item.2)
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appSub)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.tiffany.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tiffany.opacity(0.2), lineWidth: 1))
            }
        }
    }
}

// MARK: - マトリックス分析

private struct MatrixDiagram: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Spacer(minLength: 30)
                Text("緊急度　低 ←───→ 高")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appSub)
            }
            HStack(spacing: 4) {
                VStack {
                    Text("重")
                    Text("要")
                    Text("度")
                    Text("↕")
                }
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .frame(width: 16)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                    cell(text: "計画的に実施", sub: "重要・非緊急", bold: false)
                    cell(text: "最優先！", sub: "重要・緊急", bold: true)
                    cell(text: "後回しor委任", sub: "非重要・非緊急", bold: false, muted: true)
                    cell(text: "すぐ対処", sub: "非重要・緊急", bold: false)
                }
            }
        }
    }

    private func cell(text: String, sub: String, bold: Bool, muted: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.system(size: bold ? 10 : 9, weight: bold ? .bold : .regular))
                .foregroundStyle(bold ? .white : (muted ? Color.appGray : Color.tiffany))
                .multilineTextAlignment(.center)
            Text(sub)
                .font(.system(size: 8))
                .foregroundStyle(bold ? .white.opacity(0.8) : Color.appSub)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(bold ? Color.tiffany : (muted ? Color.appBg : Color.tiffany.opacity(0.08)))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - ピラミッド原則（単元版）

private struct PyramidPrincipleDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            // 頂点: 結論
            pyramidTier(texts: ["結論"], style: .top)
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(Color.appGray)
            // 中段: 理由
            pyramidTier(texts: ["理由 A", "理由 B"], style: .mid)
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(Color.appGray)
            // 下段: 根拠
            pyramidTier(texts: ["根拠1", "根拠2", "根拠3"], style: .base)
            Text("上から「結論 → 理由 → 根拠」の順")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .padding(.top, 4)
        }
    }

    private enum TierStyle { case top, mid, base }

    private func pyramidTier(texts: [String], style: TierStyle) -> some View {
        HStack(spacing: 4) {
            ForEach(texts, id: \.self) { text in
                Text(text)
                    .font(.system(size: style == .top ? 12 : 10, weight: style == .top ? .bold : .regular))
                    .foregroundStyle(style == .top ? .white : (style == .mid ? Color.tiffany : Color.appSub))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, style == .top ? 8 : 6)
                    .background(
                        style == .top ? Color.tiffany :
                        style == .mid ? Color.tiffany.opacity(0.12) :
                        Color.appBg
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(style == .base ? Color.cardBorder : Color.clear, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - So What?

private struct SoWhatDiagram: View {
    var body: some View {
        HStack(spacing: 10) {
            // 左: 事実ボックス
            VStack(spacing: 5) {
                factBox("満足度 高い")
                factBox("リピート率 高い")
                factBox("クリック率 高い")
            }
            .frame(maxWidth: .infinity)

            // 中央: 矢印
            VStack(spacing: 4) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.tiffany)
                Text("So\nWhat?")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                    .multilineTextAlignment(.center)
            }

            // 右: 示唆
            Text("施策は\n有効。\n継続すべき")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func factBox(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(Color.appText)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(Color.appBg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - 利益ツリー

private struct ProfitTreeDiagram: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 根: 利益
            rootNode("利益")
            branchSection
            // 中段
            VStack(spacing: 6) {
                midGroup(root: "売上", leaves: ["客数", "客単価"])
                midGroup(root: "コスト", leaves: ["固定費", "変動費"])
            }
        }
    }

    private func rootNode(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.tiffany)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var branchSection: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.cardBorder).frame(width: 1, height: 24)
            Rectangle().fill(Color.cardBorder).frame(width: 20, height: 1)
            Rectangle().fill(Color.cardBorder).frame(width: 1, height: 24)
        }
        .frame(width: 20)
    }

    private func midGroup(root: String, leaves: [String]) -> some View {
        HStack(spacing: 0) {
            Text(root)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // Connector lines
            Rectangle().fill(Color.cardBorder).frame(width: 14, height: 1)

            VStack(spacing: 4) {
                ForEach(leaves, id: \.self) { leaf in
                    Text(leaf)
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appSub)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.appBg)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.cardBorder, lineWidth: 1))
                }
            }
        }
    }
}

// MARK: - サニティチェック

private struct SanityCheckDiagram: View {
    var body: some View {
        VStack(spacing: 10) {
            // 推定値（警告色）
            VStack(spacing: 3) {
                Text("推定値")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appGray)
                Text("市場規模 100兆円")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.appText)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appGray.opacity(0.5), lineWidth: 1.5))

            HStack(spacing: 6) {
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
                Text("比べてみると…")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appSub)
            }

            // 比較対象
            HStack(spacing: 8) {
                compareBox(label: "日本 GDP", value: "約550兆円")
                compareBox(label: "トヨタ売上", value: "約45兆円")
            }

            // 結論
            Text("明らかに過大 → 仮定を見直す")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func compareBox(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.appText)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - 分類・グルーピング

private struct GroupingDiagram: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("バラバラな情報を整理する")
                .font(.caption2)
                .foregroundStyle(Color.appSub)

            HStack(spacing: 8) {
                scatteredItems
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.tiffany)
                groupedBoxes
            }
        }
    }

    private var scatteredItems: some View {
        VStack(spacing: 4) {
            ForEach(["みかん", "バス", "りんご", "電車", "バナナ"], id: \.self) { item in
                Text(item)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appBg)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.cardBorder, lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var groupedBoxes: some View {
        VStack(spacing: 6) {
            groupBox(title: "果物", items: ["みかん", "りんご", "バナナ"], color: .tiffany)
            groupBox(title: "乗り物", items: ["バス", "電車"], color: .appGray)
        }
        .frame(maxWidth: .infinity)
    }

    private func groupBox(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(6)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - なぜなぜ分析

private struct WhyDeepDiagram: View {
    private let steps: [(String, String)] = [
        ("問題", "機械が止まった"),
        ("なぜ①", "ヒューズが切れた"),
        ("なぜ②", "過負荷がかかった"),
        ("なぜ③", "潤滑油が不足"),
        ("根本原因", "フィルターがなかった"),
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                HStack(spacing: 8) {
                    Text(step.0)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(i == steps.count - 1 ? Color.tiffany : Color.appSub)
                        .frame(width: 46, alignment: .trailing)
                    Text(step.1)
                        .font(.system(size: 9, weight: i == steps.count - 1 ? .semibold : .regular))
                        .foregroundStyle(i == steps.count - 1 ? Color.tiffany : Color.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(i == steps.count - 1 ? Color.tiffany.opacity(0.1) : Color.appBg)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                if i < steps.count - 1 {
                    HStack {
                        Spacer().frame(width: 54)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.appGray)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - 帰納法

private struct InductionDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                exampleBox("A支店\n朝礼→遅刻減")
                exampleBox("B支店\n朝礼→遅刻減")
                exampleBox("C支店\n朝礼→遅刻減")
            }
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.forward")
                    .font(.caption)
                Image(systemName: "arrow.down")
                    .font(.caption)
                Image(systemName: "arrow.down.backward")
                    .font(.caption)
            }
            .foregroundStyle(Color.appGray)
            Text("朝礼には遅刻削減の効果がある（傾向）")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("※必ずしも法則ではなく「仮説」として扱う")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }

    private func exampleBox(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(Color.tiffany)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.tiffany.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - アナロジー思考

private struct AnalogyDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                analogyBox(title: "元ネタ", subtitle: "コンビニ\n動線設計", color: .appGray)
                VStack(spacing: 2) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.tiffany)
                    Text("構造が\n同じ")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                }
                analogyBox(title: "応用先", subtitle: "Webサイト\n導線設計", color: .tiffany)
            }
            Text("「人気商品→ついで買い」の構造を転用")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .multilineTextAlignment(.center)
        }
    }

    private func analogyBox(title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundStyle(Color.appText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - 対比・比較

private struct ComparisonDiagram: View {
    private let criteria = ["コスト", "リーチ", "CVR", "継続性"]

    var body: some View {
        VStack(spacing: 8) {
            Text("同じ軸で比べる")
                .font(.caption2)
                .foregroundStyle(Color.appSub)

            HStack(spacing: 0) {
                Text("比較軸")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.appSub)
                    .frame(width: 44)
                Text("A案")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                    .frame(maxWidth: .infinity)
                Text("VS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.appGray)
                    .frame(width: 20)
                Text("B案")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appGray)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 4)
            .background(Color.appBg)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            ForEach(Array(criteria.enumerated()), id: \.offset) { i, criterion in
                HStack(spacing: 0) {
                    Text(criterion)
                        .font(.system(size: 8))
                        .foregroundStyle(Color.appSub)
                        .frame(width: 44)
                    Text(i % 2 == 0 ? "◎" : "△")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.tiffany)
                        .frame(maxWidth: .infinity)
                    Spacer().frame(width: 20)
                    Text(i % 2 == 0 ? "△" : "◎")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appGray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - 抽象化と具体化

private struct AbstractionDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            // 抽象レイヤー
            VStack(spacing: 3) {
                Text("抽象")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                Text("コミュニケーション手段")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(Color.tiffany.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // 双方向矢印
            VStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
                Text("抽象化 ↕ 具体化")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appSub)
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(Color.appGray)
            }

            // 具体レイヤー
            VStack(spacing: 3) {
                Text("具体")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appGray)
                HStack(spacing: 4) {
                    ForEach(["メール", "電話", "チャット"], id: \.self) { item in
                        Text(item)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.appText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(Color.appBg)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.cardBorder, lineWidth: 1))
                    }
                }
            }
        }
    }
}

// MARK: - 仮説思考

private struct HypothesisDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("仮説→検証のサイクル")
                .font(.caption2)
                .foregroundStyle(Color.appSub)

            ZStack {
                Circle()
                    .stroke(Color.cardBorder, lineWidth: 1)
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    cycleNode("仮説を立てる", position: .top)
                }
            }
            .frame(height: 130)
            .overlay {
                VStack(spacing: 0) {
                    cycleLabel("①仮説")
                    HStack {
                        cycleLabel("④修正")
                        Spacer().frame(width: 50)
                        cycleLabel("②検証")
                    }
                    cycleLabel("③結果確認")
                }
                .frame(width: 160, height: 120)
            }

            Text("情報不足でも「仮の答え」を先に立てる")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .multilineTextAlignment(.center)
        }
    }

    private enum NodePosition { case top }

    private func cycleNode(_ text: String, position: NodePosition) -> some View {
        Text(text)
            .font(.system(size: 8))
            .foregroundStyle(Color.tiffany)
    }

    private func cycleLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.tiffany)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.tiffany.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - ズームイン・ズームアウト

private struct WholePartDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // 全体（ズームアウト）
                VStack(spacing: 4) {
                    Text("全体")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.appGray)
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cardBorder, lineWidth: 1.5)
                            .frame(width: 80, height: 60)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.tiffany.opacity(0.15))
                            .frame(width: 20, height: 15)
                    }
                    Text("ズームアウト")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.appSub)
                }

                VStack(spacing: 2) {
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption)
                        .foregroundStyle(Color.tiffany)
                    Text("切替")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.tiffany)
                }

                // 部分（ズームイン）
                VStack(spacing: 4) {
                    Text("部分")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.tiffany.opacity(0.08))
                            .frame(width: 80, height: 60)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.4), lineWidth: 1.5))
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(Color.tiffany)
                    }
                    Text("ズームイン")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.tiffany)
                }
            }

            Text("全体を把握してから、問題箇所を詳しく見る")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - 順序立て・プロセス思考

private struct SequencingDiagram: View {
    private let steps = ["①調査", "②仮説", "③設計", "④実行", "⑤振返"]

    var body: some View {
        VStack(spacing: 8) {
            Text("プロセスをステップに分解する")
                .font(.caption2)
                .foregroundStyle(Color.appSub)

            HStack(spacing: 4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    Text(step)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(i == 0 ? .white : Color.tiffany)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(i == 0 ? Color.tiffany : Color.tiffany.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    if i < steps.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 7))
                            .foregroundStyle(Color.appGray)
                    }
                }
            }

            Text("順序が明確→抜け漏れ・手戻りを防ぐ")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}
