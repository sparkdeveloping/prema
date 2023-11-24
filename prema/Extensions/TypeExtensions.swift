//
//  TypeExtensions.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let formattedHex = hex

        var hex: UInt64 = 0

        Scanner(string: formattedHex).scanHexInt64(&hex)

        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
    
    static var vibrant: LinearGradient {
        return AppearanceManager.shared.currentTheme.vibrantGradient
    }
    static func nonVibrant(_ colorScheme: ColorScheme) -> LinearGradient {
        return colorScheme == .light ? AppearanceManager.shared.currentTheme.nonVibrantGradient:AppearanceManager.shared.currentTheme.nonVibrantGradientDark
    }
    static var vibrantSecondary: LinearGradient {
        return AppearanceManager.shared.currentTheme.vibrantSecondaryGradient
    }
    static func nonVibrantSecondary(_ colorScheme: ColorScheme) -> LinearGradient {
        return colorScheme == .light ? AppearanceManager.shared.currentTheme.nonVibrantSecondaryGradient:AppearanceManager.shared.currentTheme.nonVibrantSecondaryGradientDark
    }
}

extension Font {
    static func logoFont(_ size: Double = 34) -> Font {
        return .custom("alba", size: size)
    }
}


extension UIFont {
    static func registerFontWithFilenameString(_ filenameString: String) {
        if let customFontURL = Bundle.main.url(forResource: filenameString, withExtension: "") {
            if let customFontData = try? Data(contentsOf: customFontURL),
               let provider = CGDataProvider(data: customFontData as CFData),
               let customFont = CGFont(provider) {
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(customFont, &error) {
                    print("Error registering font: \(error.debugDescription)")
                }
            }
        }
    }
}
