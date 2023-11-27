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

struct ActivityStatus {
    var status: String
}

struct Profile: Identifiable, Codable, Hashable {
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
    var settings: Settings = Self.defaultSettings
    var visions: [Vision] = []
    
    static var defaultSettings = Settings(allowedNotifications: ["general" ,"direct"])
}

extension ActivityStatus {
    var dictionary: [String: Any] {
        return ["status": self.status]
    }
}

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

extension [String: Any] {
    func parseActivity(_ id: String? = nil) -> ActivityStatus {
        let status = self["status"] as? String ?? "offline"
        
        return .init(status: status)
    }
}

extension [String: Any] {
    func parseProfile(_ id: String? = nil) -> Profile {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let fullName = self["fullName"] as? String ?? "Empty Name"
        let username = self["username"] as? String ?? "premauser"
        let bio = self["username"] as? String ?? "no bio"
        let gender = Gender(rawValue: self["gender"] as? String ?? "") ?? .none
        let type = ProfileType(rawValue: self["type"] as? String ?? "") ?? .none
        let privacy = Privacy(rawValue: self["privacy"] as? String ?? "") ?? .public
        let birthday = self["birthday"] as? Double ?? 0

        let avatarImageURL = self["avatarImageURL"] as? String
        let avatarDicts = self["avatars"] as? [[String: Any]] ?? []
        let settingsDict = self["settings"] as? [String: Any] ?? [:]
        let settings = settingsDict.parseSettings
        
        let avatars: [Media] = avatarDicts.map { $0.parseMedia() }
        

        return .init(id: _id, fullName: fullName, username: username, bio: bio, gender: gender, birthday: birthday, avatars: avatars, avatarImageURL: avatarImageURL, type: type, privacy: privacy, settings: settings)
    }
}

extension [Profile] {
    var inbox: Inbox {
        let membs = self + [AccountManager.shared.currentProfile ?? .init()]
        let sortedArray = membs.map {$0.id}.sorted()
        let concatenatedString = sortedArray.joined()
        
        
        print("accepts id: \(concatenatedString)")
        return Inbox(id: concatenatedString, members: membs, requests: self.map { $0.id }, accepts: [], displayName: membs.map { $0.username }.reduce("") { "\($0), " + $1 }, recentMessage: nil, creationTimestamp: .init(id: UUID().uuidString, profile: AccountManager.shared.currentProfile ?? .init(), time: Date.now.timeIntervalSince1970), unreadDict: [:])
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
        dict["settings"] =  self.settings.dictionary

        dict["type"] = self.type.rawValue
        dict["privacy"] = self.privacy.rawValue
        
        return dict
    }
}
