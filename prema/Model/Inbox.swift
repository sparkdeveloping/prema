//
//  Inbox.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/7/23.
//

import Algorithms
import Foundation

class Inbox: ObservableObject, Identifiable, Comparable, Hashable {
    
    init(id: String, members: [Profile], requests: [String], accepts: [String], displayName: String? = nil, avatarImageURL: String? = nil, recentMessage: Message? = nil, creationTimestamp: Timestamp, unreadDict: [String : Int?]) {
        self.id = id
        self.members = members
        self.requests = requests
        self.accepts = accepts
        self.displayName = displayName
        self.avatarImageURL = avatarImageURL
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
    var displayName: String?
    var avatarImageURL: String?
    var avatar: String? {
        if let displayName {
            return displayName
        } else if let profile = self.members.first(where: {$0 != AccountManager.shared.currentProfile }) {
            return profile.fullName
        }
        return ""
    }
    var name: String {
        if let displayName {
            return displayName
        } else if let profile = self.members.first(where: {$0 != AccountManager.shared.currentProfile }) {
            return profile.fullName
        }
        return ""
    }
    
    @Published var recentMessage: Message?
    var creationTimestamp: Timestamp
    var isGroup: Bool {
        return members.count > 2
    }
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
        var requests = self["requests"] as? [String] ?? []
        var accepts = self["accepts"] as? [String] ?? []
        let members = membersDict.map { $0.parseProfile() }
        let message = (self["recentMessage"] as? [String: Any])?.parseMessage()
        let creationTimestampDict = self["timestamp"] as? [String: Any] ?? [:]
        let creationTimestamp = creationTimestampDict.parseTimestamp()
        
        
        return Inbox(id: _id, members: members, requests: requests.removingDuplicates(), accepts: accepts.removingDuplicates(), displayName: displayName, avatarImageURL: avatarImageURL, recentMessage: message, creationTimestamp: creationTimestamp, unreadDict: unreadDict)
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
        if let name = self.displayName {
            dict["displayName"] = name
        }
        if let image = self.avatarImageURL {
            dict["avatarImageURL"] = image
        }
        dict["members"] = self.members.map { $0.dictionary }
       
        if let profile = AccountManager.shared.currentProfile {
            if let index = requests.firstIndex(where: {$0.id == profile.id }) {
                self.accepts.append(profile.id)
                self.requests.removeAll(where: {$0 == profile.id })
            }
        }
        
        dict["accepts"] = self.accepts
        dict["requests"] = self.requests
        
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
