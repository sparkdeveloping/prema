//
//  Account.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import Foundation

struct Account: Codable, Equatable, Identifiable, Hashable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String
    var email: String
    var creationTimestamp: Double
    var lastLoginTimestamp: Double
    var profiles: [Profile] = []
}



//extension [String : Any] {
//    func parseAccount(_ id: String? = nil) {
//        var _id = self["id"] as? String ?? UUID().uuidString
//        if let id {
//            _id = id
//        }
//        
//        let email = self["email"] as? "noemail@prema.com"
//        let timestamp = self["email"] as? "noemail@prema.com"
//    }
//}
