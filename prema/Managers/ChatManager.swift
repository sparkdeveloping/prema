//
//  ChatManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/7/23.
//

import FirebaseDatabase
import Firebase
import Foundation
import SwiftUI
import UIKit

struct Location {
    var address: String
    var latitude: String
    var longitude: String
}

enum ChatMode: String {
    case regular = "regular", sensitive = "sensitive", destructive = "destructive"
}

enum ContextMode {
    case header, reactions
}

class ChatManager: ObservableObject {
    
    @Published var contextMode: ContextMode = .header
    @Published var selectedMessage: Message? {
        didSet {
            AppearanceManager.shared.hideTopBar = !(selectedMessage == nil)
        }
    }
    @Published var reply: Message?
    @Published var inbox: Inbox
    @Published var text = ""
    @Published var reaction: String?
    @Published var media: [Media] = []
    @Published var sticker: Media?
    @Published var showingStickerView: Bool = false
    @Published var location: Location?
    @Published var currentChatMode: ChatMode = .regular {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(currentChatMode.rawValue, forKey: "\(inbox.id)-chatmode")
        }
    }
    @Published var messages: [Message] = []
    
    var listeners: (ListenerRegistration?, ListenerRegistration?, ListenerRegistration?)
     var lastMessageDoc: DocumentSnapshot?
    
    let db = Firestore.firestore()
    
    init(_ inbox: Inbox) {
        self.inbox = inbox
        self.fetchMessages()
        self.listenForChatChanges()
    }
    deinit {
           self.removeHandlers()
           
       }
       
    func removeHandlers() {
            listeners.0?.remove()
            listeners.1?.remove()
            listeners.2?.remove()
            listeners.0 = nil
            listeners.1 = nil
            listeners.2 = nil
            
            print("this is called: deinit")
        }
    
    func getActivityStatus() {
//        for (index, profile) in inbox.members.enumerated() {
//            let ref = Database.database().reference().child("profiles").child(profile.id).child("status")
//                
//            ref.observe(.value) { snapshot in
//                if let data = snapshot.value as? [String: Any] {
//                    profile.status = data.parseActivity
//                }
//            }
//
//        }

    }
    
    func sendMessage() {
        if let profile = AccountManager.shared.currentProfile {
            let batch = db.batch()
            print("\n\n\n sending 1 \n\n\n\n")
            let id = db.collection("messages").document().documentID
            print("\n\n\n sending 2 \n\n\n\n")
            let timestamp = Timestamp(profile: profile, time: Date.now.timeIntervalSince1970)
            print("\n\n\n sending 3 \n\n\n\n")
            
            var type: MessageType = .text
            
            let message = Message(id: id, inboxID: self.inbox.id, type: type, media: nil, sticker: sticker, text: text.isEmpty ? nil:text, timestamp: timestamp, opened: [])
            
            print("\n\n\n sending 4 \n\n\n\n")
            let inbox = Inbox(id: self.inbox.id, members: self.inbox.members, requests: self.inbox.requests, accepts: self.inbox.accepts, recentMessage: message, creationTimestamp: self.inbox.creationTimestamp, unreadDict: [:])
            
            print("\n\n\n sending 5 \n\n\n\n \(self.inbox.dictionary.parseInbox().dictionary)")

            print("\n\n\n sending 6 \n\n\n\n")
            batch.setData(inbox.dictionary, forDocument: db.collection("inbox").document(self.inbox.id), merge: true)

            print("\n\n\n sending 7 \n\n\n\n")
            batch.setData(message.dictionary, forDocument: db.collection("inbox").document(inbox.id).collection("messages").document(id), merge: true)
            print("\n\n\n sending 8 \n\n\n\n")
            // Commit the batch

            batch.commit { (error) in
                if let error = error {
                    print("Error writing batch: \(error.localizedDescription)")
                } else {
                    print("Batch write successful")
                    inbox.notifications.processAndSendNotifications()
                }
            }
            self.inbox = inbox.dictionary.parseInbox()
        }
    }
    
    func fetchMessages() {
        if let profile = AccountManager.shared.currentProfile {
            Firestore.firestore().collection("inbox").document(inbox.id).collection("messages").whereField("isDeleted", isEqualTo: false).order(by: "timestamp.time", descending: true).getDocuments { snapshot, error in
                if let error {}
                if let snapshot {
                    self.messages = snapshot.documents.map { $0.data().parseMessage($0.documentID) }
                }
            }
        
        }
    }
    
    func listenForChatChanges() {
        if let profile = AccountManager.shared.currentProfile {
            Firestore.firestore().collection("inbox").document(inbox.id).collection("messages").addSnapshotListener { snapshot, error in
                if let error {}
                if let snapshot {
                    let changes = snapshot.documentChanges
                    
                    changes.forEach { change in
                        switch change.type {
                        case .added:
                            if !self.messages.contains(where: { $0.id == change.document.documentID }) {
                                withAnimation(.spring()) {
                                    self.messages.insert(change.document.data().parseMessage(change.document.documentID), at: 0)
                                }
                            }
                        case .modified:
                            if let index = self.messages.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.messages[index] = change.document.data().parseMessage(change.document.documentID)
                                }
                            }
                        case .removed:
                            if let index = self.messages.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.messages.remove(at: index)
                                }
                            }
                        }
                    }
                  
                }
            }
         
        }
    }
    
}
/*
class TypingObserver: ObservableObject {
    @Published var isTyping = false
    private var typingCancellable: AnyCancellable?

    func handleTyping(_ text: String, inbox: Inbox) {
        typingCancellable?.cancel()
        isTyping = true
        self.updateInboxStatus(to: [inbox], typing: true)
        typingCancellable = Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isTyping = false
                self?.updateInboxStatus(to: [inbox], typing: false)
            }
    }
    
    func handleInChat(bool: Bool, inbox: Inbox) {
        self.updateInboxStatus(to: [inbox], inChat: bool)
    }
    
    func isOnline(bool: Bool, inboxes: [Inbox] = [], tab: String = "Home") {
        if let _ = AccountManager.shared.currentAccount?.id {
            let ref = Ref().databaseIsOnline(uid: AccountManager.shared.currentAccount?.id ?? "")
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any,
                "tab": tab as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func updateInboxStatus(to: [Inbox], online: Bool? = nil, typing: Bool? = nil, inChat: Bool? = nil, tab: String? = nil) {
        to.forEach { to in
            print("our inbox id is: \(to.id)")
            let ref = Database.database().reference().child("direct").child("inbox").child(to.id).child("status")
            var dict: Dictionary<String, Any> = [:]
            
            if let online {
                dict["online"] = [AccountManager.shared.currentAccount?.id:online]
            }
            if let typing {
                dict["typing"] = [AccountManager.shared.currentAccount?.id:typing]
            }
            if let inChat {
                dict["inChat"] = [AccountManager.shared.currentAccount?.id:inChat]
            }
            if let tab {
                dict["tab"] = [AccountManager.shared.currentAccount?.id:tab]
            }
            print("our inbox id is: \(to.id) -- dict: \(dict)")
            
            if !(online == nil && typing == nil && inChat == nil && tab == nil) {
                ref.updateChildValues(dict)
            }
        }
    }
}
*/
