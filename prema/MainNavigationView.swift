//
//  NavigationView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import SwiftUI

enum Tab: String {
    case profile = "Profile", play = "Play", direct = "Direct", shopper = "Shopper", bite = "Bite", ride = "Ride"
    static var allCases: [Self] = [.play, .direct, .shopper, .bite, .ride]
}



struct MainNavigationView: View {
    @Environment (\.colorScheme) var colorScheme
    @StateObject var accountManager = AccountManager.shared
    @StateObject var navigationManager = NavigationManager.shared

    @State var showSidebar = true
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack(alignment: .leading) {
                HStack {
                    Sidebar(selectedTab: $navigationManager.selectedTab)
                        .offset(x: showSidebar ? 0:-size.width / 2)
                    Color.clear
                }
                TabView(selection: $navigationManager.selectedTab) {
                    
                    SelfView()
                        .tag(Tab.profile)
                    Color.clear
                        .tag(Tab.play)
                    DirectView()
                        .tag(Tab.direct)
                    Color.clear
                        .tag(Tab.shopper)
                    Color.clear
                        .tag(Tab.bite)
                    Color.clear
                        .tag(Tab.ride)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .nonVibrantBackground(cornerRadius: showSidebar ? 40:0, colorScheme: colorScheme)
                .scaleEffect((showSidebar ? 0.7:1), anchor: .leading)
                .offset(x: size.width * (showSidebar ? 0.6:0))
               
                VStack {
                    
                    Spacer()
                    HStack {
                        Image(showSidebar ? "Cancel":"Menu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .rotationEffect(.radians(showSidebar ? .pi:0))
                            .foregroundStyle(showSidebar ? .red:.secondary)
                            .padding()
                            .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showSidebar.toggle()
                                }
                            }
                        HStack {
                            ForEach(navigationManager.tabs, id: \.self) { tab in
                                
                                TabButton(imageName: tab)
                            }
                        }
                        .frame(height: 60)
                        .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                      
                    }
                    .padding()
                    .bottomPadding(safeAreaInsets.bottom)
                }
            }
            .ignoresSafeArea()
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
            if navigationManager.selectedDirectTab == "Feed" && imageName == "Feed" {
                return .create
            }
            if navigationManager.selectedDirectTab == "Inbox" && imageName == "Inbox" {
                return .create
                
            }
        default:
            return .normal
        }
        return .normal
  
    }
    var imageName: String

    @Environment (\.colorScheme) var colorScheme

    @StateObject var navigationManager = NavigationManager.shared

    var foreground: Color {
        switch navigationManager.selectedTab {
        case .profile:
            if navigationManager.selectedSelfTab == imageName  {
                return AppearanceManager.shared.currentTheme.vibrantColors[0]
            }
        case .direct:
               if (navigationManager.selectedDirectTab) == imageName {
                   return AppearanceManager.shared.currentTheme.vibrantColors[0]
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
            
             if navigationManager.selectedDirectTab == "Inbox" && imageName == "Inbox" {
                 withAnimation(.spring()) {
                     navigationManager.showNewInbox = true
                 }
                 return
             }
            
             withAnimation(.spring()) {
                 navigationManager.selectedDirectTab = imageName
             }
             if navigationManager.selectedDirectTab == "Feed" && imageName == "Feed" {
                 withAnimation(.spring()) {
                     navigationManager.showNewFeed = true
                 }
                 return
             }
            
             withAnimation(.spring()) {
                 navigationManager.selectedDirectTab = imageName
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
                        }
                    }
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppearanceManager.shared.currentTheme .vibrantGradient)
                                .shadow(color: Color("Shadoww"), radius: 20, x: 4, y: 10)
                                .matchedGeometryEffect(id: "namespace", in: namespace)
                        }
                    }
                }
            }
            .buttonPadding()
            .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
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
