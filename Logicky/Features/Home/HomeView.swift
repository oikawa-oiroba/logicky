import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ヘッダー
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // 過去の結果ボタン
                historyButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                // Level別単元一覧
                ForEach(LevelModel.all) { level in
                    levelSection(level)
                        .padding(.bottom, 20)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(colors: [.indigo, .purple],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Logicky")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                Text("思考力を、見える化する")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let today = viewModel.todayScore {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("今日のスコア")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(today)点")
                            .font(.title2.bold())
                            .foregroundStyle(.indigo)
                    }
                }
                Text("累計 \(viewModel.totalAnsweredCount) 問")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - History Button

    private var historyButton: some View {
        Button {
            navigationPath.append(AppRoute.history)
        } label: {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.subheadline)
                Text("過去の結果")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .foregroundStyle(.indigo)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Level Section

    private func levelSection(_ level: LevelModel) -> some View {
        let unlocked = viewModel.isLevelUnlocked(level)
        return VStack(alignment: .leading, spacing: 12) {
            // Level ヘッダー
            HStack(spacing: 8) {
                Text(level.name)
                    .font(.headline)
                Text(level.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // Unit カード
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(level.units) { unit in
                    UnitCard(
                        unit: unit,
                        answeredCount: viewModel.answeredCount(for: unit),
                        isCompleted: viewModel.isUnitCompleted(unit),
                        isLocked: !unlocked
                    ) {
                        if unlocked {
                            navigationPath.append(AppRoute.quiz(unitId: unit.id))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Unit Card

private struct UnitCard: View {
    let unit: UnitModel
    let answeredCount: Int
    let isCompleted: Bool
    let isLocked: Bool
    let onTap: () -> Void

    private var progress: Double {
        guard unit.totalQuestions > 0 else { return 0 }
        return Double(min(answeredCount, unit.totalQuestions)) / Double(unit.totalQuestions)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // タイトル行
                HStack {
                    Text(unit.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isLocked ? .secondary : .primary)
                        .lineLimit(1)
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }

                // プログレスバー
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemFill))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isCompleted ? Color.green : Color.indigo)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(isCompleted ? "完了 ✅" : "\(answeredCount)/\(unit.totalQuestions)")
                        .font(.caption2)
                        .foregroundStyle(isCompleted ? .green : .secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
    }
}
