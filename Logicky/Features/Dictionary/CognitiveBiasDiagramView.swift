import SwiftUI

struct CognitiveBiasDiagramView: View {
    let bias: CognitiveBias

    var body: some View {
        Group {
            switch bias.id {
            case "confirmation_bias":   ConfirmationBiasDiagram()
            case "anchoring":           AnchoringDiagram()
            case "halo_effect":         HaloEffectDiagram()
            case "hindsight_bias":      HindsightBiasDiagram()
            case "overgeneralization":  OvergeneralizationDiagram()
            case "illusory_correlation": IllusoryCorrelationDiagram()
            case "survivorship_bias":   SurvivorshipBiasDiagram()
            case "availability_heuristic": AvailabilityHeuristicDiagram()
            case "framing_effect":      FramingEffectDiagram()
            case "base_rate_neglect":   BaseRateNeglectDiagram()
            case "sunk_cost":           SunkCostDiagram()
            case "gamblers_fallacy":    GamblersFallacyDiagram()
            case "bandwagon_effect":    BandwagonEffectDiagram()
            case "authority_bias":      AuthorityBiasDiagram()
            case "self_serving_bias":   SelfServingBiasDiagram()
            case "normalcy_bias":       NormalcyBiasDiagram()
            case "status_quo_bias":     StatusQuoBiasDiagram()
            case "dunning_kruger":      DunningKrugerDiagram()
            default:
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(Color.appGray)
                    .frame(width: 170, height: 130)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }
}

// MARK: - 1. 確証バイアス

private struct ConfirmationBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                // 賛成カード群（左側）
                VStack(spacing: 4) {
                    ForEach(["賛成", "賛成", "賛成"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.tiffany)
                            .frame(width: 36)
                            .padding(.vertical, 4)
                            .background(Color.tiffany.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.tiffany.opacity(0.4), lineWidth: 1))
                    }
                }

                // 矢印 → 人 アイコン
                HStack(spacing: 2) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.tiffany)
                    // 右側: 反対カードが押しのけられる
                    VStack(spacing: 4) {
                        ForEach(["反対", "反対"], id: \.self) { label in
                            HStack(spacing: 2) {
                                Text("×")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color.appGray)
                                Text(label)
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.appGray)
                                    .frame(width: 30)
                                    .padding(.vertical, 4)
                                    .background(Color.appGray.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.appGray.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                }
            }
            .frame(width: 170, height: 100)

            Text("都合の良い情報だけ集める")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 2. アンカリング

private struct AnchoringDiagram: View {
    var body: some View {
        VStack(spacing: 4) {
            // 大きなアンカー数値
            HStack(spacing: 6) {
                Text("500万")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                Image(systemName: "anchor.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.tiffany)
            }

            // 点線の矢印
            VStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.appGray.opacity(0.5))
                        .frame(width: 1.5, height: 4)
                }
                Image(systemName: "arrow.down")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appGray)
            }

            // 判断ボックス
            Text("判断")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appSub)
                .frame(width: 60)
                .padding(.vertical, 6)
                .background(Color.appGray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.appGray.opacity(0.4), lineWidth: 1))

            Text("最初の数字が基準になる")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
                .padding(.top, 2)
        }
        .frame(width: 170, height: 130)
    }
}

// MARK: - 3. ハロー効果

private struct HaloEffectDiagram: View {
    private let labels: [(String, CGFloat, CGFloat)] = [
        ("仕事",   -52, -30),
        ("人柄",   -36, 28),
        ("判断力",  10, 50),
        ("知識",    54, 20),
        ("実力",    46, -36),
    ]

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // 周囲の評価ラベル
                ForEach(labels, id: \.0) { item in
                    HStack(spacing: 2) {
                        Circle()
                            .fill(Color.tiffany.opacity(0.5))
                            .frame(width: 6, height: 6)
                        Text(item.0)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.appSub)
                    }
                    .offset(x: item.1, y: item.2)
                }

                // 中央スター
                Image(systemName: "star.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.tiffany)
            }
            .frame(width: 170, height: 110)

            Text("1つの印象で全てを評価")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 4. 後知恵バイアス

private struct HindsightBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                // 判断時ボックス
                VStack(spacing: 3) {
                    Text("判断時")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.appGray)
                    Text("?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
                .frame(width: 48, height: 54)
                .background(Color.appGray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appGray.opacity(0.3), lineWidth: 1))

                VStack(spacing: 2) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.appGray)
                    Text("結果\n判明")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.appSub)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 34)

                // スピーチバブル風「やっぱりね」
                VStack(spacing: 3) {
                    Text("やっぱり\nね！")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 56, height: 54)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.4), lineWidth: 1))
            }

            // タイムライン矢印
            HStack(spacing: 0) {
                Text("過去")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appGray)
                Rectangle()
                    .fill(Color.appGray.opacity(0.4))
                    .frame(height: 1)
                Image(systemName: "arrow.right")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appGray)
                Text("現在")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appGray)
            }
            .frame(width: 160)

            Text("後から「わかってた」と思う")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 5. 過度な一般化

