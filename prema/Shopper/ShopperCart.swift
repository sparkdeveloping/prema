//
//  ShopperHome.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import SwiftUI

extension ShopperView {
    struct ShopperCart: View {
        @EnvironmentObject var shopper: ShopperManager
        @State var category = "recommended"
        @Environment (\.safeAreaInsets) var safeAreaInsets
        @Environment (\.colorScheme) var colorScheme
    
        var width = AppearanceManager.shared.size.width
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(shopper.cart) { product in
                        CartCell(product: product)
                            .environmentObject(shopper)
                    }
                }
                .topPadding(Double.blobHeight - safeAreaInsets.top)
                .bottomPadding(safeAreaInsets.bottom + 100)
                .horizontalPadding()
            }
            .ignoresSafeArea()
          
        }
    }
    
    struct CheckoutView: View {
        var cart: [Product]
        
        var subtotal: Double {
            cart.map { $0.price * Double($0.cartQuantity)}.reduce(0) { $0 + $1 }
        }
        
        var deliveryFee: Double {
            (cart.map { $0.price * Double($0.cartQuantity)}.reduce(0) { $0 + $1 } * 0.1)
        }
        
        var tax: Double {
            (cart.map { $0.price * Double($0.cartQuantity)}.reduce(0) { $0 + $1 } * 0.01)
        }
        
        var grandTotal: Double {
            subtotal + deliveryFee + tax
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Checkout")
                    .bold()
                VStack {
                    HStack {
                        Text("Subtotal")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(subtotal.priceString)
                            .font(.subheadline.bold())
                            
                    }
                    HStack {
                        Text("Delivery Fee")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(deliveryFee.priceString)
                            .font(.subheadline.bold())
                            
                    }
                    HStack {
                        Text("Tax")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(tax.priceString)
                            .font(.subheadline.bold())
                            
                    }
                    HStack {
                        Text("Grand Total")
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(grandTotal.priceString)
                            .font(.title3.bold())
                            
                    }
                }
                
            }
            .padding()
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
                        .frame(width: width / 7, height: width / 7)
                }
                VStack(alignment: .leading) {
                    Text(product.name)
                        .fontWeight(.bold)
                        .roundedFont()
                        .lineLimit(2)
                }
                Spacer()
                VStack {
                    Text("\(product.cartQuantity)")
                        .fontWeight(.bold)
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
                                .fontWeight(.bold)
                                .frame(width: width / 10, height: width / 10)
                                .nonVibrantBackground(cornerRadius: (0.3 * width / CGFloat(10)), colorScheme: colorScheme)
                                .foregroundStyle(.primary)
                        }
                        Button {
                            withAnimation(.spring()) {
                                product.cartQuantity += 1
                            }
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                                .frame(width: width / 10, height: width / 10)
                                .nonVibrantBackground(cornerRadius: (0.3 * width / CGFloat(10)), colorScheme: colorScheme)
                                .foregroundStyle(.primary)
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
