//
//  BodyView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/16/23.
//

import SwiftUI

struct BodyView: View {
  
    @EnvironmentObject var navigationManager: NavigationManager
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    
    var body: some View {
        
        TabView(selection: $navigationManager.selectedModule){
            ProfileView()
                .tag(Module.profile)
                .ignoresSafeArea()
            PlayView()
                .tag(Module.play)
                .ignoresSafeArea()
            DirectView()
                .tag(Module.direct)
                .ignoresSafeArea()
            ShopperView()
                .tag(Module.shopper)
                .ignoresSafeArea()
            Help()
                .tag(Module.ride)
                .ignoresSafeArea()
            SupportView()
                .tag(Module.support)
                .ignoresSafeArea()
        }
    }
}





struct History: View {
    
    var body: some View{
        
        NavigationView{
            
            Text("History")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .navigationTitle("History")
        }
    }
}

struct Notifications: View {
    
    var body: some View{
        
        NavigationView{
            
            Text("Notifications")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .navigationTitle("Notifications")
        }
    }
}

struct Settings: View {
    
    var body: some View{
        
        NavigationView{
            
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .navigationTitle("Settings")
        }
    }
}

struct Help: View {
    
    var body: some View{
        
        NavigationView{
            
            Text("Help")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .navigationTitle("Help")
        }
    }
}
