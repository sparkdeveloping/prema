//
//  Vision.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import SwiftUI
import Foundation

enum Recursion: String, Codable {
    case never = "never", hourly = "hourly", daily = "daily", weekly = "weekly", monthly = "monthly", yearly = "yearly"
    static var allCases: [Recursion] = [.never, .hourly, .daily, .weekly, .monthly, .yearly]
}

extension String {
    var recursion: Recursion {
        return Recursion(rawValue: self.lowercased()) ?? .never
    }
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
    var requests: [String]
    var timestamps: [Timestamp]
    var completionTimestamp: Timestamp?
    @Published var tasks: [Task]
    var priorityPercentage: Double {
        // Filter tasks that are completed
        let completedTasks = tasks.filter { $0.completionTimestamp != nil }

        // Calculate the percentage of completed tasks
        let completionPercentage = Double(completedTasks.count) / Double(tasks.count)
        
        // Calculate the average proximity of tasks to the deadline
        let deadlineProximity = tasks.map { task in
            abs(task.end - deadline)
        }.reduce(0, +) / Double(tasks.count)
        
        // Combine completion percentage and deadline proximity to get overall priority
        let overallPriority = (completionPercentage + (1 - deadlineProximity)) / 2.0
        
        // Convert to percentage (0-100)
        let priorityPercentage = overallPriority * 100.0
        
        return priorityPercentage
    }
    
    var priority: String {
        if self.deadline - Date.now.timeIntervalSince1970 < 0 {
            return self.tasks.count == self.tasks.filter { $0.completionTimestamp != nil }.count ? "COMPLETED" : "PAST DUE"
        }
        return priorityPercentage >= 75 ? "SERIOUS":priorityPercentage >= 50 ? "HIGH":priorityPercentage >= 30 ? "MEDIUM":"LOW"
    }
    
    var priorityColor: Color {
        if self.deadline - Date.now.timeIntervalSince1970 < 0 {
            return self.tasks.count == self.tasks.filter { $0.completionTimestamp != nil }.count ? AppearanceManager.shared.currentTheme.vibrantColors[0] : .red
        }
        return priorityPercentage >= 75 ? .red:priorityPercentage >= 50 ? .orange:priorityPercentage >= 30 ? .blue:.green
    }
    
    init(id: String, title: String, category: String, privacy: Privacy, comments: [Message], deadline: Double, visionaries: [Profile], accepts: [String], requests: [String], timestamps: [Timestamp], completionTimestamp: Timestamp? = nil, tasks: [Task]) {
        self.id = id
        self.title = title
        self.category = category
        self.privacy = privacy
        self.comments = comments
        self.deadline = deadline
        self.visionaries = visionaries
        self.accepts = accepts
        self.requests = requests
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
            case requests
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
        requests = try container.decode([String].self, forKey: .requests)
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
            try container.encode(requests, forKey: .requests)
            try container.encode(timestamps, forKey: .timestamps)
            try container.encode(completionTimestamp, forKey: .completionTimestamp)
            try container.encode(tasks, forKey: .tasks)
        }
    
    var dictionary: [String: Any] {
        var dict: [String : Any] = [:]
        dict["id"] = self.id
        dict["title"] = self.title
        dict["category"] = self.category
        dict["privacy"] = self.privacy.rawValue
        dict["comments"] = self.comments.map {$0.dictionary}
        dict["deadline"] = self.deadline
        dict["visionaries"] = self.visionaries.map {$0.dictionary}
        dict["accepts"] = self.accepts
        dict["requests"] = self.requests
        dict["timestamps"] = self.timestamps.map {$0.dictionary}
        dict["completionTimestamp"] = self.completionTimestamp.map {$0.dictionary}
        dict["tasks"] = self.tasks
        dict[""] = self.id
        return dict
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
        let requests = self["requests"] as? [String] ?? []
        let timestamps = (self["timestamps"] as? [[String: Any]] ?? []).map { $0.parseTimestamp() }
        let completionTimestamp = (self["completionTimestamp"] as? [String: Any])?.parseTimestamp()
        let tasks = (self["tasks"] as? [[String: Any]] ?? []).map { $0.parseTask() }
        
        return .init(id: _id, title: title, category: category, privacy: privacy, comments: comments, deadline: deadline, visionaries: visionaries, accepts: accepts, requests: requests, timestamps: timestamps, completionTimestamp: completionTimestamp, tasks: tasks)
    }
}

