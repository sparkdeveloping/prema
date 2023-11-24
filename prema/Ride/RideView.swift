//
//  RideView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/22/23.
//

import SwiftUI

struct RideView: View {
    @StateObject var navigation = NavigationManager.shared
    var body: some View {
        TabView(selection: $navigation.selectedShopperTab) {
            RideHome()
                .tag("RideHome")
            RideTravel()
                .tag("RideTravel")
            RideHistory()
                .tag("RideHistory")
            RideSettings()
                .tag("RideSettings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
