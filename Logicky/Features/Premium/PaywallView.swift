import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var premiumService: PremiumService
    @Environment(\.dismiss) private var dismiss

    @State private var licenseCode = ""
    @State private var redeemMessage: String? = nil
    @State private var redeemSuccess = false
    @State private var redeeming = false
    @State private var purchaseError: String? = nil
    @AppStorage("logicky_nickname") private var nickname: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    if premiumService.isPremium {
                        premiumActiveCard
                    } else {
                        featureList
                        purchaseSection
                    }
                    licenseSection
                    legalLinks
                }
                .padding(20)
            }
            .background(Color.appBg)
            .navigationTitle("プレミアム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appSub)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.tiffany)
            Text("Logicky プレミアム")
                .font(.title2.bold())
                .foregroundStyle(Color.appText)
            Text("思考力トレーニングを、制限なく。")
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
        }
        .padding(.top, 8)
    }

    private var premiumActiveCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.tiffany)
            Text("プレミアム有効")
                .font(.headline)
                .foregroundStyle(Color.appText)
            if premiumService.subscriptionActive {
                Text("App Storeサブスクリプション")
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
            } else if let until = premiumService.licensePremiumUntil {
                Text(until == .distantFuture
                     ? "ライセンスコード（無期限）"
                     : "ライセンスコード（\(formatted(until))まで）")
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tiffany.opacity(0.4), lineWidth: 1))
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(icon: "infinity", title: "トレーニングやり放題",
                       detail: "無料プランは1日1セッション。プレミアムは無制限")
            featureRow(icon: "square.grid.2x2.fill", title: "全23単元・全機能が使い放題",
                       detail: "基礎編14単元＋実践編9単元すべて")
            featureRow(icon: "sparkles", title: "今後の新機能もすべて利用可能",
                       detail: "追加問題・新機能を追加料金なしで")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.tiffany)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
            }
        }
    }

    private var purchaseSection: some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    purchaseError = await premiumService.purchaseMonthly()
                }
            } label: {
                VStack(spacing: 2) {
                    Text(premiumService.purchaseInProgress ? "処理中…" : "初月無料で始める")
                        .font(.headline)
                    Text(priceText)
                        .font(.caption)
                        .opacity(0.85)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(premiumService.purchaseInProgress)

            Button("購入を復元する") {
                Task { await premiumService.restorePurchases() }
            }
            .font(.caption)
            .foregroundStyle(Color.appSub)

            if let purchaseError {
                Text(purchaseError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text("初月無料期間終了後は自動で月額課金されます。いつでも設定から解約できます。")
                .font(.caption2)
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)
        }
    }

    private var priceText: String {
        if let product = premiumService.monthlyProduct {
            return "\(product.displayPrice)/月・初月無料"
        }
        return "月額980円・初月無料"
    }

    private var licenseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ライセンスコードをお持ちの方")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appText)

            HStack(spacing: 8) {
                TextField("コードを入力", text: $licenseCode)
                    .font(.subheadline.monospaced())
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 1))

                Button {
                    Task { await redeem() }
                } label: {
                    Text(redeeming ? "確認中…" : "適用")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(licenseCode.trimmingCharacters(in: .whitespaces).isEmpty ? Color.appGray : Color.tiffany)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(licenseCode.trimmingCharacters(in: .whitespaces).isEmpty || redeeming)
            }

            if let redeemMessage {
                Text(redeemMessage)
                    .font(.caption)
                    .foregroundStyle(redeemSuccess ? Color.tiffany : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("利用規約", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            Link("プライバシーポリシー", destination: URL(string: "https://logicky.app/privacy")!)
        }
        .font(.caption2)
        .foregroundStyle(Color.appGray)
    }

    private func redeem() async {
        redeeming = true
        redeemMessage = nil
        let result = await premiumService.redeemLicense(
            code: licenseCode,
            nickname: nickname
        )
        switch result {
        case .success(let untilText):
            redeemSuccess = true
            redeemMessage = "プレミアムが有効になりました（\(untilText)）"
        case .failure(let message):
            redeemSuccess = false
            redeemMessage = message
        }
        redeeming = false
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