private struct OvergeneralizationDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            // サンプル小ボックス 2つ
            HStack(spacing: 8) {
                sampleBox("事例①")
                sampleBox("事例②")
                VStack(spacing: 2) {
                    Text("?")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
                .frame(width: 24)
            }

            // 下矢印（太い）
            Image(systemName: "arrow.down")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.tiffany)

            // 大きな法則ボックス
            Text("これが法則だ！")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: 160)

            Text("少ない事例で断定してしまう")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }

    private func sampleBox(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(Color.appSub)
            .frame(width: 52)
            .padding(.vertical, 8)
            .background(Color.appGray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.appGray.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - 6. 幻想的相関

private struct IllusoryCorrelationDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                // 左ボックス
                Text("Aが\n起きた")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.appSub)
                    .multilineTextAlignment(.center)
                    .frame(width: 52)
                    .padding(.vertical, 10)
                    .background(Color.appGray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appGray.opacity(0.3), lineWidth: 1))

                // 点線矢印 + 因果ラベル
                VStack(spacing: 2) {
                    Text("因果？")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.tiffany.opacity(0.5))
                                .frame(width: 4, height: 1.5)
                        }
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.tiffany)
                    }
                    Text("実は偶然")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.appGray)
                }
                .frame(width: 58)

                // 右ボックス
                Text("Bも\n起きた")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.appSub)
                    .multilineTextAlignment(.center)
                    .frame(width: 52)
                    .padding(.vertical, 10)
                    .background(Color.appGray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appGray.opacity(0.3), lineWidth: 1))
            }

            Text("偶然の一致を法則と思い込む")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
        .frame(width: 170, height: 130)
    }
}

// MARK: - 7. 生存者バイアス

private struct SurvivorshipBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // スポットライト（グラデーション円）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.tiffany.opacity(0.25), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)

                VStack(spacing: 10) {
                    // 成功した1人（大・ティファニー）
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.tiffany)

                    // 見えていない4人（小・グレー）
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { _ in
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.appGray.opacity(0.4))
                        }
                    }
                }
            }
            .frame(width: 170, height: 105)

            Text("成功例だけが見えている")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 8. 利用可能性ヒューリスティック

private struct AvailabilityHeuristicDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                // 脳アイコン
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.tiffany)
                    .frame(width: 36)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 8) {
                    // 大きな印象バブル
                    Text("印象的な\n出来事!")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.tiffany.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.35), lineWidth: 1))

                    // 小さな統計バブル
                    Text("実際の統計")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.appGray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.appGray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.appGray.opacity(0.3), lineWidth: 1))
                }
            }
            .frame(width: 170, height: 100)

            Text("記憶に残りやすい事例で判断")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 9. フレーミング効果

private struct FramingEffectDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                // 左: 半分も
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.tiffany.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 52, height: 52)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.tiffany.opacity(0.3))
                            .frame(width: 50, height: 26)
                    }
                    Text("半分も\nある!")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                }

                // VS
                Text("同じ\n事実")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appGray)
                    .multilineTextAlignment(.center)

                // 右: 半分しか
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.appGray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 52, height: 52)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appGray.opacity(0.2))
                            .frame(width: 50, height: 26)
                    }
                    Text("半分\nしかない")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appGray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 170, height: 100)

            Text("同じ事実、違う印象")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 10. 基準率の無視

private struct BaseRateNeglectDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 4) {
                Text("的中率 99%!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.tiffany)

                Text("でも対象は10万人に1人")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appGray)

                Image(systemName: "arrow.down")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appGray)

                HStack(spacing: 4) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appSub)
                    Text("実際の確率は？")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.appSub)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(width: 160)
                .background(Color.appGray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: 170, height: 110)

            Text("全体の割合を忘れてしまう")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 11. サンクコスト

private struct SunkCostDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 14) {
                // 穴とコイン
                VStack(spacing: 4) {
                    ZStack {
                        // 穴
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.appGray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 52, height: 44)
                        // コイン（小矩形）
                        VStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.appGray.opacity(0.35))
                                    .frame(width: 28, height: 6)
                            }
                        }
                    }
                    // 人 + 吹き出し
                    HStack(spacing: 3) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appGray)
                        Text("もったい\nない…")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.appGray)
                            .multilineTextAlignment(.center)
                            .padding(4)
                            .background(Color.appGray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }

                // 未来の利益
                VStack(spacing: 3) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    Text("未来の\n利益")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 170, height: 100)

            Text("過去のコストに縛られる")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 12. ギャンブラーの誤謬

