import Foundation
import UserNotifications

/// Centralises all local notification scheduling for the app.
/// Call `rescheduleAll` whenever records or settings change.
final class NotificationService {
    static let shared = NotificationService()

    // Notification category/action identifiers
    static let categoryPeriodStart = "PERIOD_START"
    static let categoryPeriodEnd   = "PERIOD_END"
    static let actionYes = "YES"
    static let actionNo  = "NO"

    private let center = UNUserNotificationCenter.current()

    private init() {
        registerCategories()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    // MARK: - Category registration

    private func registerCategories() {
        let yes = UNNotificationAction(identifier: Self.actionYes,
                                       title: NSLocalizedString("Yes", comment: ""),
                                       options: [.foreground])
        let no  = UNNotificationAction(identifier: Self.actionNo,
                                       title: NSLocalizedString("No", comment: ""),
                                       options: [])

        let startCat = UNNotificationCategory(identifier: Self.categoryPeriodStart,
                                              actions: [yes, no],
                                              intentIdentifiers: [])
        let endCat   = UNNotificationCategory(identifier: Self.categoryPeriodEnd,
                                              actions: [yes, no],
                                              intentIdentifiers: [])
        center.setNotificationCategories([startCat, endCat])
    }

    // MARK: - Reschedule

    /// Cancel all app notifications and recompute based on current records and settings.
    func rescheduleAll(records: [MenstrualRecord], cycleLengthDays: Int) async {
        // Cancel all existing period notifications
        let pending = await center.pendingNotificationRequests()
        let toCancel = pending.map(\.identifier).filter {
            $0.hasPrefix("period_start_") || $0.hasPrefix("period_end_")
        }
        center.removePendingNotificationRequests(withIdentifiers: toCancel)

        let now = Date()
        let calendar = Calendar.current

        // 1. Schedule "Has your period stopped?" reminders (day 5 after start)
        for record in records where record.isActive {
            guard
                let day5 = calendar.date(byAdding: .day, value: 5, to: record.startDate),
                day5 > now
            else { continue }
            await scheduleEndReminder(recordID: record.id, fireDate: day5)
        }

        // 2. Schedule "Has your period started?" reminder (3 days before next predicted date)
        if let latest = records.sorted(by: { $0.startDate > $1.startDate }).first,
           let nextDate = calendar.date(byAdding: .day, value: cycleLengthDays, to: latest.startDate),
           let reminderDate = calendar.date(byAdding: .day, value: -3, to: nextDate),
           reminderDate > now {
            await scheduleStartReminder(fireDate: reminderDate)
        }
    }

    // MARK: - Private helpers

    private func scheduleEndReminder(recordID: UUID, fireDate: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Period Tracker"
        content.body  = "Has your period stopped?"
        content.sound = .default
        content.categoryIdentifier = Self.categoryPeriodEnd
        content.userInfo = ["recordID": recordID.uuidString]

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "period_end_\(recordID.uuidString)",
            content: content,
            trigger: trigger)
        try? await center.add(request)
    }

    private func scheduleStartReminder(fireDate: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Period Tracker"
        content.body  = "Has your period started?"
        content.sound = .default
        content.categoryIdentifier = Self.categoryPeriodStart

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "period_start_\(UUID().uuidString)",
            content: content,
            trigger: trigger)
        try? await center.add(request)
    }
}
