//
//  AppearanceManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

class AppearanceManager: ObservableObject {
    
    var currentTheme: Theme {
        return themes[currentThemeIndex]
    }
    @Published var currentThemeIndex: Int = 0
    
    var themes: [Theme] = []
    
    static var shared = AppearanceManager()
    
    @Published var shrinkBlob = false
    @Published var isLoading = false
    var size: CGSize = .zero
    var safeArea: EdgeInsets = .init()
    
 
    init() {
        themes = AppearanceManager.loadThemes()
    }
    
    func startLoading() {
        withAnimation(.spring()) {
            self.isLoading = true
        }
    }
    func stopLoading() {
        withAnimation(.spring()) {
            self.isLoading = false
        }
    }
    
    static func saveThemesLocally(themes: [Theme]) {
        do {
            let encoder = JSONEncoder()
            let themesData = try encoder.encode(themes)
            
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let themesURL = documentsDirectory.appendingPathComponent("themes.json")
                try themesData.write(to: themesURL)
            }
        } catch {
            print("Error saving themes: \(error.localizedDescription)")
        }
    }
    
    static func loadThemes() -> [Theme] {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let themesURL = documentsDirectory.appendingPathComponent("themes.json")
            
            do {
                let themesData = try Data(contentsOf: themesURL)
                let decoder = JSONDecoder()
                let themes = try decoder.decode([Theme].self, from: themesData)
                return themes
            } catch {
                print("Error loading themes: \(error.localizedDescription)")
            }
        }
        return [Theme.defaultTheme]
    }
    
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
