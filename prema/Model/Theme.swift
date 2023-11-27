//
//  Theme.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

struct Theme: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var vibrantHexes: [String]
    var nonVibrantHexes: [String]
    var nonVibrantHexesDark: [String]
    var vibrantSecondaryHexes: [String]
    var nonVibrantSecondaryHexes: [String]
    var nonVibrantSecondaryHexesDark: [String]

    var vibrantColors: [Color] {
        return vibrantHexes.map { Color(hex: $0) }
    }

    var nonVibrantColors: [Color] {
        return nonVibrantHexes.map { Color(hex: $0) }
    }
    
    var nonVibrantColorsDark: [Color] {
        return nonVibrantHexesDark.map { Color(hex: $0) }
    }

    var vibrantSecondaryColors: [Color] {
        return vibrantSecondaryHexes.map { Color(hex: $0) }
    }

    var nonVibrantSecondaryColors: [Color] {
        return nonVibrantSecondaryHexes.map { Color(hex: $0) }
    }
    
    var nonVibrantSecondaryColorsDark: [Color] {
        return nonVibrantSecondaryHexesDark.map { Color(hex: $0) }
    }

    var vibrantGradient: LinearGradient {
        return LinearGradient(colors: vibrantColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var vibrantSecondaryGradient: LinearGradient {
        return LinearGradient(colors: vibrantSecondaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var nonVibrantGradient: LinearGradient {
        return LinearGradient(colors: nonVibrantColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var nonVibrantGradientDark: LinearGradient {
        return LinearGradient(colors: nonVibrantColorsDark, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var nonVibrantSecondaryGradient: LinearGradient {
        return LinearGradient(colors: nonVibrantSecondaryColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var nonVibrantSecondaryGradientDark: LinearGradient {
        return LinearGradient(colors: nonVibrantSecondaryColorsDark, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    
    static var defaultTheme: Theme = .init(name: "Default", vibrantHexes: ["7C00DD", "FF004D"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["FF004D"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    
    static var asterid: Theme = .init(name: "Asterid", vibrantHexes: ["5200FF", "9E00FF"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["9E00FF"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    static var coconatt: Theme = .init(name: "Coconatt", vibrantHexes: ["A14400", "E3AD46"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["E3AD46"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    static var swift: Theme = .init(name: "Swift", vibrantHexes: ["FF4D00", "FFB800"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["FFB800"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    static var saculent: Theme = .init(name: "Saculent", vibrantHexes: ["00D13B", "00FF85"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["00FF85"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    static var beast: Theme = .init(name: "Beast", vibrantHexes: ["D10000", "FF3D00"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["FF3D00"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
    static var knowel: Theme = .init(name: "Knowel", vibrantHexes: ["0047FF", "00B2FF"], nonVibrantHexes: ["FFFFFF"], nonVibrantHexesDark: ["000000"], vibrantSecondaryHexes: ["0047FF"], nonVibrantSecondaryHexes: ["F0F0F0"], nonVibrantSecondaryHexesDark: ["1A1A1A"])
}

extension [String: Any] {
    func parseTheme(id: String = UUID().uuidString) -> Theme {
        let id = self["id"] as? String ?? id
        let name = self["name"] as? String ?? Theme.defaultTheme.name
        let vibrantHexes = self["vibrantHexes"] as? [String] ?? Theme.defaultTheme.vibrantHexes
        let nonVibrantHexes = self["nonVibrantHexes"] as? [String] ?? Theme.defaultTheme.nonVibrantHexes
        let vibrantSecondaryHexes = self["vibrantSecondaryHexes"] as? [String] ?? Theme.defaultTheme.vibrantSecondaryHexes

        let nonVibrantSecondaryHexes = self["nonVibrantSecondaryHexes"] as? [String] ?? Theme.defaultTheme.nonVibrantSecondaryHexes
        let nonVibrantHexesDark = self["nonVibrantHexesDark"] as? [String] ?? Theme.defaultTheme.nonVibrantHexesDark
        let nonVibrantSecondaryHexesDark = self["nonVibrantSecondaryHexesDark"] as? [String] ?? Theme.defaultTheme.nonVibrantSecondaryHexesDark

        return .init(name: name, vibrantHexes: vibrantHexes, nonVibrantHexes: nonVibrantHexes, nonVibrantHexesDark: nonVibrantHexesDark, vibrantSecondaryHexes: vibrantSecondaryHexes, nonVibrantSecondaryHexes: nonVibrantSecondaryHexes, nonVibrantSecondaryHexesDark: nonVibrantSecondaryHexesDark)
    }
}

