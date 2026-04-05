import SwiftUI

/// ホーム画面: 診断開始ボタンとアプリ説明を表示する
struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // ヘッダーセクション
                headerSection

                // 機能説明セクション
                featureSection

                // 診断開始ボタン
                startButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Logicky")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text("思考力を、見える化する")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var featureSection: some View {
        VStack(spacing: 0) {
            FeatureRow(
                icon: "brain",
                iconColor: .indigo,
                title: "ロジカルシンキングを診断",
                description: "4択・自由記述の問題に答えて思考力を測定"
            )
            Divider().padding(.leading, 60)
            FeatureRow(
                icon: "chart.bar.fill",
                iconColor: .purple,
                title: "3つの軸で評価",
                description: "構造・論理性・具体性の観点からフィードバック"
            )
            Divider().padding(.leading, 60)
            FeatureRow(
                icon: "arrow.up.circle.fill",
                iconColor: .teal,
                title: "継続的なトレーニング",
                description: "繰り返すことで思考力の成長を実感できる"
            )
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var startButton: some View {
        Button {
            viewModel.loadQuestions()
            viewModel.reset()
            navigationPath.append(AppRoute.quiz)
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("診断を開始する")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
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
}

/// 機能説明の1行コンポーネント
private struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}
