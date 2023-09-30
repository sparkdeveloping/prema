//
//  TabbarViewX.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/18/23.
//

import SwiftUI

struct TabbarViewX: View {
    @EnvironmentObject var navigationManager: NavigationManager

    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
        HStack {
            if isSearching {
                HStack {
                    TextField("Search for plays", text: $searchText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    Button {
                        withAnimation(.spring()){
                            isSearching = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                            .font(.title.bold())
                            .contentShape(.rect)
                    }
                }
            } else {
                ForEach(PlayTab.allCases, id:\ .self) { tab in
                    Button {
                        if tab == .explore {
                            withAnimation(.spring()){
                                isSearching = true
                            }
                        }
                        withAnimation {
                            navigationManager.playTab = tab
                        }
                    } label: {
                        ZStack {
                            Image(tab.rawValue)
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(navigationManager.playTab == tab ? .orange:Color.secondary)
                        }
                        .frame(width: 32)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                    }
                }
                
                Button {
                    withAnimation(.spring()){
                        //                        navigationManager.showModules.toggle()
                    }
                } label: {
                    
                    // Animted Drawer Button..
                    Image("Camera")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .padding(7)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.pink.gradient)
                        }
                        .shadowX(radius: 20)
                        .contentShape(Rectangle())
                }
                .padding(.trailing)
            }
        }
        .padding(.leading, navigationManager.hideModulesButton ? 0:80)
        .padding(.horizontal, navigationManager.hideModulesButton ? 20:0)
        .padding(.bottom, navigationManager.safeArea.bottom + (navigationManager.hideModulesButton ? 20:0))
        .background {
            TransparentBlurView()
                .blur(radius: 7, opaque: false)
                .padding(-10)
        }
        .ignoresSafeArea()
        .onChange(of: isSearching) { _, new in
           
                navigationManager.hideModulesButton = new
            
        }
    }
}
