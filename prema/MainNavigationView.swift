//
//  NavigationView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import SwiftUI

enum Tab: String {
    case profile = "Profile", play = "Play", direct = "Direct", shopper = "Shopper", bite = "Bite", ride = "Ride", camera = "Camera"
    static var allCases: [Self] = [.play, .direct, .shopper, .bite, .ride]
}



struct MainNavigationView: View {
    @Environment (\.colorScheme) var colorScheme
    @StateObject var accountManager = AccountManager.shared
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var directManager = DirectManager.shared
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack(alignment: .leading) {
                HStack {
                    Sidebar(selectedTab: $navigation.selectedTab)
                        .offset(x: navigation.showSidebar ? 0:-size.width / 2)
                    Color.clear
                }
            
                    TabView(selection: $navigation.selectedTab) {
                        
                        SelfView()
                            .tag(Tab.profile)
                        Color.clear
                            .tag(Tab.play)
                        DirectView()
                            .tag(Tab.direct)
                        ShopperView()
                            .environmentObject(navigation)
                            .tag(Tab.shopper)
                        Color.clear
                            .tag(Tab.bite)
                        RideView()
                            .tag(Tab.ride)
                        CameraView()
                            .tag(Tab.camera)
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                  
                    .overlay(alignment: .topLeading) {
                        if navigation.selectedTab != .camera {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .saturation(0)
                                .padding(40)
                        }
                    }
                    .nonVibrantBackground(cornerRadius: navigation.showSidebar ? 40:0, colorScheme: colorScheme)
                    .scaleEffect((navigation.showSidebar ? 0.7:1), anchor: .leading)
                    .offset(x: size.width * (navigation.showSidebar ? 0.6:0))
          
            }
            .frame(maxWidth: .infinity)
            .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
                
            }
        }
}

struct TabButton: View {
    enum TabButtonType {
        case create, normal
    }
    var type: TabButtonType {
        switch navigationManager.selectedTab {
        case .profile:
            if navigationManager.selectedSelfTab == "Heart" && imageName == "Heart" {
                return .create
            }
       
        case .direct:
            if navigationManager.selectedDirectTab == "DirectInbox" && imageName == "DirectInbox" {
                return .create
            }
            if navigationManager.selectedDirectTab == "DirectInbox" && imageName == "DirectInbox" {
                return .create
                
            }
        default:
            return .normal
        }
        return .normal
  
    }
    var imageName: String

    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager

    @StateObject var navigationManager = NavigationManager.shared

    var foreground: Color {
        switch navigationManager.selectedTab {
        case .profile:
            if navigationManager.selectedSelfTab == imageName  {
                return appearance.currentTheme.vibrantColors[0]
            }
        case .direct:
               if (navigationManager.selectedDirectTab) == imageName {
                   return appearance.currentTheme.vibrantColors[0]
               }
        case .shopper:
            if (navigationManager.selectedShopperTab) == imageName {
                return appearance.currentTheme.vibrantColors[0]
            }
        case .ride:
            if (navigationManager.selectedRideTab) == imageName {
                return appearance.currentTheme.vibrantColors[0]
            }
        default:
            return .secondary
        }
     
        return .secondary
    }
    
    func action() {
        switch navigationManager.selectedTab {
        case .profile:
            if navigationManager.selectedSelfTab == "Heart" && imageName == "Heart" {
                withAnimation(.spring()) {
                    navigationManager.showNewVision = true
                }
                return
            }
            
             withAnimation(.spring()) {
                 navigationManager.selectedSelfTab = imageName
             }
        case .direct:
            
             if navigationManager.selectedDirectTab == "DirectInbox" && imageName == "DirectInbox" {
                 withAnimation(.spring()) {
                     navigationManager.showNewInbox = true
                     print("yess its being hit")
                 }
                 return
             }
            
             withAnimation(.spring()) {
                 navigationManager.selectedDirectTab = imageName
             }
             if navigationManager.selectedDirectTab == "DirectFeed" && imageName == "DirectFeed" {
                 withAnimation(.spring()) {
                     navigationManager.showNewFeed = true
                 }
                 return
             }
            
             withAnimation(.spring()) {
                 navigationManager.selectedDirectTab = imageName
             }
        case .shopper:
            withAnimation(.spring()) {
                navigationManager.selectedShopperTab = imageName
            }
        case .ride:
            withAnimation(.spring()) {
                navigationManager.selectedRideTab = imageName
            }
        default:
            
             withAnimation(.spring()) {
                 navigationManager.selectedSelfTab = imageName
             }
        }
       
        
    }
    @Namespace var namespace
    var body: some View {
        Button {
           action()
        } label: {
            ZStack {
                if type == .create {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .padding(7)
                        .foregroundStyle(.white)
                        .background {
                            Color.clear
                            .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                            .matchedGeometryEffect(id: "namespace", in: namespace)
                        }
                    
                    
                } else {
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(foreground)
                   
                    
                }
            }
            .frame(maxWidth: .infinity)
            
        }
    }
}

struct Sidebar: View {
    @Binding var selectedTab: Tab
    @Environment (\.colorScheme) var colorScheme
    @Namespace var namespace
    @StateObject var accountManager = AccountManager.shared
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var navigation: NavigationManager

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image("FullName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .nonVibrantSecondaryBackground(cornerRadius: 12, colorScheme: colorScheme)
                Text("Self")
                    .bold()
                    .roundedFont()
                Spacer()
            }
            .foregroundStyle(selectedTab == .profile ? .white:.primary)
            .padding(7)
            .background {
                if selectedTab == .profile {
                    Color.clear
                        .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                        .matchedGeometryEffect(id: "namespace", in: namespace)
                } else {
                    Color.clear.nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                }
            }
            .bottomPadding()
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedTab = .profile
                    navigation.showSidebar = false
                }
            }
            
            VStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    HStack {
                        Image(tab.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(7)
                        Text(tab.rawValue)
                            .bold()
                            .roundedFont()
                        Spacer()
                    }.foregroundStyle(selectedTab == tab ? .white:Color.primary)
                    .padding(7)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedTab = tab
                            navigation.showSidebar = false
                        }
                    }
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(appearance.currentTheme .vibrantGradient)
                                .shadow(color: Color("Shadoww"), radius: 20, x: 4, y: 10)
                                .matchedGeometryEffect(id: "namespace", in: namespace)
                        }
                    }
                }
            }
            .buttonPadding()
            .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
            HStack {
                Image("Camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .nonVibrantSecondaryBackground(cornerRadius: 12, colorScheme: colorScheme)
                Text("Camera")
                    .bold()
                    .roundedFont()
                Spacer()
            }
            .foregroundStyle(selectedTab == .camera ? .white:.primary)
            .padding(7)
            .background {
                if selectedTab == .camera {
                    Color.clear
                        .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                        .matchedGeometryEffect(id: "namespace", in: namespace)
                } else {
                    Color.clear.nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                }
            }
            .bottomPadding()
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedTab = .camera
                    navigation.showSidebar = false
                }
            }
            
            Spacer()
            HStack {
                Image("Accounts")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
           
                Text("Accounts")
                    .bold()
                    .roundedFont()
                Spacer()
                    
            }
            .padding()
            .frame(maxWidth: .infinity)
            .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
            .onTapGesture {
                withAnimation(.spring()) {
                    accountManager.currentProfile = nil
                }
            }
            Spacer()
        }
        .padding()
     
    }
}

extension String? {
    var optionalHandler: String {
        return self ?? ""
    }
}
