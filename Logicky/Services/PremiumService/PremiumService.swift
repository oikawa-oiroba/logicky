import Foundation
import StoreKit

/// プレミアム権限の管理。
/// 権限ソースは2系統: App Storeサブスクリプション / ライセンスコード。
/// どちらかが有効なら isPremium = true。
@MainActor
final class PremiumService: ObservableObject {
    static let shared = PremiumService()

    /// App Store Connect で登録するサブスクリプションのプロダクトID
    static let monthlyProductId = "app.logicky.premium.monthly"

    /// 期間限定の全機能無料開放フラグ。課金を開始するタイミングで false にする。
    /// true の間は無料プランの制限がかからず、ペイウォールは「無料開放中」の告知になる。
    static let freePromotionActive = true

    // MARK: - Published

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var subscriptionActive: Bool = false
    @Published private(set) var monthlyProduct: Product? = nil
    @Published private(set) var purchaseInProgress = false

    // MARK: - UserDefaults keys

    private let licenseUntilKey = "logicky_license_until" // ISO8601 or "forever"
    private let licenseCodeKey = "logicky_license_code"
    private let deviceIdKey = "logicky_device_id"

    private var updatesTask: Task<Void, Never>? = nil

    private init() {
        recompute()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if let transaction = try? update.payloadValue {
                    await transaction.finish()
                }
                await self?.refreshSubscriptionStatus()
            }
        }
        Task {
            await loadProducts()
            await refreshSubscriptionStatus()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Device ID（匿名・端末単位。ライセンス利用の識別に使用）

    var deviceId: String {
        if let existing = UserDefaults.standard.string(forKey: deviceIdKey) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: deviceIdKey)
        return new
    }

    // MARK: - License

    var licenseCode: String? {
        UserDefaults.standard.string(forKey: licenseCodeKey)
    }

    var licensePremiumUntil: Date? {
        guard let raw = UserDefaults.standard.string(forKey: licenseUntilKey) else { return nil }
        if raw == "forever" { return .distantFuture }
        return ISO8601DateFormatter().date(from: raw)
    }

    private var licenseActive: Bool {
        guard let until = licensePremiumUntil else { return false }
        return until > Date()
    }

    struct RedeemResponse: Decodable {
        let ok: Bool?
        let premiumUntil: String?
        let grantDays: Int?
        let error: String?
    }

    enum RedeemResult {
        case success(untilText: String)
        case failure(message: String)
    }

    func redeemLicense(code: String, nickname: String) async -> RedeemResult {
        struct Payload: Encodable {
            let code: String
            let deviceId: String
            let nickname: String
            let platform: String
        }
        guard let url = URL(string: "https://logicky.app/api/license/redeem") else {
            return .failure(message: "内部エラー")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        do {
            request.httpBody = try JSONEncoder().encode(
                Payload(code: code, deviceId: deviceId, nickname: nickname, platform: "ios")
            )
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(RedeemResponse.self, from: data)
            if response.ok == true {
                let untilRaw = response.premiumUntil ?? "forever"
                UserDefaults.standard.set(untilRaw, forKey: licenseUntilKey)
                UserDefaults.standard.set(code.uppercased(), forKey: licenseCodeKey)
                recompute()
                if let untilIso = response.premiumUntil,
                   let until = ISO8601DateFormatter().date(from: untilIso) {
                    let f = DateFormatter()
                    f.locale = Locale(identifier: "ja_JP")
                    f.dateStyle = .medium
                    return .success(untilText: "\(f.string(from: until))まで")
                }
                return .success(untilText: "無期限")
            }
            return .failure(message: response.error ?? "コードを確認できませんでした")
        } catch {
            return .failure(message: "通信に失敗しました。ネットワークを確認してください")
        }
    }

    // MARK: - StoreKit

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.monthlyProductId])
            monthlyProduct = products.first
        } catch {
            monthlyProduct = nil
        }
    }

    func refreshSubscriptionStatus() async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue,
               transaction.productID == Self.monthlyProductId {
                active = true
            }
        }
        subscriptionActive = active
        recompute()
    }

    func purchaseMonthly() async -> String? {
        guard let product = monthlyProduct else {
            return "ストアの準備中です。しばらくしてからお試しください"
        }
        purchaseInProgress = true
        defer { purchaseInProgress = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue {
                    await transaction.finish()
                }
                await refreshSubscriptionStatus()
                return nil
            case .userCancelled, .pending:
                return nil
            @unknown default:
                return nil
            }
        } catch {
            return "購入処理に失敗しました"
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshSubscriptionStatus()
    }

    // MARK: - Entitlement

    private func recompute() {
        isPremium = subscriptionActive || licenseActive
    }

    /// 無料プラン: トレーニングは1日1セッションまで（診断・辞典・ふりかえりは無制限）
    /// 無料開放中はすべて許可
    func canStartTrainingSession(attemptService: AttemptService) -> Bool {
        if Self.freePromotionActive { return true }
        if isPremium { return true }
        let calendar = Calendar.current
        let todayCount = attemptService.attempts.filter { calendar.isDateInToday($0.date) }.count
        return todayCount == 0
    }
}
