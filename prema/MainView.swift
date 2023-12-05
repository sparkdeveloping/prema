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
    @StateObject var selfManager = SelfManager.shared

    @StateObject var accountManager = AccountManager.shared
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme
    @StateObject var namespace: NamespaceWrapper = .shared
    @Namespace var namespacee

    @StateObject var directManager = DirectManager.shared
    @Environment(\.scenePhase) var scenePhase

    @State var appeared = false
    @State var size: CGSize = .zero
    init() {
        
        NamespaceWrapper.shared.namespace = namespacee
        
        if let profile = accountManager.currentProfile {
            let topic = profile.id + "direct"
            Messaging.messaging().subscribe(toTopic: topic) { error in
              print("Subscribed to topic ")
                print("\n\n\ntopic is: \(topic)\n\n\n")
            }
        }
    }


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
                                ChatView()
                                    .environmentObject(ChatManager(inbox))
                                    .toolbar(.hidden)
                            }
                            .navigationDestination(for: String.self) { string in
                                if string == "checkout" {
                                    ShopperCheckoutView()
                                        .toolbar(.hidden)
                                }
                                if string.contains("|") {
                                    let strings = string.components(separatedBy: "|")
                                    CreateStickerView(inboxID: strings[1])
                                }
                            }
                            .navigationDestination(for: Vision.self) { vision in
                                VisionDetailView(vision: vision)
                                    .toolbar(.hidden)
                            }
                            .onReceive(navigation.$notificationInboxID) {
                                if let id = $0 {
                                    DirectManager.shared.fetchInbox(id) { inbox in
                                        navigation.selectedTab = .direct
                                        navigation.showSidebar = false
                                        navigation.path.append(inbox)
                                    }
                                }
                            }
                            .onChange(of: scenePhase) { _, newPhase in
                                if newPhase == .active {
                                    print("Active")
                                    AccountManager.shared.isOnline(bool: true)
                                    AccountManager.shared.updateInboxStatus(to: directManager.accepts, online: true)
                                    
                                } else if newPhase == .inactive {
                                    print("Inactive")
                                    AccountManager.shared.updateInboxStatus(to: directManager.accepts, online: false)
                                    
                                    AccountManager.shared.isOnline(bool: false)
                                } else if newPhase == .background {
                                    print("Background")
                                    AccountManager.shared.updateInboxStatus(to: directManager.accepts, online: false)
                                    
                                    AccountManager.shared.isOnline(bool: false)
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
                    .overlay {
                        Color.clear.nonVibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
                            .opacity((navigation.showNewVision || navigation.showNewTaskVision != nil) ? 0.9:0)
                            .ignoresSafeArea()
                        NewVisionView()
                            .offset(y: navigation.showNewVision  ? 0:appearance.size.height)
                            .environmentObject(selfManager)
                        if let vision = navigation.showNewTaskVision {
                            NewTaskView(vision: vision)
                                .offset(y: navigation.showNewTaskVision != nil ? 0:appearance.size.height)
                                .environmentObject(selfManager)
                        }
                    }
                }
                
            }
            .nonVibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                blob
            }
            .overlay {
                ZStack {
                    if let media = navigation.media {
                        MediaPlayerView(media: media)
                            .transition(.scale)
                            .matchedGeometryEffect(id: "mediaplayer-\(media[0].id)", in: namespace.namespace!)
                    }
                }
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
                        Image(systemName: "chevron.left")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .padding(20)
                            .topPadding(20)
                            .contentShape(.rect)
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
