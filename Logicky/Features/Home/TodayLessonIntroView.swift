import SwiftUI

/// 「今日の5問」を始める前に、単元の解説（辞典の内容）を表示するインターステイシャル。
/// 概要をつかんでから問題に入れる。シャッフルで別の未修得単元にも切り替えられる。
struct TodayLessonIntroView: View {
    let initialUnitId: String
    let onStart: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var unitId: String

    init(initialUnitId: String, onStart: @escaping (String) -> Void) {
        self.initialUnitId = initialUnitId
        self.onStart = onStart
        _unitId = State(initialValue: initialUnitId)
    }

    private var unit: UnitModel? {
        UnitModel.all.first { $0.id == unitId }
    }

    private var method: ThinkingMethod? {
        ThinkingMethodService.shared.all.first { $0.unitId == unitId }
    }

    // シャッフル候補：未完了の単元（現在の単元を除く）
    private var shuffleCandidates: [UnitModel] {
        UnitModel.all.filter {
            $0.id != unitId && !SkillBadgeService.shared.isUnitCompleted($0.id)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let unit {
                        // 単元名
                        VStack(alignment: .leading, spacing: 6) {
                            Text("今日の単元")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appGray)
                            Text(unit.displayName)
                                .font(.title2.bold())
                                .foregroundStyle(Color.appText)
                            if let method {
                                Text(method.reading.map { "\(method.name)（\($0)）" } ?? method.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appSub)
                            }
                        }

                        if let method {
                            // どういう考え方？
                            VStack(alignment: .leading, spacing: 10) {
                                Label("どういう考え方？", systemImage: "lightbulb.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.tiffany)
                                Text(method.hintShort)
                                    .font(.body)
                                    .foregroundStyle(Color.appText)
                                    .lineSpacing(5)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.tiffany.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // 身近な例
                            VStack(alignment: .leading, spacing: 10) {
                                Label("身近な例", systemImage: "person.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSub)
                                Text(method.hintExample)
                                    .font(.body)
                                    .foregroundStyle(Color.appText)
                                    .lineSpacing(5)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // 詳しい解説（辞典より）
                            VStack(alignment: .leading, spacing: 10) {
                                Label("くわしく", systemImage: "book.closed.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSub)
                                Text(method.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appSub)
                                    .lineSpacing(5)
                            }
                        }
                    }
                }
                .padding(20)
                .animation(.easeInOut(duration: 0.2), value: unitId)
            }
            .background(Color.appBg)
            .navigationTitle("今日の5問")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appSub)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                        onStart(unitId)
                    } label: {
                        HStack(spacing: 6) {
                            Text("今日の5問スタート")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.tiffany)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if !shuffleCandidates.isEmpty {
                        Button {
                            if let next = shuffleCandidates.randomElement() {
                                unitId = next.id
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "shuffle")
                                Text("別の単元にする")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.tiffany)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.tiffany.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
    }
}
