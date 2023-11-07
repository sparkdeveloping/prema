//
//  MainView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var appearance = AppearanceManager.shared
    @StateObject var accountManager = AccountManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State var appeared = false
    @State var size: CGSize = .zero
    init() {
        // Register your custom font
        UIFont.registerFontWithFilenameString("alba.ttf")
    }
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack {
                SplashView()
                    .opacity(appearance.shrinkBlob ? 0.1:1)
                if accountManager.currentProfile == nil {
                    AuthView()
                } else {
                    MainNavigationView()
                }
                
            }
            .nonVibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                blob
                  
            }
            .onAppear {
                self.size = size

                appearance.size = size
   
                withAnimation(.spring()) {
                    appeared = true
                }
            }
        }
        .ignoresSafeArea()
        
    }
    
    var blob: some View {
        Blob()
            .foregroundStyle(Color.vibrant)
            .frame(width: self.size.width * 0.6, height: self.size.width * 0.6 * 247 / 277)
            .overlay(alignment: .leading) {
                Text("prema")
                    .font(.logoFont(self.size.width / 10))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
            }
            .offset(x: appeared ? 0:-self.size.width * 0.6, y: appeared ? 0:-self.size.width * 0.6 * 247 / 277)
            .scaleEffect(appearance.shrinkBlob || !accountManager.accounts.isEmpty ? 0.7:1, anchor: .topLeading)
        
    }
}

extension Double {
    static var blobHeight = (AppearanceManager.shared.size.width * 0.6 * 247 / 277)
}
