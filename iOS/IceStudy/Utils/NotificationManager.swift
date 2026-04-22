import UserNotifications

enum NotificationManager {

    // MARK: - 권한 요청
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                scheduleMorningNotification()
            }
        }
    }

    // MARK: - 매일 아침 8시 알림
    static func scheduleMorningNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["morning_greeting"])

        let content = UNMutableNotificationContent()
        content.title = "얼공"
        content.body = "좋은 아침입니다! 오늘 하루도 힘차게 얼공 해볼까요? \u{1F9CA}"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morning_greeting", content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - 타이머 완료 알림 (백그라운드용)
    static func scheduleTimerCompleteNotification(after seconds: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["timer_complete"])

        let content = UNMutableNotificationContent()
        content.title = "얼공"
        content.body = "얼음이 다 녹았어요! 수고했어요 \u{1F4A7}"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(seconds, 1)), repeats: false)
        let request = UNNotificationRequest(identifier: "timer_complete", content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - 타이머 알림 취소 (포기/리셋 시)
    static func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_complete"])
    }
}
