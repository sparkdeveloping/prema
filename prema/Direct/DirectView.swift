//
//  DirectView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/6/23.
//

import FirebaseAuth
import SwiftUI

struct DirectView: View {
    
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @StateObject var directManager: DirectManager = .shared
    @StateObject var accountManager: AccountManager = .shared
    @StateObject var authManager: AuthManager = .shared
    @EnvironmentObject var navigation: NavigationManager
    
    @Namespace var namespace
    
    var body: some View {
        TabView(selection: $navigation.selectedDirectTab) {
            DirectInbox()
                .tag("DirectInbox")
            DirectFeed()
                .tag("DirectFeed")
            DirectAlerts()
                .tag("DirectAlerts")
            DirectSettings()
                .tag("DirectSettings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
extension DirectView {
    struct DirectFeed: View {
        var body: some View {
            Text("Feed")
        }
    }
    struct DirectAlerts: View {
        var body: some View {
            Text("Alerts")
        }
    }
    
    struct DirectSettings: View {
        var body: some View {
            Text("Settings")
        }
    }
}
