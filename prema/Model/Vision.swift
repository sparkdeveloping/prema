//
//  Vision.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Foundation

enum Recursion: String {
    case never = "Never", daily = "Daily", weekly = "Weekly", monthly = "Monthly", yearly = "Yearly"
}

enum MessageType: String {
    case text = "text", image = "image", video = "video", audio = "audio", sticker = "sticker"
}


struct Vision: Identifiable {
    var id: String
    var name: String
    var description: String
    var comments: [Comment]
    var deadline: Double
    var visionaries: [Profile]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
}

struct Task: Identifiable {
    var id: String
    var name: String
    var description: String
    var comments: [Comment]
    var startDate: Double
    var endDate: Double
    var responsibles: [Profile]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
    var recursion: Recursion
}

struct Comment: Identifiable {
    var id: String
    var profile: [Profile]
    var message: [Message]
    var timestamp: Double
}

class Message: ObservableObject, Identifiable, Equatable {
    init(id: String, inboxID: String, type: MessageType, media: [Media]? = nil, sticker: Media?, text: String? = nil, timestamp: Timestamp, destruction: Double? = nil, expiry: Double? = nil, isSent: Bool = true, opened: [Timestamp]) {
        self.id = id
        self.inboxID = inboxID
        self.type = type
        self.media = media
        self.sticker = sticker
        self.text = text
        self.timestamp = timestamp
        self.destruction = destruction
        self.expiry = expiry
        self.isSent = isSent
        self.opened = opened
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
           return lhs.id == rhs.id
       }
       
       func hash(into hasher: inout Hasher) {
             hasher.combine(id)
         }
       
    
  
    
    var id: String
    var inboxID: String
    @Published var frame: CGRect = .zero
    var type: MessageType
    var media: [Media]?
    var sticker: Media?
    var text: String?
    var timestamp: Timestamp
    
    var destruction: Double? = nil
    var expiry: Double? = nil
    
    @Published var isSent: Bool = true
    
    @Published var isMessageSendError: Bool = false
    
    var opened: [Timestamp]

    var isOpened: Bool {
        return opened.contains(where: {$0.profile.id == AccountManager.shared.currentProfile?.id })
    }
    var reply: Message?
    var isReply = false
}


struct Timestamp: Identifiable {
    var id: String = UUID().uuidString
    var profile: Profile
    var time: Double
}



extension [String : Any] {
    func parseMessage(_ id: String? = nil) -> Message {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let text = self["text"] as? String
        let sticker = (self["sticker"] as? [String: Any])?.parseMedia()
        let mediaDict = self["media"] as? [[String: Any]] ?? []
        let media = mediaDict.map { $0.parseMedia() }
        let inboxID = self["inboxID"] as? String ?? UUID().uuidString
        let timestampDict = self["timestamp"] as? [String: Any] ?? [:]
        
        let destruction = self["destruction"] as? Double
        let expiry = self["expiry"] as? Double
        
        let type = MessageType(rawValue: (self["type"] as? String ?? "text")) ?? .text
        
        let timestamp = timestampDict.parseTimestamp()
        
        let openedDict = self["opened"] as? [[String: Any]] ?? []
        let opened = openedDict.map { $0.parseTimestamp() }
        
        return .init(id: _id, inboxID: inboxID, type: type, media: media, sticker: sticker, text: text, timestamp: timestamp, destruction: destruction, expiry: expiry, opened: opened)
    }
}

extension Timestamp {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["profile"] = self.profile.dictionary
        dict["time"] = self.time
        
        return dict
    }
}

extension Message {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        if let text = self.text {
            dict["text"] = text
        }
        if let media = self.media {
            dict["media"] = media.map { $0.dictionary }
        }
        dict["inboxID"] = self.inboxID
//        dict["timestamp"] = self.timestamp.dictionary
        dict["timestamp"] = timestamp.dictionary
        dict["isDeleted"] = false

        return dict
    }
}
