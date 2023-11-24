//
//  NavigationManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import SwiftUI
import Foundation

class NavigationManager: ObservableObject {
    @Published var selectedSelfTab: String = "FullName"
    @Published var selectedDirectTab: String = "DirectInbox"
    @Published var selectedBiteTab: String = "Home"
    @Published var selectedShopperTab: String = "ShopperHome"
    @Published var selectedPlayTab: String = "Home"
    @Published var selectedRideTab: String = "Home"
    @Published var path = NavigationPath()
    @Published var showSidebar = true

    var selfTabs = ["FullName", "Heart", "Bell", "Settings"]
    var directTabs = ["DirectInbox", "DirectFeed", "DirectAlerts", "DirectSettings"]
    var shopperTabs = ["ShopperHome", "ShopperCart", "ShopperOrders", "ShopperSettings"]
    var biteTabs = ["ShopperHome", "ShopperCart", "ShopperOrders", "ShopperSettings"]
    var rideTabs = ["RideHome", "RideTravel", "RideHistory", "RideSettings"]

    var tabs: [String] {
        switch selectedTab {
        case .profile:
            return selfTabs
        case .play:
            return []
        case .direct:
            return directTabs
        case .shopper:
            return shopperTabs
        case .bite:
            return []
        case .ride:
            return rideTabs
        case .camera:
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
