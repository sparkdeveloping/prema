//
//  ChatDetailView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 12/6/23.
//

import SwiftUI

struct ChatDetailView: View {
    @Binding var inbox: Inbox
    @Environment (\.colorScheme) var colorScheme
    
    @State var profile: Profile?
    
    @State var selection = "members"
    
    var tabs: [String] = ["members",
                          "media",
                          "background"]
    var body: some View {
        ZStack {
            Color.clear.nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Spacer()
                    ProfileImageView(avatarImageURL: inbox.avatar)
                        .frame(width: 100, height: 100)
                        .verticalPadding(20)
                    Text(inbox.name)
                        .font(.largeTitle)
                    Spacer()
                    CustomSelectorView(selection: $selection, strings:
                        tabs
                        
                    )
                    .horizontalPadding(-20)
                    HStack {
                        Text("\(inbox.members.count) members")
                            .font(.subheadline)
                        Spacer()
                    }
                    Divider()
                    
                    if selection == "members" {
                        membersView
                            .tag("members")
                    }
                    
                    if selection == "media" {
                        
                    }
                 
                }
                .padding()
            }
            .scrollIndicators(.never)
        }
    }
    
    var membersView: some View {
        VStack {
            ForEach(inbox.members) { profile in
                HStack {
                    ProfileImageView(avatarImageURL: profile.avatarImageURL)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text(profile.username)
                            .bold()
                            .roundedFont()
                        Text("\(inbox.messages.filter({$0.timestamp.profile == profile }).count) total messages")
                            .font(.caption.bold())
                            .roundedFont()
                            .foregroundStyle(.secondary)
                        
                    }
                    Spacer()
                    if inbox.creationTimestamp.profile.id == AccountManager.shared.currentProfile?.id {
                        HStack {
                            Button {
                                
                            } label : {
                                
                                Text("remove")
                                    .font(.subheadline.bold())
                                    .roundedFont()
                            }
                            .foregroundStyle(.red)
                        }
                    }
                }
                .verticalPadding()
                .contentShape(.rect)
                .onTapGesture {
                    self.profile = profile
                }
                .sheet(item: $profile) { profile in
                    ProfileView(profile: profile)
                }
            }
        }
    }
}

