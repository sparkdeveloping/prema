//
//  DirectManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/6/23.
//

import AlgoliaSearchClient
import FirebaseFirestore
import FirebaseDatabase
import Foundation
import SwiftUI

class DirectManager: ObservableObject {
    
    @Published var accepts: [Inbox] = []
    @Published var requests: [Inbox] = []
    var inboxes: [Inbox] {
        return selectedDirectMode == "all" ? self.accepts: selectedDirectMode == "groups" ? self.accepts.filter({ $0.isGroup }) :self.requests
    }
    @Published var inbox: Inbox?
    @Published var selectedDirectMode = "all"
    @Published var stickers: [Sticker] = []

    let client = SearchClient(appID: "0D2Q7L4DCF", apiKey: "ec1b50b1def1c426ed5f82614d547ed2")
    
    static var shared = DirectManager()
    
    func fetchStickers() {
        Ref.firestoreDb.collection("stickers")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("error loading stickers: \(error.localizedDescription)")
                }
                if let snapshot = snapshot {
                    snapshot.documents.forEach { document in
                        let sticker = document.data().parseSticker()
                        self.stickers.append(sticker)
                    }
                }
            }
    }
    
    init() {
//        self.fetchInboxes()
        fetchStickers()
        self.listenForInboxChanges()
        
    }
    
    func fetchInbox(_ id: String, completion: @escaping(Inbox) -> ()) {
        if let profile = AccountManager.shared.currentProfile {
            Firestore.firestore().collection("inbox").document(id).getDocument { snapshot, error in
                if let error {}
                if let snapshot {
                    if let data = snapshot.data() {
                        completion(data.parseInbox())
                    }
                }
            }
        }
    }
    
    func fetchInboxes() {
        if let profile = AccountManager.shared.currentProfile {
            Firestore.firestore().collection("inbox").whereField("accepts", arrayContains: profile.id).order(by: "recentmessage.recentMessage.timestamp.time.time", descending: true).getDocuments { snapshot, error in
                if let error {}
                if let snapshot {
                    self.accepts = snapshot.documents.map { $0.data().parseInbox($0.documentID) }
                }
            }
            Firestore.firestore().collection("inbox").whereField("requests", arrayContains: profile.id).order(by: "recentmessage.recentMessage.timestamp.time.time", descending: true).getDocuments { snapshot, error in
                if let error {}
                if let snapshot {
                    self.requests = snapshot.documents.map { $0.data().parseInbox($0.documentID) }
                }
            }
        }
    }
    
    func listenForInboxChanges() {
        print("this is being called for inbox")
        if let profile = AccountManager.shared.currentProfile {
            Firestore.firestore().collection("inbox").whereField("accepts", arrayContains: profile.id).order(by: "recentMessage.timestamp.time", descending: true).addSnapshotListener { snapshot, error in
                print("this is being called for inbox 2")
                if let error {
                    print("this is being called for inbox 2.5: \(error.localizedDescription)")

                }
                if let snapshot {
                    let changes = snapshot.documentChanges
                    
                    changes.forEach { change in
                        switch change.type {
                        case .added:
                            if !self.accepts.contains(where: { $0.id == change.document.documentID }) {
                                withAnimation(.spring()) {
                                    self.accepts.append(change.document.data().parseInbox(change.document.documentID))
                                }
                                print("this is being called for inbox 3")
                            }
                        case .modified:
                            if let index = self.accepts.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.accepts.remove(at: index)
                                    self.accepts.insert(change.document.data().parseInbox(change.document.documentID), at: 0)
                                }
                            }
                        case .removed:
                            if let index = self.accepts.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.accepts.remove(at: index)
                                }
                            }
                        }
                    }
                  
                }
            }
            Firestore.firestore().collection("inbox").whereField("requests", arrayContains: profile.id).addSnapshotListener { snapshot, error in
                if let error {
                    
                }
                if let snapshot {
                    let changes = snapshot.documentChanges
                    
                    changes.forEach { change in
                        switch change.type {
                        case .added:
                            if !self.requests.contains(where: { $0.id == change.document.documentID }) {
                                withAnimation(.spring()) {
                                    self.requests.insert(change.document.data().parseInbox(change.document.documentID), at: 0)
                                }
                            }
                        case .modified:
                            if let index = self.requests.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.requests[index] = change.document.data().parseInbox(change.document.documentID)
                                }
                            }
                        case .removed:
                            if let index = self.requests.firstIndex(where: { $0.id == change.document.documentID } ) {
                                withAnimation(.spring()) {
                                    self.requests.remove(at: index)
                                }
                            }
                        }
                    }
                  
                }
            }
        }
    }
    
    func retrieveTempProfiles(completion: @escaping([Profile]) -> ()) {
        Firestore.firestore().collection("profiles").limit(to: 50).getDocuments { snapshot, error in
            if let error {
                completion([])
            }
            if let snapshot {
                completion(snapshot.documents.map { $0.data().parseProfile($0.documentID)})
            }
        }
    }
    
    func searchProfiles(search: String, completion: @escaping([Profile]) -> ()) {
        if search.isEmpty {
            retrieveTempProfiles() { p in
                completion(p)
                return
            }
            return
        }

        let index = client.index(withName: "profiles")
        print(" we are searching \(search)")
        let query = Query(search)
        
        index.search(query: query) { result in
            print(" \n\n\n we are searching 2 \n\n\n \(result)")
            if case .success(let response) = result {
                
                response.hits.forEach { hit in
                    print(" \n\n\n we are searching 3 \n\n\n \(hit)")
                    var profiles: [Profile] = []
                    
                    if let object = hit.object.object() as? [String: Any] {
                        profiles.append(object.parseProfile(hit.objectID.rawValue))
                        
                    }
                    completion(profiles)
                }
            }
        }
        
       
    }
}

