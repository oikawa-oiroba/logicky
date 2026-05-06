import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            logoHeader

            Spacer()

            scoreSection
                .padding(.horizontal, 28)

            Spacer()

            ctaSection
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Logo

    private var logoHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.indigo, .purple],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("Logicky")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
    }

    // MARK: - Score

    private var scoreSection: some View {
        VStack(spacing: 16) {
            if let score = viewModel.todayScore {
                VStack(spacing: 4) {
                    Text("今日のスコア")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(score)")
                        .font(.system(size: 88, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                    Text("点")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.indigo.opacity(0.18))
                    Text("思考力を鍛えよう")
                        .font(.title2.bold())
                    Text("毎日の学習でロジカルシンキングが身につきます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            if viewModel.totalAnsweredCount > 0 {
                Text("累計 \(viewModel.totalAnsweredCount) 問回答")
                    .font(.caption)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 20) {
            Button {
                navigationPath.append(AppRoute.levelSelection)
            } label: {
                Text("学習を始める")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [.indigo, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            HStack(spacing: 8) {
                Button {
                    navigationPath.append(AppRoute.history)
                } label: {
                    Text("過去の結果を見る")
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }

                Text("·")
                    .foregroundStyle(Color(.separator))

                Button {
                    navigationPath.append(AppRoute.dictionaryList)
                } label: {
                    Label("思考法辞典", systemImage: "book.closed")
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }
            }
        }
    }
}
