//
//  PlayNavigationView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/18/23.
//

import SwiftUI

struct Theme {
    
}

struct NavigationViewX: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var playModel: PlayModel

    var body: some View {
        ZStack {
            switch navigationManager.selectedModule {
            case .play:
                PlayNavigationBarView()
            default:
                Color.clear
            }
        }
        .padding(.top, navigationManager.safeArea.top)
        .padding(.horizontal, 10)
        .background {
            if playModel.playHomeType != .quickies || navigationManager.playTab != .explore {
                TransparentBlurView()
                    .blur(radius: 7, opaque: false)
                    .padding(-10)
            }
        }
        
    }
    
}

struct PlayNavigationBarView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var playModel: PlayModel
    @Namespace var namespace

    var body: some View {
        switch navigationManager.playTab {
        case .home:
            homeNav
        case .events:
            eventsNav
        default:
            Color.clear
        }
    }
    
    var homeNav: some View {
        VStack(spacing: 0) {
            if playModel.playHomeType != .quickies {
                HStack {
                    ForEach(PlayHomeType.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring()) {
                                playModel.playHomeType = tab
                            }
                        } label: {
                            ZStack {
                                if playModel.playHomeType == tab {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.orange.gradient)
                                        .matchedGeometryEffect(id: "selection1", in: namespace)
                                }
                                
                                Text(tab.rawValue)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(playModel.playHomeType == tab ? .white:.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(.rect)
                        }
                    }
                }
                .frame(height: 40)
            }
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEach(playModel.interests, id: \.self) { tab in
                        VStack(spacing: 0) {
                            Button {
                                
                            } label: {
                                Text(tab)
                                    .fontDesign(.rounded)
                                    .font(playModel.selectedInterest == tab ? .title2:.title3)
                                    .fontWeight(playModel.selectedInterest == tab ? .bold:.semibold)
                                    .foregroundStyle(playModel.selectedInterest == tab ? .orange:.secondary)
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .contentShape(.rect)
                            }
                            if playModel.selectedInterest == tab {
                                Capsule()
                                    .fill(.orange.gradient)
                                    .frame(width: 50, height: 4)
                                    .matchedGeometryEffect(id: "selection", in: namespace)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(height: 50)
            
            
        }
     
    }
    var eventsNav: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(PlayEventType.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring()) {
                            playModel.playEventType = tab
                        }
                    } label: {
                        ZStack {
                            if playModel.playEventType == tab {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.orange.gradient)
                                    .matchedGeometryEffect(id: "selection1", in: namespace)
                            }
                            
                            Text(tab.rawValue)
                                .fontDesign(.rounded)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(playModel.playEventType == tab ? .white:.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                    }
                }
            }
            .frame(height: 50)
            
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEach(playModel.interests, id: \.self) { tab in
                        VStack(spacing: 0) {
                            Button {
                                
                            } label: {
                                Text(tab)
                                    .font(playModel.selectedInterest == tab ? .title2:.title3)
                                    .fontWeight(playModel.selectedInterest == tab ? .bold:.semibold)
                                    .foregroundStyle(playModel.selectedInterest == tab ? .orange:.secondary)
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .contentShape(.rect)
                            }
                            if playModel.selectedInterest == tab {
                                Capsule()
                                    .fill(.orange.gradient)
                                    .frame(width: 50, height: 4)
                                    .matchedGeometryEffect(id: "selection", in: namespace)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(height: 50)
            
            
        }
   
    }
}
