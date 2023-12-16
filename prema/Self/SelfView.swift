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
    @EnvironmentObject var navigation: NavigationManager

    @StateObject var accountManager = AccountManager.shared
    @StateObject var authManager = AuthManager.shared

    var body: some View {
        TabView(selection: $navigation.selectedSelfTab) {
            ProfileView()
                .tag("FullName")
            VisionsView()
                .tag("Heart")
            Color.clear
                .tag("Trophy")
            Color.clear
                .tag("Settings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
