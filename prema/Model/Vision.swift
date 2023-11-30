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


class Vision: Identifiable, Equatable, Codable, Hashable, ObservableObject {
    static func == (lhs: Vision, rhs: Vision) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: String
    var title: String
    var category: String
    var privacy: Privacy
    var comments: [Message]
    var deadline: Double
    var visionaries: [Profile]
    var accepts: [String]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
    @Published var tasks: [Task]
    
    init(id: String, title: String, category: String, privacy: Privacy, comments: [Message], deadline: Double, visionaries: [Profile], accepts: [String], timestamps: [Timestamp], completionTimestamp: Timestamp? = nil, tasks: [Task]) {
        self.id = id
        self.title = title
        self.category = category
        self.privacy = privacy
        self.comments = comments
        self.deadline = deadline
        self.visionaries = visionaries
        self.accepts = accepts
        self.timestamps = timestamps
        self.completionTimestamp = completionTimestamp
        self.tasks = tasks
    }
    
    enum CodingKeys: String, CodingKey {
            case id
            case title
            case category
            case privacy
            case comments
            case deadline
            case visionaries
            case accepts
            case timestamps
            case completionTimestamp
            case tasks
        }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            category = try container.decode(String.self, forKey: .category)
            privacy = try container.decode(Privacy.self, forKey: .privacy)
            comments = try container.decode([Message].self, forKey: .comments)
            deadline = try container.decode(Double.self, forKey: .deadline)
            visionaries = try container.decode([Profile].self, forKey: .visionaries)
            accepts = try container.decode([String].self, forKey: .accepts)
            timestamps = try container.decode([Timestamp].self, forKey: .timestamps)
            completionTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .completionTimestamp)
            tasks = try container.decode([Task].self, forKey: .tasks)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(title, forKey: .title)
            try container.encode(category, forKey: .category)
            try container.encode(privacy, forKey: .privacy)
            try container.encode(comments, forKey: .comments)
            try container.encode(deadline, forKey: .deadline)
            try container.encode(visionaries, forKey: .visionaries)
            try container.encode(accepts, forKey: .accepts)
            try container.encode(timestamps, forKey: .timestamps)
            try container.encode(completionTimestamp, forKey: .completionTimestamp)
            try container.encode(tasks, forKey: .tasks)
        }
    
}

extension [String: Any] {
    func parseVision(_ id: String? = nil) -> Vision {
        var _id = self["id"] as? String ?? UUID().uuidString
        
        if let id {
            _id = id
        }
        
        let title = self["title"] as? String ?? ""
        let category = self["category"] as? String ?? "other"
        let privacy = Privacy(rawValue: (self["privacy"] as? String ?? "private")) ?? .private
        let comments = (self["comments"] as? [[String: Any]] ?? []).map { $0.parseMessage() }
        let deadline = self["deadline"] as? Double ?? Date.now.timeIntervalSince1970
        let visionaries = (self["visionaries"] as? [[String: Any]] ?? []).map { $0.parseProfile() }
        let accepts = self["accepts"] as? [String] ?? []
        let timestamps = (self["timestamps"] as? [[String: Any]] ?? []).map { $0.parseTimestamp() }
        let completionTimestamp = (self["completionTimestamp"] as? [String: Any])?.parseTimestamp()
        let tasks = (self["tasks"] as? [[String: Any]] ?? []).map { $0.parseTask() }
        
        return .init(id: _id, title: title, category: category, privacy: privacy, comments: comments, deadline: deadline, visionaries: visionaries, accepts: accepts, timestamps: timestamps, completionTimestamp: completionTimestamp, tasks: tasks)
    }
}

class Task: Identifiable, Codable {
    var id: String
    var title: String
    var start: Double
    var end: Double
    var responsibles: [Profile]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
    var recursion: Recursion
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["title"] = self.title
        dict["start"] = self.start
        dict["end"] = self.end
        dict["responsibles"] = self.responsibles.map { $0.dictionary }
        dict["timestamps"] = self.timestamps.map { $0.dictionary }
        dict["completionTimestamp"] = self.completionTimestamp?.dictionary
        dict["recursion"] = self.recursion.rawValue

        return dict
        
    }
    
    init(id: String, title: String, start: Double, end: Double, responsibles: [Profile], timestamps: [Timestamp], completionTimestamp: Timestamp? = nil, recursion: Recursion) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.responsibles = responsibles
        self.timestamps = timestamps
        self.completionTimestamp = completionTimestamp
        self.recursion = recursion
    }
}

extension [String: Any] {
    
    func parseTask(_ id: String? = nil) -> Task {
        var _id = self["id"] as? String ?? UUID().uuidString
        
        if let id {
            _id = id
        }
        
        let title = self["title"] as? String ?? ""
        let recursion = Recursion(rawValue: (self["recursion"] as? String ?? "never")) ?? .never
        let start = self["start"] as? Double ?? Date.now.timeIntervalSince1970
        let end = self["end"] as? Double ?? Date.now.timeIntervalSince1970
        let responsibles = (self["visionaries"] as? [[String: Any]] ?? []).map { $0.parseProfile() }
        let accepts = self["accepts"] as? [String] ?? []
        let timestamps = (self["timestamps"] as? [[String: Any]] ?? []).map { $0.parseTimestamp() }
        let completionTimestamp = (self["completionTimestamp"] as? [String: Any])?.parseTimestamp()
        
        return .init(id: _id, title: title, start: start, end: end, responsibles: responsibles, timestamps: timestamps, completionTimestamp: completionTimestamp, recursion: recursion)
    }
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
        dict["type"] = self.type.rawValue
        if let media = self.media {
            dict["media"] = media.map { $0.dictionary }
        }
        dict["inboxID"] = self.inboxID
//        dict["timestamp"] = self.timestamp.dictionary
        dict["timestamp"] = timestamp.dictionary
        if let destruction {
            dict["destruction"] = self.destruction
        }
        if let expiry {
            dict["expiry"] = self.expiry
        }
        dict["timestamp"] = timestamp.dictionary
        if let sticker {
            dict["sticker"] = sticker.dictionary
        }
        dict["isDeleted"] = false

        return dict
    }
}
