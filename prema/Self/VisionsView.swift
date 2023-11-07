//
//  VisionsView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Foundation
import SwiftUI

struct VisionsView: View {
    @State var currentTab: String = "visions"
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @StateObject var navigationManager = NavigationManager.shared

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Text("Nov")
                            .bold()
                            .foregroundStyle(Color.vibrant)
                            
                    }
                    .buttonPadding(20)
                    .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                }
                .topPadding(safeAreaInsets.top)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        CustomSelectorView(selection: $currentTab, strings: ["visions", "tasks"])
                        Spacer()
                    }
                    Text("writing ALL your visions down is proof of expectation")
                        .bold()
                        .roundedFont()
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, Double.blobHeight - safeAreaInsets.top)
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea()
        .overlay {
            Color.clear.nonVibrantBackground(cornerRadius: 0, colorScheme: colorScheme)
                .opacity(navigationManager.showNewVision ? 0.9:0)
                .ignoresSafeArea()
            NewVisionView()
                .offset(y: navigationManager.showNewVision  ? 0:AppearanceManager.shared.size.height)
        }
    }
}

struct NewVisionView: View {
    @StateObject var appearanceManager = AppearanceManager.shared
    @StateObject var navigationManager = NavigationManager.shared
    @Environment (\.colorScheme) var colorScheme
    @State var id: String = ""
    @State var name: String = ""
    @State var description: String = ""
    @State var comments: [Comment] = []
    @State var deadline: Date = Date.now
    @State var visionaries: [Profile] = []
    @State var timestamps: [Timestamp] = []
    @State var completionTimestamp: Timestamp? = nil
    @State var showProfilePicker = false
    var buttonEnabled: Bool {
        return false
    }
    
    var body: some View {
 
        ZStack {
            if appearanceManager.isLoading {
                SpinnerView()
                    .frame(width: 80, height: 80)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("New Vision")
                                .font(.largeTitle.bold())
                                .roundedFont()
                            Text("We will make this quick!")
                                .font(.caption)
                        }
                        Spacer()
                        DismissButton() {
                            withAnimation(.spring()) {
                                navigationManager.showNewVision = false
                            }
                        }
                    }
                    VStack {
                        CustomTextField(text: $name, imageName: "Badge", placeHolder: "What is the end result for this goal?")
                        Divider()
                            .padding(10)
                        CustomTextField(text: $name, imageName: "Filter", placeHolder: "What kind of a goal is this?")
                        Divider()
                            .padding(10)
                        HStack {
                            Image("Calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            DatePicker("Deadline", selection: $deadline, in: Date.now..., displayedComponents: .date)
                        }
                        Divider()
                            .padding(10)
                        HStack {
                            Image("Visionary")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            Button {
                                
                            } label : {
                                HStack {
                                    Text("Who is this goal for")
                                    Spacer()
                                }
                            }
                        }
                    }
               
                    if !buttonEnabled {
                        Button {} label: {
                            Text("proceed")
                                .font(.title3.bold())
                                .foregroundStyle(.gray)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .nonVibrantSecondaryBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                        .allowsHitTesting(false)
                    } else {
                        Button {
                           
                            
                        } label: {
                            Text("create")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .vibrantBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                    }
                }
            }
        }
        .padding()
        .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
        .padding()
        .padding(.vertical, 10)
    }
}

struct CustomSelectorView: View {
    @Binding var selection: String
    @Environment (\.colorScheme) var colorScheme
    var strings: [String]
    var body: some View {
        HStack {
            ForEach(strings, id: \.self) { string in
                Button {
                    withAnimation(.spring) {
                        selection = string
                    }
                } label: {
                Text(string)
                    .bold()
                    .roundedFont()
                    .buttonPadding(5)
                    .foregroundStyle(selection == string ? .white:Color.primary)
                    .background {
                        if selection == string {
                            Color.clear
                                .vibrantBackground(cornerRadius: 10, colorScheme: colorScheme)
                        }
                    }
                    .contentShape(.rect)
            }
            }
        }
    }
}
