import SwiftUI

struct DiagnosticStartView: View {
    var onStartTraining: ((String) -> Void)? = nil
    @StateObject private var vm = DiagnosticViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch vm.phase {
            case .start:  startContent
            case .quiz:   DiagnosticQuizView(vm: vm)
            case .result: DiagnosticResultView(vm: vm, onClose: { dismiss() }, onStartTraining: onStartTraining)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
    }

    // MARK: - Start Screen

    private var startContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.tiffany)
                        .padding(.top, 24)
                    Text("ロジッキー診断")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.appText)
                    Text("5分でわかる！あなたの思考力")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSub)
                }
                .frame(maxWidth: .infinity)

                infoCard(icon: "list.bullet.clipboard",
                         title: "14問の選択問題",
                         body: "基礎14単元からそれぞれ1問出題・約7分")
                infoCard(icon: "chart.bar.fill",
                         title: "3軸で診断",
                         body: "整理力・推論力・判断力を数値化")
                infoCard(icon: "star.fill",
                         title: "得意・苦手を可視化",
                         body: "単元ごとの正誤から強み・弱みを表示")

                if let prev = DiagnosticService.shared.latestResult {
                    previousResultCard(prev)
                }

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
                    .background(Color.tiffany)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button("キャンセル") { dismiss() }
                    .font(.subheadline)
                    .foregroundStyle(Color.appSub)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appBg)
        .navigationBarHidden(true)
    }

    private func infoCard(icon: String, title: String, body: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.tiffany)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appText)
                Text(body).font(.caption).foregroundStyle(Color.appSub)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func previousResultCard(_ prev: DiagnosticResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("前回の診断結果")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appSub)
            HStack {
                Text(DiagnosticViewModel().rankLabel(for: prev.totalScore))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tiffany)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(prev.totalScore)点")
                        .font(.headline)
                        .foregroundStyle(Color.appText)
                    Text(prev.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color.appSub)
                }
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(Color.tiffany)
                Text("再挑戦")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
            }
        }
        .padding(14)
        .background(Color.tiffany.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
