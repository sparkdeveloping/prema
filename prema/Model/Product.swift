//
//  Product.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/21/23.
//

import Foundation

class Product: Identifiable, ObservableObject {
    init(id: String = UUID().uuidString, name: String, description: String, avatars: [Media] = [], price: Double, comparisonPrice: Double, availableStock: Int, favorites: [String] = [], ratings: [Rating] = [], cartQuantity: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.avatars = avatars
        self.price = price
        self.comparisonPrice = comparisonPrice
        self.availableStock = availableStock
        self.favorites = favorites
        self.ratings = ratings
        self.cartQuantity = cartQuantity
    }
    
   
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var avatars: [Media] = []
    var avatar: Media? {
        return avatars.first
    }
    var price: Double
    var comparisonPrice: Double
    var availableStock: Int
    @Published var favorites: [String] = []
    var isFavorite: Bool {
        if let id = AccountManager.shared.currentProfile?.id {
            return favorites.contains(id)
        }
        return false
    }
    var ratings: [Rating] = []
    @Published var cartQuantity: Int = 0
}

struct Rating: Identifiable {
    var id: String = UUID().uuidString
    var message: String
    var starCount: Int
    var timestamp: Timestamp
}
