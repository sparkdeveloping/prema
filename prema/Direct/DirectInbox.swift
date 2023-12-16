//
//  DirectView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/6/23.
//

import FirebaseAuth
import SwiftUI
import FirebaseDatabase

struct SelectedInbox: Identifiable {
    var id: String {
        return inbox.id
    }
    var inbox: Inbox
    var frame: CGRect
}

struct DirectInbox: View {
    
    var GodIsGood = true
    
    @State var selection: Inbox?
    @State var selectedChat: SelectedInbox?
    
    //    @Namespace var global_namespace
    
    @StateObject var directManager: DirectManager = .shared
    @StateObject var navigation: NavigationManager = .shared
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @StateObject var namespace = NamespaceWrapper.shared
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 5) {
                
                CustomSelectorView(selection: $directManager.selectedDirectMode, strings: [
                    "all",
                    "groups",
                    "communications",
                    "proxy",
                    "requests"
                ])
                
                ForEach(directManager.inboxes) { inbox in
                    
                    InboxCell(inbox: inbox, selection: $selection)
                }
                
                
            }
//            .background(Color(.systemBackground))
//            .shadow(color: .shadow, radius: 10, x: 0, y: -10)
            .padding(.bottom, 50)
            .padding(.top, Double.blobHeight - safeAreaInsets.top)
        }
        .ignoresSafeArea()
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4)) {
                        selection = nil
                    }
                }
        )
        .sheet(isPresented: $navigation.showNewInbox) {
            
            ProfileSearchView() { profiles in
                navigation.path.append(profiles.inbox)
            }
        }
    }
}

struct InboxCell: View {
    
    @StateObject var navigation = NavigationManager.shared
    @Namespace var namespace
    @ObservedObject var inbox: Inbox
    @Binding var selection: Inbox?
    @StateObject var viewModel = ActivityStatusManager()
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var inboxChangedMessageHandle: DatabaseHandle!
    
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .topLeading) {
                    ZStack {
                        ProfileImageView(avatarImageURL: inbox.avatar)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(22)
                    
                    Circle()
                        .foregroundStyle(viewModel.statusColor)
                        .overlay {
                            ZStack {
                                if inbox.isGroup {
                                    Text("\(viewModel.inChatCount > 0 ? viewModel.inChatCount:  viewModel.onlineCount > 0 ? viewModel.onlineCount:inbox.members.count)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                }
                            }
                        }
                        .frame(width: !inbox.isGroup ? 10:16, height: !inbox.isGroup ? 10:16)
                        .padding(3)
                        .background(Circle().foregroundColor(.background))
                        .offset(x: -3, y: -3)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(inbox.name)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.orange)
                        Image(systemName: "bell.slash.fill")
                            .foregroundColor(Color.gray)
                    }
                    
                    if let message = inbox.recentMessage, Date.now.timeIntervalSince1970 - message.timestamp.time < 300, viewModel.typingCount == 0 {
                    Text(inbox.recentMessage?.text ?? "")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text(viewModel.statusText)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(viewModel.statusColor)
                            .lineLimit(1)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(inbox.recentMessage?.timestamp.time.chatTime ?? "")")
                        .font(.caption)
                        .roundedFont()
                    if inbox.unreadCount > 0 {
                        Text("\(inbox.unreadCount)")
                            .font(.caption.bold())
                            .roundedFont()
                            .foregroundColor(.white)
                            .padding(5)
                            .padding(.horizontal, 4)
                            .background(Color.vibrant)
                            .clipShape(Capsule())
                    }
                }
            }
            if let selection, selection.id == inbox.id {
                Divider()
                    .padding(10)
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
                    .padding(7)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.1))
                
                    .cornerRadius(12)
                //                        .shadow(color: .shadow, radius: 10, x: 0, y: 0  )
                Spacer()
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.purple)
                        .padding(7)
                        .padding(.horizontal, 10)
                        .background(Color.secondary.opacity(0.1))
                    
                        .cornerRadius(12)
                    //                        .shadow(color: .shadow, radius: 10, x: 0, y: 0  )
                    Spacer()
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(7)
                        .padding(.horizontal, 10)
                        .background(Color.secondary.opacity(0.1))
                    
                        .cornerRadius(12)
                    //                        .shadow(color: .shadow, radius: 10, x: 0, y: 0  )
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                            .padding(7)
                            .padding(.horizontal, 10)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        //                        .shadow(color: .shadow, radius: 10, x: 0, y: 0  )
                    }
                }
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
        .matchedGeometryEffect(id: "blur", in: namespace)
        .cornerRadius(30)
        .padding(.horizontal)
        .onChange(of: viewModel.status) { newValue in
            inbox.status = viewModel.status
        }
        .onAppear {
            self.viewModel.getStatus(inbox: inbox)
        }
        .onTapGesture {
            if selection == nil {
                withAnimation(.spring(response: 0.4)) {
                    navigation.path.append(inbox)
                }
            }
        }
        .onScalingLongPress {
            self.haptic()
            withAnimation(.spring(response: 0.4)) {
                selection = inbox
            }
            
        }
     
    }
}

struct ProfileSearchView: View {
    
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.dismiss) var dismiss
    @EnvironmentObject var appearance: AppearanceManager
    var preloadTitle: String?
    var preload: [Profile]?
    
    
    
    @State var profiles: [Profile] = []
    @State var selectedProfiles: [Profile] = []
    
    @StateObject var directManager = DirectManager.shared
    
    @State var text = ""
    var action: ([Profile]) -> ()
    
    init(preloadTitle: String? = nil, preload: [Profile]? = nil, action: @escaping ([Profile]) -> ()) {
        self.preloadTitle = preloadTitle
        self.preload = preload
        self.action = action
    }
    
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
                        .buttonPadding(15)
                        .nonVibrantBackground(cornerRadius: 17, colorScheme: colorScheme)
                    DismissButton() {
                        NavigationManager.shared.showNewInbox = false
                    }
                }
                VStack(alignment: .leading) {
                    if let preloadTitle {
                        Text(preloadTitle)
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                    if let preload {
                        ForEach(preload) { profile in
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
                                    if selectedProfiles.contains(profile) {
                                        Text(selectedProfiles.contains(profile) ? "deselect":"select")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(selectedProfiles.contains(profile) ? .secondary:appearance.currentTheme.vibrantColors[0])
                                    }
                                    
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
                            if selectedProfiles.contains(profile) {
                                Text(selectedProfiles.contains(profile) ? "deselect":"select")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(selectedProfiles.contains(profile) ? .secondary:appearance.currentTheme.vibrantColors[0])
                            }
                            
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
