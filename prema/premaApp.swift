//
//  premaApp.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/16/23.
//

import Firebase
import SwiftUI
import PushKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging
@main

struct premaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appearance = AppearanceManager()
    @StateObject var navigation = NavigationManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appearance)
                .environmentObject(navigation)
                .onAppear {
                    AppearanceManager.shared = appearance
                    NavigationManager.shared = navigation

                }
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        // Set FCM delegate
        Messaging.messaging().delegate = self

        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Send device token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Process received notification
        let apsData = userInfo["aps"] as! [String: Any]
        let alertData = apsData["alert"] as! [String: Any]
        let title = alertData["title"] as! String
        let body = alertData["body"] as! String

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
           
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
}


extension AppDelegate: PKPushRegistryDelegate {
    // Called when the device token is received from Apple Push Notification service (APNs)
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP device token: \(deviceToken)")
        // You can send the device token to your server here
    }

    // Called when a VoIP notification is received
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Incoming VoIP notification: \(payload.dictionaryPayload)")

        // Handle the VoIP notification payload
    }

}
