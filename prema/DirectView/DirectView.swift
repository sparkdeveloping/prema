//
//  DirectView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 9/17/23.
//

import SwiftUI

struct DirectView: View {

    var tabs: [String] = [
        "Home",
        "Events",
        "Search"
    ]
    @State var selectedSubTab = "Best"
    @State var selectedNav = "Quickies"
    var subTabs: [String] = [
        
        "Following",
        "Best",
        "Nearby",
        "Choose"
        
    ]
    var navs: [String] {
        return ["Quickies", "TV", "Voices", "Feed"]
    }
    let strings: [String] = ["1", "2", "3", "4", "5"]
    @State var searchText = ""
    @State var isSearching = false
    @Namespace var namespace
    var body: some View {
        ZStack {
           Text("DIrerct")
        }
        
    }
}
