//
//  NotificationManager.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 21/06/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error solicitando autorización: \(error.localizedDescription)")
            } else {
                print("Permiso de notificación otorgado: \(granted)")
                if granted {
                    self.scheduleDailyNotification()
                }
            }
        }
    }

    func scheduleDailyNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard let date = UserDefaults.standard.object(forKey: "userFreeTime") as? Date else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "PeaceMaker"
        content.body = "Hola, ¿cómo te sientes hoy?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "daily_checkin", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error programando notificación: \(error.localizedDescription)")
            }
        }
    }
}
