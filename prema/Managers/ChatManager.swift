//
//  ChatManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/7/23.
//

import Combine
import MapItemPicker
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
    @Published var inbox: Inbox
    @Published var selection = "chat"
    @Published var reply: Message?
    @Published var text = ""
    @Published var reaction: String?
    @Published var media: [Media] = []
    @Published var sticker: Sticker?
    @Published var showingStickerView: Bool = false
    @Published var location: Location?
    @Published var currentChatMode: ChatMode = .regular
    @Published var messages: [Message] = []
        
    var listeners: (ListenerRegistration?, ListenerRegistration?, ListenerRegistration?)
     var lastMessageDoc: DocumentSnapshot?
    
    let db = Firestore.firestore()
    @StateObject var selfManager = SelfManager.shared

    var visions: [Vision] {
        return selfManager.visions.filter({$0.visionaries.contains(where: { $0.id == inbox.members.first(where: {$0.id != AccountManager.shared.currentProfile?.id})?.id})})
    }
 
    init(_ inbox: Inbox) {
        self.inbox = inbox
    }
    
    func getActivityStatus(inbox: Inbox) {
        for (index, profile) in inbox.members.enumerated() {
            let ref = Database.database().reference().child("profiles").child(profile.id).child("status")
                
            ref.observe(.value) { snapshot in
                if let data = snapshot.value as? [String: Any] {
//                    profile.status = data.parseStatus()
                }
            }

        }

    }
    
    func deleteMessage() {
        guard let id = selectedMessage?.id else { return }
        Ref.firestoreDb.collection("inbox").document(inbox.id).collection("messages").document(id).delete()
    }
    
    func sendMessage() {
        
      
        if let profile = AccountManager.shared.currentProfile {
        
            let id = db.collection("messages").document().documentID
            let timestamp = Timestamp(profile: profile, time: Date.now.timeIntervalSince1970)
            
            var type: MessageType = .text
            
            if !media.isEmpty {
                type = media.contains(where: {$0.type == .audio }) ? .audio:media.contains(where: {$0.type == .audio }) ? .video:.image
            }
            if let sticker {
                type = .sticker
            }
            var ts: Double? = nil
            switch currentChatMode {
            case .regular:
                break
            case .sensitive:
                ts = 180
            case .destructive:
                ts = 180
            }
            
          
            
            let message = Message(id: id, inboxID: inbox.id, type: type, media: media, sticker: sticker, text: text.isEmpty ? nil:text, timestamp: timestamp, destruction: currentChatMode == .destructive  ? ts:nil, expiry: currentChatMode == .sensitive  ? ts:nil, opened: [])
            reply?.isReply = true
            message.reply = reply
            let inbox = Inbox(id: inbox.id, members: inbox.members, requests: inbox.requests, accepts: inbox.accepts, recentMessage: message, creationTimestamp: inbox.creationTimestamp, unreadDict: [:])
            

            var inboxDict = inbox.dictionary
            var messageDict = message.dictionary
            
            print("message is Sent is: \(message.isSent)")
            message.isSent = false
            print("message is Sent is: \(message.isSent)")
            withAnimation(.spring()) {
                self.messages.insert(message, at: 0)
                
            }
            
            if media.isEmpty {
                self.finalizeMessage(id: id, inbox: inbox, inboxDict: inboxDict, messageDict: messageDict)
            } else {
                StorageManager.uploadMedia(media: media, locationName: "direct") { dict in
                    messageDict["media"] = dict
                    self.finalizeMessage(id: id, inbox: inbox, inboxDict: inboxDict, messageDict: messageDict)
                } onError: { error in
                    message.isMessageSendError = true
                    message.isMessageSendError = true
                }

            }
            
            self.text = ""
            self.media.removeAll()
            self.inbox = inboxDict.parseInbox()
            self.selectedMessage = nil
            self.reply = nil
            self.sticker = nil
        }
    }
    
    func openedMessage(_ message: Message) {
        guard let profile = AccountManager.shared.currentProfile else { return }
        let timestamp = Timestamp(profile: profile, time: Date.now.timeIntervalSince1970)
        Ref.firestoreDb.collection("inbox").document(inbox.id).collection("messages").document(message.id).updateData([
            "opened": FieldValue.arrayUnion([timestamp.dictionary])
        ])

        
    }
    
    
    func finalizeMessage(id: String, inbox: Inbox, inboxDict: [String: Any], messageDict: [String: Any]) {
        let batch = db.batch()
        batch.setData(inboxDict, forDocument: db.collection("inbox").document(inbox.id), merge: true)

        print("\n\n\n sending 7 \n\n\n\n")
        batch.setData(messageDict, forDocument: db.collection("inbox").document(inbox.id).collection("messages").document(id), merge: true)
        print("\n\n\n sending 8 \n\n\n\n")
        // Commit the batch

        batch.commit { (error) in
            if let error = error {
                print("Error writing batch: \(error.localizedDescription)")
                if let index = self.messages.firstIndex(where: {$0.id == messageDict.parseMessage().id }) {
                    self.messages[index].isMessageSendError = true
                }
            } else {
                print("Batch write successful")
                inboxDict.parseInbox().processAndSendNotifications()
                if let index = self.messages.firstIndex(where: {$0.id == messageDict.parseMessage().id }) {
                    let message = self.messages[index]
                    message.isSent = true
                    self.messages[index] = message
                    self.messages[index].isSent = true
                }
            }
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

class TypingObserver: ObservableObject {
    @Published var isTyping = false
    private var typingCancellable: AnyCancellable?

    func handleTyping(_ text: String, inbox: Inbox) {
        typingCancellable?.cancel()
        isTyping = true
        AccountManager.shared.updateInboxStatus(to: [inbox], typing: true)
        typingCancellable = Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isTyping = false
                AccountManager.shared.updateInboxStatus(to: [inbox], typing: false)
            }
    }
    
    func handleInChat(bool: Bool, inbox: Inbox) {
        AccountManager.shared.updateInboxStatus(to: [inbox], inChat: bool)
    }
    
}

