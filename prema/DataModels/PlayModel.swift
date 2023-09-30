//
//  PlayModel.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/18/23.
//

import Foundation

enum PlayHomeType: String {
    case quickies = "Quickies"
    case tv = "TV"
    case voices = "Voices"
    case feed = "Feed"
    
    static var allCases: [PlayHomeType] = [
        .feed,
        .quickies,
        .tv,
        .voices
    ]
}

enum PlayEventType: String {
    case physical = "Physical"
    case virtual = "Virtual"
    case live = "Live"
    
    static var allCases: [PlayEventType] = [
        .physical,
        .virtual,
        .live
    ]
}

class PlayModel: ObservableObject {
    // PlayNav
    @Published var playHomeType: PlayHomeType = .feed
    @Published var playEventType: PlayEventType = .physical

    @Published var selectedInterest: String = "Best"
    
    var interests: [String] = [
        "Popular",
        "Best",
        "Nearby",
        "Choose"
    ]
    
}
