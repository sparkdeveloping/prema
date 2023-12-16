//
//  Inbox.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/7/23.
//

import Algorithms
import Foundation

class Inbox: ObservableObject, Identifiable, Comparable, Hashable {
    internal init(id: String, members: [Profile], requests: [String], accepts: [String], privates: [String] = [], favorites: [String] = [], mutes: [String] = [], deletes: [String: Any] = [:], displayName: String? = nil, avatarImageURL: String? = nil, status: ActivityStatus = .init(), recentMessage: Message? = nil, creationTimestamp: Timestamp, unreadDict: [String : Int?]) {
        self.id = id
        self.members = members
        self.requests = requests
        self.privates = privates
        self.accepts = accepts
        self.favorites = favorites
        self.mutes = mutes
        self.deletes = deletes
        self.displayName = displayName
        self.avatarImageURL = avatarImageURL
        self.status = status
        self.recentMessage = recentMessage
        self.creationTimestamp = creationTimestamp
        self.unreadDict = unreadDict
    }
    
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: Inbox, rhs: Inbox) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: Inbox, rhs: Inbox) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var members: [Profile]
    var requests: [String]
    var accepts: [String]
    var privates: [String] = []
    var favorites: [String] = []
    var mutes: [String] = []
    var deletes: [String: Any] = [:]
    var displayName: String?
    var avatarImageURL: String?
    var messages: [Message] = []
    var avatar: String? {
        if let displayName {
            return displayName
        } else if let profile = self.members.first(where: {$0 != AccountManager.shared.currentProfile }) {
            return profile.avatarImageURL
        }
        return ""
    }
    var name: String {
        if let displayName {
            print("this is the one rendered 1: \(displayName)")
            return self.isGroup ? displayName:displayName.formattedName(from: members.map { $0.fullName })
        } else if isGroup {
            return members.map { ($0.fullName.first ?? "X").uppercased() }.reduce("") { "\($0)" + $1 }
        } else if let profile = self.members.first(where: {$0 != AccountManager.shared.currentProfile }) {
            print("this is the one rendered 2: \(profile.fullName)")
            return profile.fullName.formattedName(from: members.map { $0.fullName })
        }
        return ""
    }
    @Published var status: ActivityStatus = .init()

    @Published var recentMessage: Message?
    var creationTimestamp: Timestamp
    var isGroup: Bool {
        return members.count > 2
    }
//    var isFavorite: Bool {
//        return favorites.contains(where: {AccountManager.shared.currentProfile?.id == $0})
//    }
//    var isMuted: Bool {
//        return mutes.contains(where: {AccountManager.shared.currentProfile?.id == $0})
//    }
//    var isDeleted: Bool {
//        return deletes.contains(where: {AccountManager.shared.currentProfile?.id == $0})
//    }
    var unreadDict: [String: Int?]
    var unreadCount: Int {
        if let profile = AccountManager.shared.currentProfile {
            return unreadDict[profile.id] as? Int ?? 0
        }
        return 0
    }
    var isUnread: Bool {
        if let profile = AccountManager.shared.currentProfile {
            return (unreadDict[profile.id] as? Int ?? 0) > 0
        }
        return false
    }
}

extension [String: Any] {
    func parseInbox(_ id: String? = nil) -> Inbox {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let displayName = self["displayName"] as? String
        let avatarImageURL = self["avatarImageURL"] as? String
        
   
        
        let membersDict = self["members"] as? [[String: Any]] ?? []
        let unreadDict = self["unread"] as? [String: Int?] ?? [:]
        let requests = self["requests"] as? [String] ?? []
        let accepts = self["accepts"] as? [String] ?? []
        let privates = self["privates"] as? [String] ?? []
        let favorites = self["favorites"] as? [String] ?? []
        let mutes = self["mutes"] as? [String] ?? []
        let deletes = self["deletes"] as? [String: Any] ?? [:]
        let members = membersDict.map { $0.parseProfile() }
        let message = (self["recentMessage"] as? [String: Any])?.parseMessage()
        let creationTimestampDict = self["timestamp"] as? [String: Any] ?? [:]
        let creationTimestamp = creationTimestampDict.parseTimestamp()
        
        
        return Inbox(id: _id, members: members, requests: requests.removingDuplicates(), accepts: accepts.removingDuplicates(), privates: privates, favorites: favorites, mutes: mutes, deletes: deletes, displayName: displayName, avatarImageURL: avatarImageURL, recentMessage: message, creationTimestamp: creationTimestamp, unreadDict: unreadDict)
    }
}

extension [String: Any] {
    func parseTimestamp(id: String? = nil) -> Timestamp {
        var _id = self["id"] as? String ?? UUID().uuidString
        
        if let id {
            _id = id
        }
        
        let profileDict = self["profile"] as? [String: Any] ?? [:]
        let profile = profileDict.parseProfile()
        let time = self["time"] as? Double ?? Date.now.timeIntervalSince1970
        
        return .init(id: _id, profile: profile, time: time)
    }
}

extension Inbox {
    var dictionary: [String: Any] {
        
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
  
        if let image = self.avatarImageURL {
            dict["avatarImageURL"] = image
        }
        dict["members"] = self.members.map { $0.dictionary }
       
        if let profile = AccountManager.shared.currentProfile {
            if requests.contains(where: {$0.id == profile.id }) {
                self.accepts.append(profile.id)
                self.requests.removeAll(where: {$0 == profile.id })
            }
        }
        
        if let profile = AccountManager.shared.currentProfile {
            if !accepts.contains(where: {$0.id == profile.id }) {
                self.accepts.append(profile.id)
            }
        }
        
        dict["accepts"] = self.accepts
        dict["requests"] = self.requests
        dict["privates"] = self.privates
        dict["favorites"] = self.favorites
        dict["mutes"] = self.mutes
        
        if let profile = AccountManager.shared.currentProfile {
            self.deletes[profile.id] = self.deletes[profile.id] ?? false
        }
        dict["deletes"] = self.deletes
        
        if let message = self.recentMessage {
            dict["recentMessage"] = message.dictionary
        }
        
        var unreadDict = self.unreadDict
        members.forEach { member in
            if let id = AccountManager.shared.currentProfile?.id, id == member.id {
                unreadDict[id] = 0
            } else {
                unreadDict[member.id] = (unreadDict[member.id] as? Int ?? 0) + 1
            }
        }
     
        dict["unread"] = unreadDict
        dict["creationTimestamp"] = self.creationTimestamp.dictionary
        
        if let displayName {
            dict["displayName"] = displayName
        }
     
        return dict
    }
}

struct Sticker: Identifiable, Codable {
    var id: String = UUID().uuidString
    var imageURLString: String?
    var inboxID: String?
    var timestamp: Timestamp
    

    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["imageURL"] = self.imageURLString
        dict["timestamp"] = self.timestamp.dictionary
        dict["inboxID"] = self.inboxID
        
        return dict
    }
}

extension [String: Any] {
    func parseSticker(id: String? = nil) -> Sticker {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let timestamp = (self["timestamp"] as? [String: Any] ?? [:]).parseTimestamp()
        let imageURLString = self["imageURL"] as? String ?? ""
        let inboxID = self["inboxID"] as? String
        
        return .init(id: _id, imageURLString: imageURLString, inboxID: inboxID, timestamp: timestamp)
        
    }
}
