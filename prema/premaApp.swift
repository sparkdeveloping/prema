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

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification permissions granted: \(granted)")
        }
        center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        
        center.delegate = self
                
        Messaging.messaging().delegate = self
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        let openAction = UNNotificationAction(identifier: "OpenNotification", title: NSLocalizedString("Abrir", comment: ""), options: UNNotificationActionOptions.foreground)
        let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [openAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories(Set([deafultCategory]))
        
        application.registerForRemoteNotifications()
        
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
            voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("here is your token: \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Received FCM token: \(fcmToken ?? "")")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        process(notification)
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        process(response.notification)

        completionHandler()
    }
    
    private func process(_ notification: UNNotification) {
        // 1
        if let id = notification.request.content.userInfo["inboxID"] as? String {
         
            NavigationManager.shared.notificationInboxID = id
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            //        if let inbox = userInfo["inbox"] as? [String: Any] {
            //          NavigationManager.shared.selectedTab = .direct
            //          NavigationManager.shared.showSidebar = false
            //            NavigationManager.shared.path.append(inbox.parseInbox())
            //      }
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {


        if let menu = userInfo["inboxID"] as? String {
            print("\n\n\n THIS IS GETTING CALLED: " + menu)
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
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
