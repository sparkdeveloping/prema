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

struct Profile: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var fullName: String = "Empty Name"
    var username: String = "premauser"
    var bio: String = "no bio"
    var gender: Gender = .none
    var birthday: Double = 0
    var avatars: [Media] = []
    var type: ProfileType = .none
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
        let birthday = self["birthday"] as? Double ?? 0
        let avatarDicts = self["media"] as? [[String: Any]]
        var avatars: [Media] = []
        if let avatarDicts {
            avatars = avatarDicts.map { $0.parseMedia() }
        }
        return .init(id: _id, fullName: fullName, username: username, avatars: avatars, type: type)
    }
}
