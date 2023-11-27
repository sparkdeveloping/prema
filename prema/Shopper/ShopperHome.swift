//
//  ShopperHome.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import SwiftUI

extension ShopperView {
    struct ShopperHome: View {
        @EnvironmentObject var shopper: ShopperManager
        @State var category = "recommended"
        @Environment (\.safeAreaInsets) var safeAreaInsets
        @Environment (\.colorScheme) var colorScheme
        let columns = [
               GridItem(.flexible()),
               GridItem(.flexible()),
           ]
        var width = AppearanceManager.shared.size.width

        var body: some View {
            ScrollView {
                
                VStack(spacing: 20) {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(0..<10) { i in
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(hue: Double(i) / 2, saturation: 1, brightness: 1).gradient)
                                    .frame(width: width - 40, height: (width - 40) * 9 / 16)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 20)
                    
                
                        CustomSelectorView(selection: $category, strings: [
                            "recommended",
                            "home",
                            "garden",
                            "technology",
                            "pets",
                            "toys",
                            "chemicals"
                        ])
           
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(shopper.products) { product in
                            
                            ProductCell(product: product)
                                .environmentObject(shopper)
                             
                        }
                    }
                    .padding(.horizontal)
                }
                .topPadding(Double.blobHeight - safeAreaInsets.top)
                .bottomPadding(safeAreaInsets.bottom + 100)
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title2.bold())
                    Divider()
                        .frame(height: 20)
                        .horizontalPadding(4)
                    Image(systemName: "magnifyingglass")
                        .font(.title2.bold())
                }
                .frame(height: 40)
                .foregroundStyle(Color.vibrant)
                .buttonPadding()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                .padding(.trailing)
                .topPadding(safeAreaInsets.top)
                .ignoresSafeArea()
            }
        }
    }
}

struct ProductCell: View {
    
    var product: Product
    var width = AppearanceManager.shared.size.width
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var shopper: ShopperManager

    var body: some View {
        VStack {
            if let avatar = product.avatar, let image = avatar.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width / 3, height: width / 3)
            }
           
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.title3.bold())
                    .roundedFont()
                    .lineLimit(2)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        if product.comparisonPrice != 0 {
                            Text("$" + product.comparisonPrice.priceString)
                                .font(.subheadline)
                                .roundedFont()
                                .strikethrough()
                                .bold()
                        }
                        Text("$" + product.price.priceString)
                            .font(.title3.bold())
                            .roundedFont()
                            .foregroundStyle(product.comparisonPrice != 0 ? .red:Color.primary)
                    }
                    Spacer()
                }
            }
            HStack {
                
                Button {
                    if let index = shopper.cart.firstIndex(where: {$0.id == product.id }) {
                        let i = index
                        withAnimation(.spring()) {
                            shopper.cart.remove(at: i)
                        }
                    } else {
                        withAnimation(.spring()) {
                            shopper.cart.append(product)
                        }
                    }
                } label: {
                    Label(shopper.cart.contains(where: {$0.id == product.id }) ? "Remove":"Add to Cart", systemImage: shopper.cart.contains(where: {$0.id == product.id }) ? "cart.fill.badge.minus":"cart.fill.badge.plus")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if shopper.cart.contains(where: {$0.id == product.id }) {
                                Color.red
                            } else {
                                Color.clear.vibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
                            }
                        }
                        .clipShape(.rect(cornerRadius: 14, style: .continuous))
                }
                Image(systemName: "heart.fill")
                    .fontWeight(.bold)
                    .padding(10)
                    .foregroundStyle(.secondary)
                    .nonVibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

extension Double {
    var priceString: String {
        return String(format: "%.2f", self)
    }
}
