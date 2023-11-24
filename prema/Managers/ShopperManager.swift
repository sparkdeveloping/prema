//
//  ShopperManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import Foundation
import UIKit

class ShopperManager: ObservableObject {
    
    @Published var products: [Product] = ShopperManager.dummyProducts
    @Published var cart: [Product] = []

    static var dummyProducts: [Product] = [
    
        .init(name: "Summer Glasses", description: "This is a description for sun glasses to see how they will look ", avatars: [.init(uiImage: UIImage(named: "sunglasses"))], price: 29.99, comparisonPrice: 40.57, availableStock: 100),
        .init(name: "Apple Airpods Max", description: "This is a description for headphones to see how they will look ", avatars: [.init(uiImage: UIImage(named: "headphones"))], price: 399.99, comparisonPrice: 499, availableStock: 100),
        .init(name: "Blue Hoodie", description: "This is a description for hoodies to see how they will look ", avatars: [.init(uiImage: UIImage(named: "hoodie"))], price: 29.99, comparisonPrice: 40.57, availableStock: 100),
        .init(name: "Gifty Handbag", description: "This is a description for sun glasses to see how they will look ", avatars: [.init(uiImage: UIImage(named: "handbag"))], price: 29.99, comparisonPrice: 40.57, availableStock: 100),
        .init(name: "Special Nike Show", description: "This is a description for sun glasses to see how they will look ", avatars: [.init(uiImage: UIImage(named: "shoe"))], price: 29.99, comparisonPrice: 40.57, availableStock: 100),
    
    ]
    
}
