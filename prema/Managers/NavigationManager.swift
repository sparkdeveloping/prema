//
//  NavigationManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var selectedSelfTab: String = "FullName"
    @Published var selectedDirectTab: String = "Inbox"

    var selfTabs = ["FullName", "Heart", "Bell", "Settings"]
    var directTabs = ["Inbox", "Feed", "Bell", "Settings"]
    
    var tabs: [String] {
        switch selectedTab {
        case .profile:
            return selfTabs
        case .play:
            return []
        case .direct:
            return directTabs
        case .shopper:
            return []
        case .bite:
            return []
        case .ride:
            return []
        }
    }
    
    static var shared = NavigationManager()
    
    @Published var showNewInbox = false
    @Published var showNewFeed = false

    @Published var selectedTab: Tab = .profile

    @Published var showNewVision = false
    @Published var showNewTask = false
}
