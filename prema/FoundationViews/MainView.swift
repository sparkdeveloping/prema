//
//  MainView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/16/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    var body: some View {
       let dragGesture = DragGesture()
            .onChanged { value in
                if value.translation.width > 50 {
                    withAnimation(.spring) {
                        navigationManager.showModules = true
                    }
                }
            }
        ZStack{
            
            Color.background
                .ignoresSafeArea()
            LinearGradient(colors: [.pink, .background.opacity(0), .background.opacity(0), .orange, .background.opacity(0), .background.opacity(0), .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .blur(radius: 30)
                .opacity(0.2)
                
            // Side Menu...
            ScrollView(getRect().height < 750 ? .vertical : .init(), showsIndicators: false, content: {
                
                SideMenu()
            })

            ZStack{
                
                // two background Cards...
                
                Color.secondaryBackground
                    .opacity(0.5)
                    .clipShape(.rect(cornerRadius: navigationManager.showModules ? 35 : 0, style: .continuous))                    // Shadow...
                    .shadowX(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: navigationManager.showModules ? -25 : 0)
                    .padding(.vertical,30)
                
                Color.secondaryBackground
                    .opacity(0.4)
                    .clipShape(.rect(cornerRadius: navigationManager.showModules ? 35 : 0, style: .continuous))
                    // Shadow...
                    .shadowX(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: navigationManager.showModules ? -50 : 0)
                    .padding(.vertical,60)
                
                BodyView()
                    .clipShape(.rect(cornerRadius: navigationManager.showModules ? 35 : 0, style: .continuous))
                    .disabled(navigationManager.showModules ? true : false)
                    .shadowX(radius: 50)
                    
            }
            .overlay {
                if navigationManager.showModules {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                        .simultaneousGesture(TapGesture().onEnded { _ in
                            withAnimation {
                                navigationManager.showModules = false
                            }
                        })
                }
            }
            .scaleEffect(navigationManager.showModules ? 0.84 : 1)
            .offset(x: navigationManager.showModules ? getRect().width - 120 : 0)
            .ignoresSafeArea()
            
            .overlay(alignment: navigationManager.showModules ? .bottomTrailing:.bottomLeading) {
                // Menu Button...
                VStack(alignment: .leading) {
                    if !navigationManager.showModules {
                        Color.clear
                            .contentShape(.rect)
                            .frame(width: 50)
                            .highPriorityGesture(dragGesture)
                    }
                
                if !navigationManager.hideModulesButton {
                    Button {
                        withAnimation(.spring()){
                            navigationManager.showModules.toggle()
                        }
                    } label: {
                        
                        // Animted Drawer Button..
                        Image((!navigationManager.showModules ? navigationManager.selectedModule.rawValue:"CloseMenu"))
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .padding(7)
                            .background {
                                if !navigationManager.showModules {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.orange.gradient)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.red.gradient)
                                }
                            }
                            .shadowX(radius: 20)
                            .rotationEffect(.init(radians: navigationManager.showModules ? .pi : 0))
                            .contentShape(Rectangle())
                    }
                    .padding(.horizontal)
             
                    .padding(navigationManager.showModules ? 20:0)
                }
            }
                .padding(.bottom, navigationManager.safeArea.bottom)
            }
        }
        .ignoresSafeArea()
      
    }
}

extension View{
    
    func getRect()->CGRect{
        
        return UIScreen.main.bounds
    }
}