class ActivityStatusManager: ObservableObject {
    @Published var status: ActivityStatus = .init()
    
    var inbox: Inbox!
    var statusHandle: DatabaseHandle!
    static var shared = ActivityStatusManager()
    var online: [Profile] {
        var onl: [Profile] = []
        self.status.isOnline.forEach({ (key, value) in
            print("the online: \(key) - \(value)")
            if let profile = self.inbox.members.first(where: { $0.id == key }) {
                if value == true {
                    onl.append(profile)
                }
            }
        })
        return onl.filter({$0.id != AccountManager.shared.currentProfile?.id})
    }
    
    var inChat: [Profile] {
        var onl: [Profile] = []
        self.status.inChat.forEach({ (key, value) in
            print("the online: \(key) - \(value)")
            if let profile = self.inbox.members.first(where: { $0.id == key }) {
                if value == true {
                    onl.append(profile)
                }
            }
        })
        return onl.filter({$0.id != AccountManager.shared.currentProfile?.id})
    }
    
    var typing: [Profile] {
        var onl: [Profile] = []
        self.status.typing.forEach({ (key, value) in
            print("the online: \(key) - \(value)")
            if let profile = self.inbox.members.first(where: { $0.id == key }) {
                if value == true {
                    onl.append(profile)
                }
            }
        })
        return onl.filter({$0.id != AccountManager.shared.currentProfile?.id})
    }
    
    var onlineCount: Int {
        return online.count
    }
    var inChatCount: Int {
        return inChat.count
    }
    var typingCount: Int {
        return typing.count
    }
    
    var statusText: String {
        if typingCount > 2 {
            return "\(typingCount) typing..."
        } else if typingCount == 2 {
            return typing[0].fullName + " & " +  typing[1].fullName + " typing..."
        } else if typingCount == 1 {
            return "typing..."
        }
        if inChatCount > 2 {
            return "\(inChatCount) active."
        } else if inChatCount == 2 {
            return inChat[0].fullName + " & " +  inChat[1].fullName + " active."
        } else if inChatCount == 1 {
            return "active"
        }
        if onlineCount > 2 {
            return "\(onlineCount) online."
        } else if onlineCount == 2 {
            return online[0].fullName + " & " +  online[1].fullName + " online."
        } else if onlineCount == 1 {
            return "online"
        }
        return "offline"
    }
    
    
    var statusColor: LinearGradient {
       
        if !inChat.isEmpty {
            return .linearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if !online.isEmpty {
            return .linearGradient(colors: [.green, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        }

        return .linearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    func getStatus(inbox: Inbox) {
            self.inbox = inbox
            let ref = Database.database().reference().child("direct").child("inbox").child(inbox.id).child("status")
                
            statusHandle = ref.observe(.value) { snapshot in
                if let data = snapshot.value as? [String: Any] {
                    let status = data.parseStatus()

                    self.status = status
    //                        self.accepts.remove(at: index)
    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    //                            self.accepts.insert(inbox, at: 0)
    //                        }
    //                    self.accepts[index].unread = inbox.unread
                    }
                
            }

        }
    
}

extension String {

    func formattedName(from names: [String]) -> String {
        let matchingNames = names.filter { $0.lowercased() == self.lowercased() }

        if matchingNames.count == 1 {
            let components = self.components(separatedBy: " ")
            return components.first ?? self
        } else {
            var formattedName: String

            let sortedMatchingNames = matchingNames.sorted()

            if let index = sortedMatchingNames.firstIndex(of: self) {
                let count = index + 1
                let components = self.components(separatedBy: " ")

                if components.count > 1 {
                    let firstName = components[0]
                    let lastNameInitial = components.last?.prefix(1) ?? ""
                    formattedName = count == 1 ? "\(firstName)" : "\(firstName) \(lastNameInitial) \(count)"
                } else {
                    formattedName = self
                }
            } else {
                formattedName = self
            }

            return formattedName
        }
    }
}
