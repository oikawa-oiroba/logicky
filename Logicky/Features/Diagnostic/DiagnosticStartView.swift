import SwiftUI

struct DiagnosticStartView: View {
    @StateObject private var vm = DiagnosticViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch vm.phase {
            case .start:  startContent
            case .quiz:   DiagnosticQuizView(vm: vm)
            case .result: DiagnosticResultView(vm: vm, onClose: { dismiss() })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
    }

    // MARK: - Start Screen

    private var startContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    Text("🎯")
                        .font(.system(size: 56))
                        .padding(.top, 24)
                    Text("ロジッキー診断")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("5分でわかる！あなたの思考力")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Info cards
                infoCard(icon: "list.bullet.clipboard", color: .indigo,
                         title: "10問の選択問題",
                         body: "Level 1〜3 からバランスよく出題")
                infoCard(icon: "chart.bar.fill", color: .teal,
                         title: "3軸で診断",
                         body: "整理力・推論力・判断力を数値化")
                infoCard(icon: "star.fill", color: .orange,
                         title: "ランク判定",
                         body: "S〜D の 6 段階でスコアを評価")

                // Previous result summary
                if let prev = DiagnosticService.shared.latestResult {
                    previousResultCard(prev)
                }

                // CTA
                Button {
                    vm.startDiagnostic()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("診断を始める")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.indigo, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button("キャンセル") { dismiss() }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    private func infoCard(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(body).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func previousResultCard(_ prev: DiagnosticResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("前回の診断結果")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack {
                Text(DiagnosticViewModel().rankLabel(for: prev.totalScore))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(DiagnosticViewModel().rankColor(for: prev.totalScore))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(prev.totalScore)点")
                        .font(.headline)
                    Text(prev.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                Text("再挑戦")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.indigo)
            }
        }
        .padding(14)
        .background(Color.indigo.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
