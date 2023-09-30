//
//  NavigationManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/18/23.
//

import SwiftUI

enum Module: String {
    case profile = "Profile"
    case activity = "Activity"
    case play = "Play"
    case direct = "Direct"
    case shopper = "Shopper"
    case ride = "Ride"
    case support = "Support"
    case bite = "Bite"
    case logout = "Logout"
}

enum PlayTab: String {
    case home = "Home"
    case events = "Events"
    case explore = "Explore"
    
    static var allCases: [PlayTab] = [
        .home,
        .events,
        .explore
    ]
}

class NavigationManager: ObservableObject {
    
    @Published var hideModulesButton: Bool = false
    // Modules
    @Published var selectedModule: Module = .play
    @Published var showModules: Bool = false
    //Play Modude
    @Published var playTab: PlayTab = .home
    
    
    
    var size: CGSize = .zero
    var safeArea: EdgeInsets = .init()
    
    
    
}
