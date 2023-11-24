//
//  ShopperHome.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import SwiftUI

extension ShopperView {
    struct ShopperCart: View {
        @StateObject var shopper = ShopperManager()
        @State var category = "recommended"
        @Environment (\.safeAreaInsets) var safeAreaInsets
        @Environment (\.colorScheme) var colorScheme
    
        var width = AppearanceManager.shared.size.width
        
        var body: some View {
            ScrollView {
                VStack {
                    ForEach(shopper.cart) { product in
                        CartCell(product: product)
                            .environmentObject(shopper)
                    }
                }
                .topPadding(Double.blobHeight - safeAreaInsets.top)
                .bottomPadding(safeAreaInsets.bottom + 100)
            }
            .ignoresSafeArea()
        }
    }
    
    struct CartCell: View {
        @ObservedObject var product: Product
        @EnvironmentObject var shopper: ShopperManager
        var width = AppearanceManager.shared.size.width
        @Environment (\.colorScheme) var colorScheme
        var body: some View {
            HStack {
                if let avatar = product.avatar, let image = avatar.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width / 4, height: width / 4)
                }
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.title3.bold())
                        .roundedFont()
                        .lineLimit(2)
                }
                Spacer()
                VStack {
                    Text("\(product.cartQuantity)")
                        .font(.title3.bold())
                        .roundedFont()
                        .lineLimit(2)
                    HStack {
                        Button {
                            if product.cartQuantity == 0 {
                                if let index = shopper.cart.firstIndex(where: {$0.id == product.id }) {
                                    withAnimation(.spring()) {
                                        shopper.cart.remove(at: index)
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        product.cartQuantity -= 1
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.title3.bold())
                                .frame(width: width / 10, height: width / 10)
                                .nonVibrantBackground(cornerRadius: (0.3 * width / CGFloat(10)), colorScheme: colorScheme)
                        }
                        Button {
                            withAnimation(.spring()) {
                                product.cartQuantity += 1
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3.bold())
                                .frame(width: width / 10, height: width / 10)
                                .nonVibrantBackground(cornerRadius: (0.3 * width / CGFloat(10)), colorScheme: colorScheme)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .nonVibrantSecondaryBackground(cornerRadius: 14, colorScheme: colorScheme)
        }
    }
}
