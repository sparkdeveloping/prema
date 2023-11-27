//
//  Vision.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Foundation

enum Recursion: String, Codable {
    case never = "Never", daily = "Daily", weekly = "Weekly", monthly = "Monthly", yearly = "Yearly"
}

enum MessageType: String, Codable {
    case text = "text", image = "image", video = "video", audio = "audio", sticker = "sticker"
}


struct Vision: Identifiable, Equatable, Codable {
    static func == (lhs: Vision, rhs: Vision) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id: String
    var name: String
    var description: String
    var comments: [Comment]
    var deadline: Double
    var visionaries: [Profile]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
    var tasks: [Task]
}

struct Task: Identifiable, Codable {
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

struct Comment: Identifiable, Codable {
    var id: String
    var profile: [Profile]
    var message: [Message]
    var timestamp: Double
}

class Message: ObservableObject, Identifiable, Equatable, Codable {
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
    
    private enum CodingKeys: String, CodingKey {
          case id
          case inboxID
          case type
          case media
          case sticker
          case text
          case timestamp
          case destruction
          case expiry
          case isSent
          case isMessageSendError
          case opened
          case reply
          case isReply
          case frame
      }
      
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        inboxID = try container.decode(String.self, forKey: .inboxID)
        type = try container.decode(MessageType.self, forKey: .type)
        media = try container.decodeIfPresent([Media].self, forKey: .media)
        sticker = try container.decodeIfPresent(Media.self, forKey: .sticker)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        destruction = try container.decodeIfPresent(Double.self, forKey: .destruction)
        expiry = try container.decodeIfPresent(Double.self, forKey: .expiry)
        isSent = try container.decode(Bool.self, forKey: .isSent)
        isMessageSendError = try container.decode(Bool.self, forKey: .isMessageSendError)
        opened = try container.decode([Timestamp].self, forKey: .opened)
        reply = try container.decodeIfPresent(Message.self, forKey: .reply)
        isReply = try container.decode(Bool.self, forKey: .isReply)
        frame = try container.decode(CGRect.self, forKey: .frame)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(inboxID, forKey: .inboxID)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(media, forKey: .media)
        try container.encodeIfPresent(sticker, forKey: .sticker)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(destruction, forKey: .destruction)
        try container.encodeIfPresent(expiry, forKey: .expiry)
        try container.encode(isSent, forKey: .isSent)
        try container.encode(isMessageSendError, forKey: .isMessageSendError)
        try container.encode(opened, forKey: .opened)
        try container.encodeIfPresent(reply, forKey: .reply)
        try container.encode(isReply, forKey: .isReply)
        try container.encode(frame, forKey: .frame)
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
        return opened.contains(where: { $0.profile.id == AccountManager.shared.currentProfile?.id })
    }
    
    var reply: Message?
    var isReply = false

}



struct Timestamp: Identifiable, Codable {
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
