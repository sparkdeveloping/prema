//
//  ContentView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/16/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var navigationManager: NavigationManager = .init()

    var body: some View {
        GeometryReader {
            // Tab View With Tabs...
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            MainView()
                .environmentObject(navigationManager)
                .onChange(of: safeArea, { oldValue, newValue in
                    navigationManager.safeArea = safeArea
                })
                .onAppear {
                    self.navigationManager.size = size
                    self.navigationManager.safeArea = safeArea
                }
        }
    }
}

