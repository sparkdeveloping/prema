//
//  DirectView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/6/23.
//

import FirebaseAuth
import SwiftUI

struct DirectInbox: View {
    
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @StateObject var directManager: DirectManager = .shared
    @StateObject var accountManager: AccountManager = .shared
    @StateObject var authManager: AuthManager = .shared
    @EnvironmentObject var navigation: NavigationManager
    
    @Namespace var namespace
    
    var body: some View {
        GeometryReader { geometry in
            if let _ = accountManager.currentProfile {
                ZStack {
                    
                    ScrollView {
                        
                        VStack {
                            ScrollView(.horizontal) {
                                HStack {
                                    CustomSelectorView(selection: $directManager.selectedDirectMode, strings: [
                                        "all",
                                        "groups",
                                        "communities",
                                        "proxy",
                                        "requests",
                                    ])
                                    Spacer()
                                }
                            }
                            .scrollIndicators(.hidden)
                            Spacer()
                            ForEach(directManager.inboxes) { inbox in
             
                                    HStack {
                                        ProfileImageView(avatarImageURL: inbox.avatar)
                                            .frame(width: 40, height: 40)
                                        VStack(alignment: .leading) {
                                            Text(inbox.name)
                                                .bold()
                                                .roundedFont()
                                            if let message = inbox.recentMessage {
                                                Text(message.preview)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        Spacer()
                                        VStack {
                                            if let message = inbox.recentMessage {
                                                Text(message.timestamp.time.chatTime)
                                                    .font(.caption)
                                            }
                                            if inbox.isUnread {
                                                Text("\(inbox.unreadCount)")
                                                    .font(.subheadline.bold())
                                                    .roundedFont()
                                                    .buttonPadding(5)
                                                    .vibrantBackground(cornerRadius: 10, colorScheme: colorScheme)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .verticalPadding(10)
                                    .horizontalPadding()
                                    .background(Color.secondary.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                                    .horizontalPadding()
                                    .contentShape(.rect)
//                                    .matchedGeometryEffect(id: "chatProfile-\(inbox.id)", in: NamespaceWrapper.shared.namespace!)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            navigation.path.append(inbox)
                                        }
                                    }
                                
                            }
                        }
                        .topPadding(CGFloat(geometry.size.width) * CGFloat(0.6) * CGFloat(247) / CGFloat(277) - CGFloat(safeAreaInsets.bottom))
                        .horizontalPadding()
                        
                    }
                 
                    VStack {
                        HStack {
                            Spacer()
                            if let currentAccount = accountManager.currentAccount {
                                Menu {
                                    ForEach(currentAccount.profiles) { profile in
                                        Button(profile.username) {
                                            do {
                                                try Auth.auth().signOut()
                                                if let password = currentAccount.password {
                                                    authManager.login(email: currentAccount.email, password: password) {
                                                        withAnimation(.spring()) {
                                                            AccountManager.shared.currentProfile = profile
                                                        }
                                                        DirectManager.shared = .init()
                                                        appearance.stopLoading()
                                                    }
                                                }
                                            } catch {}
                                        }
                                    }
                                } label: {
                                    Text("@" + (accountManager.currentProfile?.username ?? ""))
                                        .bold()
                                        .foregroundStyle(Color.vibrant)
                                        .buttonPadding(20)
                                        .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                                    
                                }
                            }
                        }
                        .topPadding(safeAreaInsets.top)
                        .padding()
                        Spacer()
                        
                    }
                }
                .ignoresSafeArea()
                .sheet(isPresented: $navigation.showNewInbox) {
                    
                    ProfileSearchView() { profiles in
                        navigation.path.append(profiles.inbox)
                        
                    }
                    
                }
                .overlay {
                    
                }
            }
        }
    }
}



struct ProfileSearchView: View {
    
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.dismiss) var dismiss
    @EnvironmentObject var appearance: AppearanceManager

    var action: ([Profile]) -> ()
    @State var profiles: [Profile] = []
    @State var selectedProfiles: [Profile] = []

    @StateObject var directManager = DirectManager.shared

    @State var text = ""
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    TextField("Search for people", text: $text)
                        .onChange(of: text) { o, v in
                            directManager.searchProfiles(search: v) { profiles in
                                withAnimation(.spring()) {
                                    self.profiles = profiles
                                }
                            }
                        }
                        .buttonPadding()
                        .nonVibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                    DismissButton() {
                        NavigationManager.shared.showNewInbox = false
                    }
                }
                ForEach(profiles) { profile in
                    VStack {
                        HStack {
                            ProfileImageView(avatars: profile.avatars)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(profile.fullName)
                                    .bold()
                                    .roundedFont()
                                Text("@" + profile.username)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Circle()
                                .fill(selectedProfiles.contains(profile) ? appearance.currentTheme.vibrantColors[0]:.secondary)
                                .frame(width: 12, height: 12)
                        }
                        Divider()
                    }
                    .buttonPadding()
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if let index = self.selectedProfiles.firstIndex(of: profile) {
                                self.selectedProfiles.remove(at: index)
                            } else {
                                self.selectedProfiles.insert(profile, at: 0)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            Button {
                action(selectedProfiles)
                dismiss()
            } label: {
                Text("finish with \(selectedProfiles.count)")
                    .bold()
                    .roundedFont()
                    .foregroundStyle(.white)
                    .buttonPadding(20)
                    .frame(maxWidth: .infinity)
                    .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                
            }
            .padding()
        }
    }
}

extension Date {
    var convertToHumanReadableFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentTime = Date()
        let timeDifference = Int(currentTime.timeIntervalSince(self))
        
        if timeDifference < 60 {
            return "Just now"
        } else if timeDifference < 3600 {
            let minutes = timeDifference / 60
            return "\(minutes) minutes ago"
        } else if timeDifference < 86400 {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: self)
        } else if timeDifference < 172800 {
            return "Yesterday"
        } else if timeDifference < 604800 {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: self)
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }
}

extension Double {
    var chatTime: String {
        return Date(timeIntervalSince1970: self).convertToHumanReadableFormat
    }
}

extension Message {
    var preview: String {
        
        return self.timestamp.profile == AccountManager.shared.currentProfile ? "you: " + (self.text ?? ""):self.text ?? ""
    }
}
