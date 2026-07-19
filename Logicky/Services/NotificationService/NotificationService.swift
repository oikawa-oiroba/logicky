import Foundation
import UserNotifications

/// 毎日の学習リマインダー通知。
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let dailyId = "logicky_daily_reminder"

    /// 通知許可をリクエストし、許可されたら毎日のリマインダーを設定する
    func requestAuthorizationAndScheduleDaily() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        if granted {
            await scheduleDailyReminder()
        }
        return granted
    }

    /// 毎日20時のリマインダー
    func scheduleDailyReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyId])

        let content = UNMutableNotificationContent()
        content.title = "おはようございます！今日の5問 🧠"
        content.body = "朝の5問で頭のウォーミングアップ。ロジカルスキルを積み上げよう"
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: dailyId, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
