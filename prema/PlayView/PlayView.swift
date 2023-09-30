//
//  PlayView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/17/23.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var playModel = PlayModel()
 
  
    let strings: [String] = ["1", "2", "3", "4", "5"]
   
    
    @Namespace var namespace
    var body: some View {
        ZStack {
            Color.background
            TabView(selection: $navigationManager.playTab) {
                PlayHomeView()
                    .environmentObject(playModel)
                    .tag(PlayTab.home)
                PlayEventsView()
                    .environmentObject(playModel)
                    .tag(PlayTab.events)
                PlayExploreView()
                    .environmentObject(playModel)
                    .tag(PlayTab.explore)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            NavigationViewX()
                .environmentObject(playModel)
        }
        .overlay(alignment: .bottom) {
            TabbarViewX()
        }
        
    }
}

struct QuickiesView: View {
    var body: some View {
        ScrollView(.vertical) {
            let strings: [String] = ["1", "2", "3", "4", "5"]
            LazyVStack(spacing: 0) { // spacing is 0.
                ForEach(strings, id: \.self) { string in
                    ZStack {
                        Rectangle()
                            .fill(.black.gradient)
                        
                        Text(string)
                            .font(.system(size: 92))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                    }
                    .containerRelativeFrame([.vertical, .horizontal])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        
    }
}

struct TVView: View {
    let strings: [String] = ["1", "2", "3", "4", "5"]
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var size: CGSize {
        return navigationManager.size
    }
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(strings, id: \.self) { string in
                    ZStack {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(.green.gradient)
                        
                        Text(string)
                            .font(.system(size: 92))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                    }
                    .frame(width: size.width - 20, height: 7 / 16 * (size.width - 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .padding(.top, 80)
            .padding(.horizontal, 10)
        }
        .scrollIndicators(.hidden)
    }
}

struct VoicesView: View {
    var body: some View {
        Text("Hey")
    }
}

struct FeedView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let strings: [String] = ["1", "2", "3", "4", "5"]

    var size: CGSize {
        return navigationManager.size
    }
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(strings, id: \.self) { string in
                    FeedCell()
                }
            }
            .padding(.top, 80 + navigationManager.safeArea.top)
            .padding(.horizontal, 10)
        }
        .scrollIndicators(.hidden)
    }
}


struct FeedCell: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Text("20 August 2020")
                    .bold()
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(10)
            VStack(alignment: .leading, spacing: 10) {
                Text("This is meant to be a caption")
                Divider()
                Text("This is also meant to be a caption")
            }
            .padding(.horizontal, 10)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondaryBackground)
                .frame(width: navigationManager.size.width - 40, height: navigationManager.size.width - 40)
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                .shadowX()
            HStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                    Text("@username")
                        .font(.caption.bold())
                        .fontDesign(.rounded)
                }
                Spacer()
                Text("Follow")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(Color.orange.gradient)
                    .clipShape(.rect(cornerRadius: 10, style: .continuous))

            }

        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 40, style: .continuous))
        .shadowX()
        
    }
}
