//
//  AppearanceManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

extension Double {
    static var blobHeight = AppearanceManager.shared.size.width * 0.6 * 247 / 277
}

class AppearanceManager: ObservableObject {
    static var shared = AppearanceManager()
    var currentTheme: Theme {
        return themes[currentThemeIndex]
    }
    @Published var hideTopBar = false
    @Published var currentThemeIndex: Int = 0
    
    var themes: [Theme] = [Theme.defaultTheme, .asterid, .beast, .coconatt, .knowel, .saculent, .swift]
        
    @Published var shrinkBlob = false
    @Published var isLoading = false
    var size: CGSize = .zero
    var safeArea: EdgeInsets = .init()
   

    init() {
        themes.append(contentsOf: self.loadThemes())
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
    
    func saveThemesLocally(themes: [Theme]) {
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
    
    func loadThemes() -> [Theme] {
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
        return []
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
public class KeyboardInfo: ObservableObject {

    public static var shared = KeyboardInfo()

    @Published public var height: CGFloat = 0

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardChanged(notification: Notification) {
        if notification.name == UIApplication.keyboardWillHideNotification {
            self.height = 0
        } else {
            self.height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
        }
    }

}

struct KeyboardAware: ViewModifier {
    @ObservedObject private var keyboard = KeyboardInfo.shared
    @Environment (\.safeAreaInsets) var safeAreaInsets
    func body(content: Content) -> some View {
        content
            .padding(.bottom, self.keyboard.height)
            .ignoresSafeArea()
            .edgesIgnoringSafeArea(self.keyboard.height > 0 ? .bottom : [])
            .animation(.easeInOut, value: self.keyboard.height)
    }
}

extension View {
    public func keyboardAware() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAware())
    }
}
