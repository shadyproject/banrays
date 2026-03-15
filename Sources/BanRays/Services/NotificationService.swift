import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()

    private var isAuthorized = false
    private var notifiedDevices: Set<UUID> = []

    private init() {}

    func requestAuthorization() async {
        do {
            isAuthorized = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            isAuthorized = false
        }
    }

    func notifySmartGlassesDetected(_ device: DiscoveredDevice) async {
        guard isAuthorized else { return }
        guard !notifiedDevices.contains(device.id) else { return }

        notifiedDevices.insert(device.id)

        let manufacturerName = device.manufacturerID
            .flatMap { ManufacturerIDs.name(for: $0) } ?? "Unknown"

        let content = UNMutableNotificationContent()
        content.title = "Smart Glasses Detected"
        content.body = "\(manufacturerName) device nearby: \(device.displayName)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "smartglasses-\(device.id.uuidString)",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func clearNotifiedDevices() {
        notifiedDevices.removeAll()
    }
}
