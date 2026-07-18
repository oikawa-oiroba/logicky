import SwiftUI

/// 初回起動時のチュートリアル。4ステップの紹介 → 通知許可のお願い。
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0
    @State private var requestingNotification = false

    private struct Step {
        let icon: String
        let title: String
        let body: String
    }

    private let steps: [Step] = [
        Step(icon: "brain.head.profile",
             title: "Logickyとは？",
             body: "論理的思考は、生まれつきの才能ではなく練習で伸びるスキル。\nLogickyは、毎日5問で「考える力」を鍛えるトレーニングアプリです。"),
        Step(icon: "4.square.fill",
             title: "まずは今日の5問",
             body: "1日5問から始めましょう。\n終わったら次の5問へ、どんどん進めてOK。\n正答率80%で単元クリア、全問正解でバッジ獲得です。"),
        Step(icon: "book.closed.fill",
             title: "辞典も活用してみて",
             body: "思考法辞典には23のフレームワークを図解つきで収録。\n問題につまずいたら、ヒントや辞典で考え方を確認できます。"),
        Step(icon: "crown.fill",
             title: "強くなりましょう！",
             body: "診断で現在地を知り、バッジを集めながら、\nあなたのロジカルスキルを高めていきましょう。"),
        Step(icon: "bell.badge.fill",
             title: "リマインダーを受け取る",
             body: "毎日の積み重ねがいちばんの近道。\n学習を忘れないように、通知を許可してください。\n（あとから設定でも変更できます）"),
    ]

    private var isNotificationStep: Bool { page == steps.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !isNotificationStep {
                    Button("スキップ") { onFinish() }
                        .font(.subheadline)
                        .foregroundStyle(Color.appGray)
                        .padding()
                }
            }
            .frame(height: 52)

            TabView(selection: $page) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 24) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.tiffany.opacity(0.1))
                                .frame(width: 140, height: 140)
                            Image(systemName: step.icon)
                                .font(.system(size: 56))
                                .foregroundStyle(Color.tiffany)
                        }
                        VStack(spacing: 12) {
                            Text(step.title)
                                .font(.title2.bold())
                                .foregroundStyle(Color.appText)
                            Text(step.body)
                                .font(.subheadline)
                                .foregroundStyle(Color.appSub)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: page)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i == page ? Color.tiffany : Color.cardBorder)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 24)

            // CTA
            VStack(spacing: 10) {
                if isNotificationStep {
                    Button {
                        requestingNotification = true
                        Task {
                            _ = await NotificationService.shared.requestAuthorizationAndScheduleDaily()
                            requestingNotification = false
                            onFinish()
                        }
                    } label: {
                        Text(requestingNotification ? "設定中…" : "通知を許可して始める")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.tiffany)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(requestingNotification)

                    Button("あとで") { onFinish() }
                        .font(.subheadline)
                        .foregroundStyle(Color.appGray)
                } else {
                    Button {
                        withAnimation { page += 1 }
                    } label: {
                        Text("次へ")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.tiffany)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.appBg)
    }
}