class Task: Identifiable, Codable, ObservableObject {
    // Properties
    var id: String
    @Published var title: String
    @Published var start: Double
    @Published var end: Double
    @Published var responsibles: [Profile]
    @Published var timestamps: [Timestamp]
    @Published var completionTimestamp: Timestamp?
    @Published var recursion: Recursion
    @Published var reminder: Reminder
    
    // Keys for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case start
        case end
        case responsibles
        case timestamps
        case completionTimestamp
        case recursion
    }

    // Initializer
    init(id: String, title: String, start: Double, end: Double, responsibles: [Profile], timestamps: [Timestamp], completionTimestamp: Timestamp? = nil, recursion: Recursion, reminder: Reminder = Reminder()) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.responsibles = responsibles
        self.timestamps = timestamps
        self.completionTimestamp = completionTimestamp
        self.recursion = recursion
        self.reminder = reminder
    }

    // Codable methods
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        responsibles = try container.decode([Profile].self, forKey: .responsibles)
        timestamps = try container.decode([Timestamp].self, forKey: .timestamps)
        completionTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .completionTimestamp)
        recursion = try container.decode(Recursion.self, forKey: .recursion)
        reminder = Reminder()  // You may need to implement Reminder decoding if needed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(responsibles, forKey: .responsibles)
        try container.encode(timestamps, forKey: .timestamps)
        try container.encode(completionTimestamp, forKey: .completionTimestamp)
        try container.encode(recursion, forKey: .recursion)
    }
    
    // Additional methods
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
}


struct Reminder: Codable {
  var timeInterval: Double?
  var date: Double?
  var location: LocationReminder?
  var reminderType: ReminderType = .time
  var repeats = false
}

//extension [String: Any] {
//    func parseReminder() -> Reminder {//(_ id: String? = nil) -> Reminder {
////        var _id = self["id"] as? String ?? UUID
//        
//        let timeInterval = self["timeInterval"] as? Double
//        let timeInterval = self["timeInterval"] as? Double
//        let timeInterval = self["timeInterval"] as? Double
//        let timeInterval = self["timeInterval"] as? Double
//    }
//}

struct LocationReminder: Codable {
  var latitude: Double
  var longitude: Double
  var radius: Double
}

enum ReminderType: Int, CaseIterable, Identifiable, Codable {
  case time
  case calendar
  case location
  var id: Int { self.rawValue }
}
extension [String: Any] {
    
    func parseTask(_ id: String? = nil) -> Task {
        var _id = self["id"] as? String ?? UUID().uuidString
        
        if let id {
            _id = id
        }
        
        let title = self["title"] as? String ?? ""
        let reminder = (self["reminder"] as? [String: Any] ?? [:])
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
    init(id: String, inboxID: String, type: MessageType, media: [Media]? = nil, sticker: Sticker?, text: String? = nil, timestamp: Timestamp, destruction: Double? = nil, expiry: Double? = nil, isSent: Bool = false, opened: [Timestamp]) {
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
        sticker = try container.decodeIfPresent(Sticker.self, forKey: .sticker)
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
    var sticker: Sticker?
    var text: String?
    var timestamp: Timestamp
  
    var destruction: Double? = nil
    var expiry: Double? = nil
    
    @Published var isSent: Bool = false
    
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
        let sticker = (self["sticker"] as? [String: Any])?.parseSticker()
        let mediaDict = self["media"] as? [[String: Any]] ?? []
        let media = mediaDict.map { $0.parseMedia() }
        let inboxID = self["inboxID"] as? String ?? UUID().uuidString
        let timestampDict = self["timestamp"] as? [String: Any] ?? [:]
        let reply = (self["reply"] as? [String: Any])?.parseMessage()

        let destruction = self["destruction"] as? Double
        let expiry = self["expiry"] as? Double
        
        let type = MessageType(rawValue: (self["type"] as? String ?? "text")) ?? .text
        
        let timestamp = timestampDict.parseTimestamp()
        
        let openedDict = self["opened"] as? [[String: Any]] ?? []
        let opened = openedDict.map { $0.parseTimestamp() }
        let message = Message.init(id: _id, inboxID: inboxID, type: type, media: media, sticker: sticker, text: text, timestamp: timestamp, destruction: destruction, expiry: expiry, isSent: true, opened: opened)
        reply?.isReply = true
        message.reply = reply
        return message
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
            dict["destruction"] = destruction
        }
        if let expiry {
            dict["expiry"] = expiry
        }
        dict["timestamp"] = timestamp.dictionary
        if let sticker {
            dict["sticker"] = sticker.dictionary
        }
        dict["isDeleted"] = false

        return dict
    }
}
