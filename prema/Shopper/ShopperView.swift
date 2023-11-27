//
//  ShopperView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import SwiftUI

struct ShopperView: View {
    @StateObject var navigation = NavigationManager.shared
    @StateObject var shopper = ShopperManager.shared
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets

    var body: some View {
        TabView(selection: $navigation.selectedShopperTab) {
            ShopperHome()
                .tag("ShopperHome")
                .environmentObject(shopper)
            ShopperCart()
                .tag("ShopperCart")
                .environmentObject(shopper)
            ShopperOrders()
                .tag("ShopperOrders")
            ShopperSettings()
                .tag("ShopperSettings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            Button {
                navigation.path.append("checkout")
            } label: {
                Text("Checkout")
                    .fontWeight(.bold)
                    .roundedFont()
                    .buttonPadding()
                    .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
            }
            .padding()
            .bottomPadding(safeAreaInsets.bottom + 40)
            .foregroundStyle(.primary)
        }
    }
}

struct ShopperCheckoutView: View {
    @StateObject var shopper = ShopperManager.shared
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets

    var cart: [Product] {
        return shopper.cart
    }
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
        ZStack {
            ScrollView {
                VStack {
                    VStack {
                        ForEach(cart) { product in
                            VStack {
                                HStack {
                                    Text(product.name)
                                    Spacer()
                                    Text("\(product.cartQuantity) x").foregroundStyle(.secondary) + Text(" \(product.price)").bold()
                                }
                                Divider()
                                    .horizontalPadding()
                            }
                            
                        }
                    }
                    .padding(10)
                    .background(.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading) {
                        Label("Shipping Address", systemImage: "shippingbox.fill")
                        Button {
                            
                        } label: {
                            HStack {
                                Text("1750 N Havard St")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                        }
                        Label("Billing Address", systemImage: "creditcard.fill")
                        Button {
                            
                        } label: {
                            HStack {
                                Text("1750 N Havard St")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                        }
                        Label("Payment Information", systemImage: "creditcard.fill")
                        Button {
                            
                        } label: {
                            HStack {
                                Text("1750 N Havard St")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                        }
                    }
                    .padding(10)
                    .background(.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))
                    
                        VStack(alignment: .leading) {
                            Text("Summary")
                                .bold()
                            VStack(spacing: 10) {
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
                        .padding(10)
                    .background(.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Process Order")
                            .font(.title.bold())
                            .buttonPadding()
                            .frame(maxWidth: .infinity)
                            .vibrantBackground(cornerRadius: 18, colorScheme: colorScheme)
                    }
                    .foregroundStyle(.primary)
                }
                .padding(10)
                .topPadding(Double.blobHeight -  safeAreaInsets.top)
                .bottomPadding(safeAreaInsets.bottom + 20)
            }
            .ignoresSafeArea()
            .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
        }
        .ignoresSafeArea()
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
