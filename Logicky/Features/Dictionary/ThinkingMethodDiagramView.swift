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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - MECE

private struct MECEDiagram: View {
    var body: some View {
        HStack(spacing: 16) {
            diagramSide(title: "良い例 ✓", color: .green,
                        items: ["国産フルーツ", "輸入フルーツ"],
                        note: "重なりなし・漏れなし")
            diagramSide(title: "悪い例 ✗", color: .orange,
                        items: ["りんご", "輸入フルーツ"],
                        note: "輸入りんごが重複！")
        }
    }

    private func diagramSide(title: String, color: Color, items: [String], note: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            VStack(spacing: 3) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(color.opacity(0.5), lineWidth: 1))
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
            flowBox(label: "大前提", text: "コーヒーは眠気を覚ます", color: .indigo)
            arrowDown
            flowBox(label: "小前提", text: "今、コーヒーを飲んだ", color: .purple)
            arrowDown
            flowBox(label: "結　論", text: "眠気が覚めるはず", color: .teal, isBold: true)
        }
    }

    private func flowBox(label: String, text: String, color: Color, isBold: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 40)
            Text(text)
                .font(isBold ? .caption.weight(.bold) : .caption)
                .foregroundStyle(isBold ? color : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var arrowDown: some View {
        Image(systemName: "arrow.down")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// MARK: - 事実と意見

private struct FactOpinionDiagram: View {
    var body: some View {
        HStack(spacing: 12) {
            column(title: "事実", icon: "checkmark.circle.fill", color: .blue,
                   examples: ["来場者 100名", "売上 +15%", "クレーム 3件"])
            column(title: "意見", icon: "quote.bubble.fill", color: .orange,
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
            treeNode(text: "売上低下", color: .indigo, level: 0)
            HStack(spacing: 0) {
                Spacer()
                branchLine
                branchLine
                Spacer()
            }
            HStack(spacing: 8) {
                treeNode(text: "客数減少", color: .purple, level: 1)
                treeNode(text: "客単価低下", color: .purple, level: 1)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                branchLine
                Spacer(minLength: 20)
                branchLine
                Spacer(minLength: 0)
            }
            HStack(spacing: 4) {
                treeNode(text: "新規減", color: .teal, level: 2)
                treeNode(text: "離脱増", color: .teal, level: 2)
                Spacer()
                treeNode(text: "値引き増", color: .teal, level: 2)
            }
        }
    }

    private var branchLine: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(width: 1, height: 12)
    }

    private func treeNode(text: String, color: Color, level: Int) -> some View {
        Text(text)
            .font(.system(size: level == 0 ? 12 : (level == 1 ? 10 : 9), weight: level == 0 ? .bold : .regular))
            .foregroundStyle(level == 0 ? .white : color)
            .padding(.horizontal, level == 0 ? 12 : 6)
            .padding(.vertical, level == 0 ? 6 : 4)
            .background(level == 0 ? color : color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: level == 0 ? 8 : 6))
    }
}

// MARK: - 3C分析

private struct ThreeCDiagram: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                circleCard(label: "Customer", subtitle: "顧客", color: .blue)
                circleCard(label: "Competitor", subtitle: "競合", color: .orange)
                circleCard(label: "Company", subtitle: "自社", color: .green)
            }
            HStack(spacing: 6) {
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("3つの視点を重ねると")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("「勝てるポイント」が見える")
                .font(.caption.weight(.bold))
                .foregroundStyle(.indigo)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.indigo.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    private func circleCard(label: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - 5W2H

private struct FiveW2HDiagram: View {
    private let items: [(String, String, Color)] = [
        ("Why", "なぜ", .red),
        ("What", "何を", .orange),
        ("When", "いつ", .yellow),
        ("Where", "どこで", .green),
        ("Who", "誰が", .teal),
        ("How", "どうやって", .blue),
        ("How much", "いくらで", .purple),
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

    private func row(item: (String, String, Color)) -> some View {
        HStack(spacing: 4) {
            Text(item.0)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(item.2)
                .frame(width: 44, alignment: .leading)
            Text(item.1)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(item.2.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - フェルミ推定

private struct FermiDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("市場規模の推定式")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                formulaBox("世帯数", color: .indigo)
                Text("×").font(.caption).foregroundStyle(.secondary)
                formulaBox("利用率", color: .purple)
                Text("×").font(.caption).foregroundStyle(.secondary)
                formulaBox("頻度", color: .teal)
                Text("×").font(.caption).foregroundStyle(.secondary)
                formulaBox("単価", color: .green)
            }
            HStack(spacing: 4) {
                Image(systemName: "equal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("市場規模")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.indigo)
            }
            Text("正確さより「筋道立てた分解」が大事")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func formulaBox(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - 因果関係

private struct CausalityDiagram: View {
    var body: some View {
        VStack(spacing: 12) {
            patternRow(label: "因果関係", a: "暑い夏", arrow: "→", b: "アイス売れる",
                       color: .green, note: "A が B を引き起こす")
            patternRow(label: "相関だけ", a: "アイス売れる", arrow: "↔", b: "溺死増える",
                       color: .orange, note: "どちらも「夏」が原因（第3要因）")
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("相関＝因果とは限らない！")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
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
            Text(note).font(.system(size: 9)).foregroundStyle(.secondary)
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
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - 批判的思考

private struct CriticalDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("「◯◯を食べると健康になる」")
                .font(.caption.weight(.semibold))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color(.systemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 6) {
                questionBubble("サンプル数は？", color: .orange)
                questionBubble("比較対照ある？", color: .red)
                questionBubble("誰が資金提供？", color: .purple)
            }

            Text("主張を鵜呑みにせず問い直す")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func questionBubble(_ text: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: "questionmark.circle.fill")
                .font(.caption)
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 9))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - ピラミッド原則

private struct PyramidDiagram: View {
    var body: some View {
        VStack(spacing: 4) {
            pyramidRow(text: "結　論", width: 0.45, color: .indigo, isBold: true)
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                pyramidRow(text: "理由①", width: 1, color: .purple, isBold: false)
                pyramidRow(text: "理由②", width: 1, color: .purple, isBold: false)
                pyramidRow(text: "理由③", width: 1, color: .purple, isBold: false)
            }
            Image(systemName: "arrow.down").font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                pyramidRow(text: "根拠・データ・例示", width: 1, color: .teal, isBold: false)
            }
            Text("「結論 → 理由 → 詳細」の順で伝える")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private func pyramidRow(text: String, width: CGFloat, color: Color, isBold: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: isBold ? .bold : .regular))
            .foregroundStyle(isBold ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isBold ? color : color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - 4P分析

private struct FourPDiagram: View {
    private let items: [(String, String, String, Color)] = [
        ("Product", "製　品", "何を売るか", .indigo),
        ("Price", "価　格", "いくらで", .purple),
        ("Place", "流通・場所", "どこで", .teal),
        ("Promotion", "販　促", "どう知らせる", .orange),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 3) {
                    Text(item.0)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(item.3)
                    Text(item.1)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                    Text(item.2)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(item.3.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 4) {
                VStack {
                    Text("重")
                    Text("要")
                    Text("度")
                    Text("↕")
                }
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .frame(width: 16)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                    cell(text: "計画的に実施", sub: "重要・非緊急", color: .blue)
                    cell(text: "⚡最優先！", sub: "重要・緊急", color: .red, bold: true)
                    cell(text: "後回しor委任", sub: "非重要・非緊急", color: .gray)
                    cell(text: "すぐ対処", sub: "非重要・緊急", color: .orange)
                }
            }
        }
    }

    private func cell(text: String, sub: String, color: Color, bold: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.system(size: bold ? 10 : 9, weight: bold ? .bold : .regular))
                .foregroundStyle(bold ? .white : color)
                .multilineTextAlignment(.center)
            Text(sub)
                .font(.system(size: 8))
                .foregroundStyle(bold ? .white.opacity(0.8) : .secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(bold ? color : color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
