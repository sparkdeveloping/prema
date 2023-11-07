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

struct Message: Identifiable {
    var id: String
}

struct Timestamp: Identifiable {
    var id: String
    var profile: String
    var time: Double
}
