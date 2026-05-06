import SwiftUI

struct ThinkingMethodDiagramView: View {
    let method: ThinkingMethod

    var body: some View {
        Group {
            switch method.id {
            case "mece":              MECEDiagram()
            case "deduction":         DeductionDiagram()
            case "fact_opinion":      FactOpinionDiagram()
            case "logic_tree":        LogicTreeDiagram()
            case "3c":                ThreeCDiagram()
            case "5w2h":              FiveW2HDiagram()
            case "fermi":             FermiDiagram()
            case "causality":         CausalityDiagram()
            case "critical":          CriticalDiagram()
            case "pyramid_principle": PyramidDiagram()
            case "4p":                FourPDiagram()
            case "matrix":            MatrixDiagram()
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

// MARK: - 演繹法

private struct DeductionDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            flowBox(label: "大前提", text: "コーヒーは眠気を覚ます", style: .sub)
            arrowDown
            flowBox(label: "小前提", text: "今、コーヒーを飲んだ", style: .sub)
            arrowDown
            flowBox(label: "結　論", text: "眠気が覚めるはず", style: .accent)
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
