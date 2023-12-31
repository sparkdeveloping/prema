//
//  Profile.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import Foundation

enum Gender: String, Codable {
    case male = "Male", female = "Female", none = "Select Gender"
    static var allCases: [Self] = [.male, .female]
}

enum Privacy: String, Codable {
    case `private` = "Private", `public` = "Public", direct = "Direct"
}

struct Settings: Codable, Hashable {
    var allowedNotifications: [String]
}

struct ActivityStatus: Codable, Equatable {
    var isOnline: [String:Bool] = [:]
    var latest: Double = Date.now.timeIntervalSince1970
    var typing: [String:Bool] = [:]
    var inChat: [String:Bool] = [:]
    
    
}

extension [String: Any] {
    func parseStatus() -> ActivityStatus {
        
        let isOnline = self["online"] as? [String:Bool] ?? [:]
        let latest = self["latest"] as? Double ?? 0
        let typing = self["typing"] as? [String:Bool] ?? [:]
        let inChat = self["inChat"] as? [String:Bool] ?? [:]

        return .init(isOnline: isOnline, latest: latest, typing: typing, inChat: inChat)
        
    }
}

class Profile: Identifiable, Codable, Hashable {
     init(id: String = UUID().uuidString, fullName: String = "Empty Name", username: String = "premauser", bio: String = "no bio", gender: Gender = .none, birthday: Double = 0, avatars: [Media] = [], avatarImageURL: String? = nil, type: ProfileType = .none, privacy: Privacy = .public, settings: Settings? = defaultSettings, visions: [Vision] = [], status: ActivityStatus? = nil, performances: [Performance] = defaultPerformances) {
        self.id = id
        self.fullName = fullName
        self.username = username
        self.bio = bio
        self.gender = gender
        self.birthday = birthday
        self.avatars = avatars
        self.avatarImageURL = avatarImageURL
        self.type = type
        self.privacy = privacy
        self.settings = settings
        self.visions = visions
        self.status = status
        self.performances = performances
    }
    
    
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String = UUID().uuidString
    var fullName: String = "Empty Name"
    var username: String = "premauser"
    var bio: String = "no bio"
    var gender: Gender = .none
    var birthday: Double = 0
    var avatars: [Media] = []
    var avatarImageURL: String? = nil
    var type: ProfileType = .none
    var privacy: Privacy = .public
    var settings: Settings? = defaultSettings
    var visions: [Vision] = []
    var status: ActivityStatus? = nil
    var performances: [Performance] = defaultPerformances
    static var defaultSettings = Settings(allowedNotifications: ["general" ,"direct"])
    static var defaultPerformances: [Performance] = [
    
        .init(id: UUID().uuidString, name: "Productivity", progress: [], statements: [], opens: []),
        .init(id: UUID().uuidString, name: "Discipline", progress: [], statements: [], opens: []),
        .init(id: UUID().uuidString, name: "Diligence", progress: [], statements: [], opens: []),
        .init(id: UUID().uuidString, name: "Retros", progress: [], statements: [], opens: [])
    ]
    
}

//extension ActivityStatus {
//    var dictionary: [String: Any] {
//        return ["status": self.status]
//    }
//}

extension Settings {
    var dictionary: [String: Any] {
        return ["allowedNotifications": self.allowedNotifications]
    }
}

extension [String: Any] {
    var parseSettings: Settings {
        var allowedNotifications = self["allowedNotifications"] as? [String] ?? []
        return .init(allowedNotifications: allowedNotifications)
    }
}

//extension [String: Any] {
//    func parseActivity(_ id: String? = nil) -> ActivityStatus {
//        let status = self["status"] as? String ?? "offline"
//        
//        return .init(status: status)
//    }
//}

extension [String: Any] {
    func parseProfile(_ id: String? = nil) -> Profile {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let fullName = self["fullName"] as? String ?? "Empty Name"
        let username = self["username"] as? String ?? "premauser"
        let bio = self["bio"] as? String ?? "no bio"
        let gender = Gender(rawValue: self["gender"] as? String ?? "") ?? .none
        let type = ProfileType(rawValue: self["type"] as? String ?? "") ?? .none
        let privacy = Privacy(rawValue: self["privacy"] as? String ?? "") ?? .public
        let birthday = self["birthday"] as? Double ?? 0

        let avatarImageURL = self["avatarImageURL"] as? String
        let avatarDicts = self["avatars"] as? [[String: Any]] ?? []
        let settingsDict = self["settings"] as? [String: Any] ?? [:]
        let performances = (self["performances"] as? [[String: Any]] ?? Profile.defaultPerformances.map {$0.dictionary} ).map { $0.parsePerformance() }
        let settings = settingsDict.parseSettings
        
        let avatars: [Media] = avatarDicts.map { $0.parseMedia() }
        

        return .init(id: _id, fullName: fullName, username: username, bio: bio, gender: gender, birthday: birthday, avatars: avatars, avatarImageURL: avatarImageURL, type: type, privacy: privacy, settings: settings, performances: performances)
    }
}

extension [Profile] {
    var inbox: Inbox {
        let membs = self + [AccountManager.shared.currentProfile ?? .init()]
        let sortedArray = membs.map {$0.id}.sorted()
        let concatenatedString = sortedArray.joined()
        
        
        print("accepts id: \(concatenatedString)")
        return Inbox(id: concatenatedString, members: membs, requests: self.map { $0.id }, accepts: [], displayName: nil, recentMessage: nil, creationTimestamp: .init(id: UUID().uuidString, profile: AccountManager.shared.currentProfile ?? .init(), time: Date.now.timeIntervalSince1970), unreadDict: [:])
    }
}

extension Profile {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["id"] = self.id
        dict["fullName"] = self.fullName
        dict["username"] = self.username
        dict["bio"] = self.bio
        dict["gender"] = self.gender.rawValue
        dict["birthday"] = self.birthday
        
        dict["avatars"] = self.avatars.map { $0.dictionary }
        if !self.avatars.isEmpty {
            dict["avatarImageURL"] =  self.avatars[0].imageURLString
        }
        if let settings {
            dict["settings"] = settings.dictionary
        }
        dict["type"] = self.type.rawValue
        dict["privacy"] = self.privacy.rawValue
        dict["perfomances"] = self.performances.map { $0.dictionary }
        
        return dict
    }
}
