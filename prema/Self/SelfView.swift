//
//  SelfView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import FirebaseAuth
import SwiftUI

struct SelfView: View {
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @StateObject var navigationManager = NavigationManager.shared

    @StateObject var accountManager = AccountManager.shared
    @StateObject var authManager = AuthManager.shared

    var body: some View {
        TabView(selection: $navigationManager.selectedSelfTab) {
            ProfileView()
                .tag("FullName")
            VisionsView()
                .tag("Heart")
            Color.clear
                .tag("Bell")
            Color.clear
                .tag("Settings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
