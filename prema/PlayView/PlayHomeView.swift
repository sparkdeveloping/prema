//
//  PlayHomeView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/18/23.
//

import SwiftUI

struct PlayHomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var playModel: PlayModel

   
    var body: some View {
        ZStack {
            TabView(selection: $playModel.playHomeType) {
                FeedView()
                    .tag(PlayHomeType.feed)
                QuickiesView()
                    .tag(PlayHomeType.quickies)
                TVView()
                    .tag(PlayHomeType.tv)
                VoicesView()
                    .tag(PlayHomeType.voices)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
     
        
    }
}
