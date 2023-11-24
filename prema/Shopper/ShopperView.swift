//
//  ShopperView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import SwiftUI

struct ShopperView: View {
    @StateObject var navigation = NavigationManager.shared
    var body: some View {
        TabView(selection: $navigation.selectedShopperTab) {
            ShopperHome()
                .tag("ShopperHome")
            ShopperCart()
                .tag("ShopperCart")
            ShopperOrders()
                .tag("ShopperOrders")
            ShopperSettings()
                .tag("ShopperSettings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

