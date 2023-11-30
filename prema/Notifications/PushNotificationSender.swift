//
//  PushNotificationSender.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//


import FirebaseDatabase
import FirebaseMessaging
import UIKit

let serverKey = "AAAAWIziT4k:APA91bF1awH3HXFGIdYqA42omSGgXpd1r5-zsLEhCKosB1yN7UwOg9eZyrJDdigdpb9kZzAGyLN0OTYn5tdXrEm4lWSZRryhtDYYBHWdEdALjWXqqTS20TwuX2sh1sPRYAyMcqogbArG"
let fcmUrl = "https://fcm.googleapis.com/fcm/send"

struct CustomNotification: Identifiable {
    var id: String
    var title: String
    var message: String
    var imageURLString: String?
    var type: String
    var recipient: String
    var from: String

    var dictionary: [String: Any] {
        
        var dict: [String: Any] = [:]
        
        dict["title"] = self.title
        dict["message"] = self.message
        dict["type"] = self.type
        dict["imageURLString"] = self.imageURLString
        dict["recipient"] = self.recipient
        dict["from"] = self.from

        return dict
    }
}

extension [String: Any] {
    func parseNotificaiton(_ id: String? = nil) -> CustomNotification {
        var _id = self["id"] as? String ?? UUID().uuidString
        
        if let id {
            _id = id
        }
        
        let title = self["title"] as? String ?? ""
        let message = self["message"] as? String ?? ""
        let type = self["type"] as? String ?? ""
        let imageURLString = self["imageURLString"] as? String ?? ""
        let recipient = self["recipient"] as? String ?? ""
        let from = self["from"] as? String ?? ""
        return .init(id: _id, title: title, message: message, type: type, recipient: recipient, from: from)
    }
}


extension Inbox {
    func processAndSendNotifications() {
        if let profile = AccountManager.shared.currentProfile {
            
            self.requests.forEach { recipient in
                let id1 = Ref.firestoreDb.collection("notifications").document().documentID
                    
                    let notificationForAccepts = CustomNotification(id: id1, title: profile.fullName, message: self.recentMessage?.text ?? "", imageURLString: self.avatar, type: "direct", recipient: recipient, from: profile.id)
                    
             
                    Ref.firestoreDb.collection("notifications").document(id1).setData(notificationForAccepts.dictionary)
                    
                
            }
            
            self.accepts.forEach { recipient in
                let id1 = Ref.firestoreDb.collection("notifications").document().documentID

                    let notificationForAccepts = CustomNotification(id: id1, title: profile.fullName, message: self.recentMessage?.text ?? "", imageURLString: self.avatar, type: "direct", recipient: recipient, from: profile.id)
                    
             
                Ref.firestoreDb.collection("notifications").document(id1).setData(notificationForAccepts.dictionary)

                
            }
            
        }
    }
}
/*
extension CustomNotification {
    func sendNotification() {
        let urlString = "https://fcm.googleapis.com/fcm/send"
//        let serverKey = "your_server_key"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("sending notificiation to \(self.topic)")
        
        let payload: [String: Any] = [
            "to": "/topics/\(self.topic)",
            "notification": [
                "title": self.title,
                "body": self.message,
                "image": self.imageURLString,
                "sound" : "default"
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

*/