private struct GamblersFallacyDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                // 過去5回「表」
                ForEach(0..<5, id: \.self) { _ in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(Color.tiffany.opacity(0.2))
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(Color.tiffany.opacity(0.5), lineWidth: 1))
                        Text("表")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color.tiffany)
                    }
                }
                Image(systemName: "arrow.right")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.appGray)
                // 6回目
                VStack(spacing: 2) {
                    Circle()
                        .fill(Color.appGray.opacity(0.1))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.appGray.opacity(0.4), lineWidth: 1.5))
                    Text("?")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
            }

            Text("次こそ裏!")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appSub)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.appGray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text("各回は独立している")
                .font(.system(size: 9))
                .foregroundStyle(Color.appGray)

            Text("「そろそろ」は根拠がない")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
        .frame(width: 170, height: 130)
    }
}

// MARK: - 13. バンドワゴン効果

private struct BandwagonEffectDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                // グレーの群衆
                ForEach(0..<4, id: \.self) { _ in
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
                // ティファニーの1つが引き寄せられる
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                    .rotationEffect(.degrees(8))
                    .offset(y: -4)
            }
            .frame(width: 170, height: 80)

            Text("多数派に流されてしまう")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 14. 権威バイアス

private struct AuthorityBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 4) {
                // 王冠 + 人物
                VStack(spacing: 2) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appGray)
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appGray)
                }

                // 吹き出し
                Text("「○○と言っている」")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.appSub)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.appGray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // 小さな問い
                Text("根拠は？")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.tiffany)
            }
            .frame(width: 170, height: 108)

            Text("権威ある人を無条件に信じる")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 15. 自己奉仕バイアス

private struct SelfServingBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                // 成功 → 自分
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    Text("自分の\n実力!")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color.tiffany.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(width: 62)

                // 失敗 → 他人
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.appGray)
                    Text("環境の\nせい!")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 5)
                        .background(Color.appGray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(width: 62)
            }
            .frame(width: 170, height: 100)

            Text("成功↑自分・失敗↓他人のせい")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 16. 正常性バイアス

private struct NormalcyBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // 警告アイコン (3つ)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appGray.opacity(0.6))
                    .offset(x: -58, y: -20)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appGray.opacity(0.6))
                    .offset(x: 56, y: -22)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appGray.opacity(0.6))
                    .offset(x: 0, y: -46)

                // 人物（目が閉じている = 2つの小円）
                VStack(spacing: 3) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.appSub)
                    // 吹き出し
                    Text("大丈夫…")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appSub)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appGray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .frame(width: 170, height: 105)

            Text("異常を正常と思い込む")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 17. 現状維持バイアス

private struct StatusQuoBiasDiagram: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                // 現状ボックス
                VStack(spacing: 4) {
                    Text("現状")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tiffany)
                    Image(systemName: "sofa.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.tiffany)
                }
                .frame(width: 54, height: 60)
                .background(Color.tiffany.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.tiffany.opacity(0.4), lineWidth: 1.5))

                // 障壁
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.appGray.opacity(0.5))
                        .frame(width: 5, height: 46)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    Text("不安")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
                .frame(width: 28)

                // 変化ボックス
                VStack(spacing: 4) {
                    Text("変化")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appGray)
                    Image(systemName: "door.right.hand.open")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appGray)
                }
                .frame(width: 54, height: 60)
                .background(Color.appGray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appGray.opacity(0.3), lineWidth: 1))
            }
            .frame(width: 170, height: 80)

            Text("変えないことを選び続ける")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}

// MARK: - 18. ダニング＝クルーガー効果

private struct DunningKrugerDiagram: View {
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .bottomLeading) {
                // 軸
                Path { path in
                    // Y軸
                    path.move(to: CGPoint(x: 24, y: 6))
                    path.addLine(to: CGPoint(x: 24, y: 86))
                    // X軸
                    path.move(to: CGPoint(x: 24, y: 86))
                    path.addLine(to: CGPoint(x: 158, y: 86))
                }
                .stroke(Color.appGray.opacity(0.5), lineWidth: 1)

                // 軸ラベル
                Text("自信")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appGray)
                    .position(x: 14, y: 46)
                    .rotationEffect(.degrees(-90))
                Text("知識")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appGray)
                    .position(x: 91, y: 97)

                // ダニングクルーガー曲線
                Path { path in
                    // 急上昇→ピーク→急落→緩やかな上昇
                    path.move(to: CGPoint(x: 24, y: 86))
                    path.addCurve(
                        to: CGPoint(x: 70, y: 14),
                        control1: CGPoint(x: 30, y: 86),
                        control2: CGPoint(x: 46, y: 14)
                    )
                    path.addCurve(
                        to: CGPoint(x: 106, y: 70),
                        control1: CGPoint(x: 90, y: 14),
                        control2: CGPoint(x: 106, y: 70)
                    )
                    path.addCurve(
                        to: CGPoint(x: 158, y: 42),
                        control1: CGPoint(x: 106, y: 70),
                        control2: CGPoint(x: 134, y: 50)
                    )
                }
                .stroke(Color.tiffany, style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                // ピークラベル
                Text("危険!")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.tiffany)
                    .position(x: 70, y: 8)
            }
            .frame(width: 170, height: 102)

            Text("知らないほど自信がある")
                .font(.system(size: 9))
                .foregroundStyle(Color.appSub)
        }
    }
}
