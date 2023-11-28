//
//  MainView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/2/23.
//

import FirebaseMessaging
import SwiftUI

struct MainView: View {
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var navigation: NavigationManager

    @StateObject var accountManager = AccountManager.shared
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme

    @StateObject var directManager = DirectManager.shared

    @State var appeared = false
    @State var size: CGSize = .zero
    init() {
        
        UIFont.registerFontWithFilenameString("alba.ttf")
        NamespaceWrapper.shared.namespace = namespace
        if let profile = accountManager.currentProfile {
            let topic = profile.id + "direct"
            Messaging.messaging().subscribe(toTopic: topic) { error in
              print("Subscribed to topic ")
                print("\n\n\ntopic is: \(topic)\n\n\n")
            }
        }
    }
    @Namespace var namespace


    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack {
                SplashView()
                    .opacity(appearance.shrinkBlob ? 0.1:1)
                    .environmentObject(appearance)
                if accountManager.currentProfile == nil {
                    AuthView()
                        .ignoresSafeArea()
                        .environmentObject(appearance)
                } else {
                    NavigationStack(path: $navigation.path) {
                        MainNavigationView()
                            .toolbar(.hidden)
                            .navigationBarBackButtonHidden()
                            .ignoresSafeArea()
                            .environmentObject(appearance)
                            .navigationDestination(for: Inbox.self) { inbox in
                                ChatView(inbox: inbox)
                                    .toolbar(.hidden)
                            }
                            .navigationDestination(for: String.self) { string in
                                if string == "checkout" {
                                    ShopperCheckoutView()
                                        .toolbar(.hidden)
                                }
                            }
                    }
                    .ignoresSafeArea()
                    .background(
                        Color.nonVibrantSecondary(colorScheme))
                    .overlay(alignment: .bottom) {
                            HStack {
                                Image(navigation.showSidebar ? "Cancel":"Menu")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(.radians(navigation.showSidebar ? .pi:0))
                                    .foregroundStyle(navigation.showSidebar ? .red:.secondary)
                                    .padding()
                                    .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            navigation.showSidebar.toggle()
                                        }
                                    }
                                HStack {
                                    ForEach(navigation.tabs, id: \.self) { tab in
                                        TabButton(imageName: tab)
                                    }
                                }
                                .frame(height: 60)
                                .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                                if navigation.selectedTab == .camera {
                                    Spacer()
                                }
                                
                            }
                            .offset(y: navigation.path.isEmpty ? 0: 100)
                            .bottomPadding(safeAreaInsets.bottom)
                            .horizontalPadding()
                    }
                }
                
            }
            .nonVibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                blob
            }
            .simultaneousGesture(TapGesture().onEnded { _ in hideKeyboard()})
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
                ZStack {
                    if navigation.path.isEmpty {
                        VStack(alignment: .leading) {
                            Text("prema")
                                .font(.logoFont(self.size.width / 10))
                                .foregroundStyle(.white)
                            Text(appearance.currentTheme.name)
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    } else {
                        Image(systemName: "xmark")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .padding(20)
                            .topPadding(20)
                            .onTapGesture {
                                navigation.path.removeLast()
                            }
                    }
                }
                .padding(.horizontal, 40)
            }
            .offset(x: appeared ? 0:-self.size.width * 0.6, y: appeared ? 0:-self.size.width * 0.6 * 247 / 277)
            .scaleEffect(appearance.shrinkBlob || !accountManager.accounts.isEmpty ? 0.7:1, anchor: .topLeading)
            .offset(y: navigation.selectedTab == .camera ? -self.size.width * 0.6 * 247 / 277:0)
            .onTapGesture {
                if navigation.path.isEmpty {
                    withAnimation(.spring()) {
                        appearance.currentThemeIndex = appearance.currentThemeIndex == appearance.themes.count - 1 ? 0:appearance.currentThemeIndex + 1
                    }
                }
            }
    }
}


class NamespaceWrapper: ObservableObject {
    internal init(namespace: Namespace.ID? = nil) {
        self.namespace = namespace
    }
    
    var namespace: Namespace.ID? = nil
    static var shared = NamespaceWrapper()
    
}
