//
//  PushNotificationSender.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseMessaging
import UIKit

let serverKey = "AAAAWIziT4k:APA91bF1awH3HXFGIdYqA42omSGgXpd1r5-zsLEhCKosB1yN7UwOg9eZyrJDdigdpb9kZzAGyLN0OTYn5tdXrEm4lWSZRryhtDYYBHWdEdALjWXqqTS20TwuX2sh1sPRYAyMcqogbArG"
let fcmUrl = "https://fcm.googleapis.com/fcm/send"

struct CustomNotification {
    var topic: String
    var title: String
    var message: String
    var imageURLString: String?
}

extension Inbox {
    var notifications: [CustomNotification] {
        var n: [CustomNotification] = []
        if let message = self.recentMessage {
            self.members.forEach { member in
                if member.id == AccountManager.shared.currentProfile?.id {
                    var title: String
                    var description: String
                    var imageURL: String?
                    title = message.timestamp.profile.fullName
                    
                    if self.accepts.contains(member.id) {
                        if let text = message.text {
                            description = text
                        } else {
                            description = "New message"
                        }
                    } else {
                        description = "Wants to directly message you"
                    }
                    imageURL = message.timestamp.profile.avatarImageURL
                    
                    n.append(CustomNotification(topic: member.id + "direct", title: title, message: description, imageURLString: imageURL))
                }
            }
        }
        return n
    }
}

extension [CustomNotification] {
    func processAndSendNotifications() {
        self.forEach { notif in
            notif.sendNotification()
        }
    }
}

extension CustomNotification {
    func sendNotification() {
        let urlString = "https://fcm.googleapis.com/fcm/send"
//        let serverKey = "your_server_key"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        print("sending notificiation to \(toUser)-\(type)")
        
        let payload: [String: Any] = [
            "to": "/topics/\(self.topic)",
            "notification": [
                "title": self.title,
                "body": self.message,
                "image": self.imageURLString
            ],
            "data": [
                "custom_key1": "custom_value1",
                "custom_key2": "custom_value2"
            ],
            "apns": [
                "payload": [
                    "aps": [
                        "mutable-content": 1
                    ]
                ],
                "fcm_options": [
                    "image": self.imageURLString ?? ""
                ]
            ],
            "android": [
                "notification": [
                    "image": self.imageURLString
                ]
            ]
        ]

            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error creating JSON payload: \(error.localizedDescription)")
                return
            }
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Notification sent. Response: \(responseString)")
                } else {
                    print("Notification sent successfully")
                }
            }
        }.resume()
        

    }
}

