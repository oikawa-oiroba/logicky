import SwiftUI

/// 結果画面: 総合スコアと3軸評価（レーダーチャート）を表示する
struct ResultView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // タイトルヘッダー
                titleHeader

                if let result = viewModel.quizResult {
                    // 総合スコア（円グラフ）
                    totalScoreSection(result)

                    // レーダーチャート
                    radarChartSection(result)

                    // 3軸スコアカード
                    scoresGrid(result)
                } else {
                    // 結果が取得できない場合のフォールバック
                    Text("結果を計算中...")
                        .foregroundStyle(.secondary)
                        .padding()
                }

                // ホームに戻るボタン
                homeButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    private var titleHeader: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 24)

            Text("診断完了")
                .font(.title.bold())

            Text("あなたの思考力スコア")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func totalScoreSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            ZStack {
                // 背景円
                Circle()
                    .stroke(Color.indigo.opacity(0.15), lineWidth: 14)
                    .frame(width: 150, height: 150)

                // スコア円弧
                Circle()
                    .trim(from: 0, to: CGFloat(result.totalScore) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: result.totalScore)

                // スコア数値
                VStack(spacing: 2) {
                    Text("\(result.totalScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                    Text("点")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // ランクラベル
            Text(rankLabel(result.totalScore))
                .font(.headline)
                .foregroundStyle(rankColor(result.totalScore))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(rankColor(result.totalScore).opacity(0.12))
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func radarChartSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            Text("3軸評価")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            RadarChartView(
                values: [
                    Double(result.structureScore) / 100,
                    Double(result.logicScore) / 100,
                    Double(result.specificityScore) / 100
                ],
                labels: ["構造", "論理性", "具体性"]
            )
            .frame(height: 240)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func scoresGrid(_ result: QuizResult) -> some View {
        HStack(spacing: 12) {
            ScoreCard(title: "構造", score: result.structureScore, color: .indigo)
            ScoreCard(title: "論理性", score: result.logicScore, color: .purple)
            ScoreCard(title: "具体性", score: result.specificityScore, color: .teal)
        }
    }

    private var homeButton: some View {
        Button {
            viewModel.reset()
            navigationPath = NavigationPath()
        } label: {
            HStack {
                Image(systemName: "house.fill")
                Text("ホームに戻る")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers

    private func rankLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return "優秀なロジカルシンカー"
        case 60..<80:  return "着実に成長中"
        case 40..<60:  return "まだ伸びしろあり"
        default:       return "基礎から積み上げよう"
        }
    }

    private func rankColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80:  return .blue
        case 40..<60:  return .orange
        default:       return .red
        }
    }
}

/// 個別軸スコアカード
private struct ScoreCard: View {
    let title: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("\(score)")
                .font(.title2.bold())
                .foregroundStyle(color)

            Text("点")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
