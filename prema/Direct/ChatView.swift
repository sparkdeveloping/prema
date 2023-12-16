//
//  ChatView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/15/23.
//

import AVFoundation
import DSWaveformImage
import VideoPlayer
import DSWaveformImageViews
import SwiftUI
import Combine

struct ChatView: View {
    
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var navigation: NavigationManager
    @EnvironmentObject var chatManager: ChatManager
    @Namespace var namespace
    @StateObject var statusViewModel = ActivityStatusManager()

    var GodIsGood = true
    @State var headerFrame: CGRect = .zero
    @State var reply: Message?
    
    var chatContextMenuAndHeader: some View {
        
        let message = chatManager.selectedMessage
        return ZStack {
        if let frame = message?.frame {
            
            let right = message?.timestamp.profile.id == AccountManager.shared.currentProfile?.id
            let width: CGFloat = frame.width
            let minX: CGFloat = frame.minX
            let maxX: CGFloat = frame.maxX
            let minY: CGFloat = frame.minY
            
            let rX = maxX - ((headerFrame.width - 40) / 2) - 10
            let y = (minY) - (70)
            
            let lX = minX + ((headerFrame.width - 40) / 2) + 10
            
            let finalY = message == nil ? (safeAreaInsets.top):y
            let finalX = message == nil ? (appearance.size.width / 2):right ? rX:lX
            
            ChatContextView() { frame in
                headerFrame = frame
            }
            //        .matchedGeometryEffect(id: "chatProfile-\(chatManager.inbox.id)", in: NamespaceWrapper.shared.namespace!)
            .environmentObject(chatManager)
            .environmentObject(statusViewModel)
            .scaleEffect(message == nil ? 0.4:1)
            .position(x: AppearanceManager.shared.size.width / 2/*finalX*/, y:  finalY)
            .animation(.spring(), value: message)
            .animation(.spring(), value: finalX)

        } else {
            Spacer()
//        return ZStack {
//            if let frame = message?.frame {
//                ChatTopView() { frame in
//                    headerFrame = frame
//                }
//                .scaleEffect(message == nil ? 0.4:1)
//                .environmentObject(chatManager)
//                .position(x: frame.midX, y:  frame.midY)
//            } else {
//                Spacer()
            }
        }
    }
    var body: some View {
        ZStack {
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    if chatManager.selection == "chat" {
                        MessagesView(namespace: _namespace)
                            .environmentObject(statusViewModel)
                            .environmentObject(chatManager)
                            .opacity(chatManager.reply == nil ? 1:0.1)
                            .ignoresSafeArea()
                            .simultaneousGesture(TapGesture().onEnded { _ in hideKeyboard()})
                            .overlay {
                                if chatManager.selectedMessage != nil {
                                    Color.background.opacity(0.1)
                                        .contentShape(.rect)
                                        .onTapGesture {
                                            withAnimation {
                                                chatManager.selectedMessage = nil
                                            }
                                        }
                                }
                            }
                    } else {
                        if chatManager.visions.isEmpty {
                            Text("You ")
                        } else {
                            ScrollView {
                                if chatManager.visions.isEmpty {
                                    VStack {
                                        LottieView(name: "Empty")
                                            .frame(width: size.width / 4, height: size.width / 4)
                                            .verticalPadding(40)
                                        Text("You do not have any Visions yet :(")
                                            .font(.subheadline.bold())
                                            .roundedFont()
                                            .foregroundStyle(.secondary)
                                        Button {
                                            withAnimation(.spring()) {
                                                navigation.showNewVision = true
                                            }
                                        } label: {
                                            Text("Create My First Vision")
                                                .bold()
                                                .roundedFont()
                                                .foregroundStyle(.white)
                                                .buttonPadding()
                                                .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                                            
                                        }
                                        .topPadding(20)
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    LazyVStack {
                                        ForEach(chatManager.visions) { vision in
                                            VisionCellView(vision: vision)
                                        }
                                    }
                                    .padding()
                                    .padding(.top, Double.blobHeight - safeAreaInsets.top)
                                    .padding(.bottom, safeAreaInsets.bottom + 20)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    chatManager.fetchMessages()
                    chatManager.listenForChatChanges()
                }
                
                .onTapGesture {
                    withAnimation(.spring()) {
                        chatManager.selectedMessage = nil
                    }
                }
                chatContextMenuAndHeader
                    .opacity(chatManager.reply == nil ? 1:0.1)
                    .opacity(chatManager.selectedMessage == nil ? 0:1)
                    .simultaneousGesture(TapGesture().onEnded { _ in hideKeyboard()})
                
                VStack {
                    if chatManager.selectedMessage == nil {
                        ChatTextField()
                            .environmentObject(chatManager)
                            .environmentObject(appearance)
                            .environmentObject(statusViewModel)
                            .simultaneousGesture(TapGesture().onEnded { _ in hideKeyboard()})
                        
                        //                        .matchedGeometryEffect(id: "chatProfile-\(chatManager.inbox.id)", in: NamespaceWrapper.shared.namespace!)
                    }
                    
                    Spacer()
                    if chatManager.selection == "chat" {
                        
                        ChatInputView()
                            .environmentObject(chatManager)
                            .ignoresSafeArea()
                    }
                }
                .ignoresSafeArea()
                .onChange(of: chatManager.currentChatMode) { _, v in
                    let defaults = UserDefaults.standard
                    defaults.set(v.rawValue, forKey: "\(chatManager.inbox.id)-chatmode")
                }
            }
        }
        .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
        .ignoresSafeArea()
    }
}


struct MessagesView: View {
    
    @EnvironmentObject var chatManager: ChatManager
    

    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @Namespace var namespace
    
    
    @EnvironmentObject var statusViewModel: ActivityStatusManager

    var body: some View {
        GeometryReader { proxy in
            List {
            
                LazyVStack {
                    if !statusViewModel.typing.isEmpty || (chatManager.inbox.isGroup && statusViewModel.statusText == "typing...") {
                        HStack {
                            Text(statusViewModel.statusText)
                                .font(.subheadline.bold())
                                .roundedFont()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)

                        .padding(.leading, 20)
                        .verticalPadding()
                            .rotationEffect(.radians(.pi))
                    }
                    ForEach(chatManager.messages) { message in
                        ChatBubble(message: message, namespace: _namespace)
                            .animation(.easeInOut(duration: 0.3), value: chatManager.messages)
                            .matchedGeometryEffect(id: "chat-bubble-\(message.id)", in: namespace)
                            .listRowBackground(Color.clear)
                        
                    }
                    
                }
                .padding(.bottom, Double.blobHeight - safeAreaInsets.top)
                .padding(.top, safeAreaInsets.bottom + 50 + (chatManager.reply?.frame.height ?? 0))
                .ignoresSafeArea()
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .rotationEffect(Angle(degrees: 180))
            .background(Color.nonVibrant(colorScheme))
            .scrollContentBackground(.hidden)
            .keyboardAware()
        }
        .background(Color.clear)
       
    }
    
}

struct ChatBubble: View {
    @EnvironmentObject var appearance: AppearanceManager
    @Environment (\.colorScheme) var colorScheme
    @ObservedObject var message: Message
    @StateObject var namespacee = NamespaceWrapper.shared

    @StateObject private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    @EnvironmentObject var viewModel: ChatManager
    @Namespace var namespace
    var type: MessageType {
        return message.type
    }
    
    @StateObject var navigation = NavigationManager.shared

    var showRecentTimestamp: Bool {
        if let firstIndex = viewModel.messages.firstIndex(of: message), firstIndex != (viewModel.messages.count - 1) {
            if message.timestamp.time - viewModel.messages[firstIndex + 1].timestamp.time < 300 {
                return false
            }
        }
        return true
    }
    @State var isLongPressing = false
    
    var fromMe: Bool {
        return message.timestamp.profile.id == AccountManager.shared.currentProfile?.id
    }
    
    var inbox: Inbox {
        return viewModel.inbox
    }
    @State var animateShow = false
    var body: some View {
        VStack {
            
            if showRecentTimestamp && !message.isReply {
                Text(message.timestamp.time.chatTime)
                    .font(.caption)
                    .opacity(viewModel.selectedMessage == nil ? 1:0.1)
                
            }
          
            HStack(alignment: .top) {
                if message.timestamp.profile.id == AccountManager.shared.currentProfile?.id && !message.isReply {
                    Spacer(minLength: 0.25 * appearance.size.width)
                }
                
                if inbox.isGroup && !fromMe {
                    ProfileImageView(avatarImageURL: message.timestamp.profile.avatarImageURL)
                        .frame(width: 34, height: 34)
                }
               
                VStack(alignment: fromMe ? .trailing:.leading) {
                    if inbox.isGroup && !fromMe {
                        Text(message.timestamp.profile.fullName.formattedName(from: inbox.members.map{$0.fullName}))
                            .font(.caption2)
                            .roundedFont()
                    }
                        if let reply = message.reply, !self.message.isReply{
                        HStack {
                          
                            if message.timestamp.profile.id != AccountManager.shared.currentProfile?.id {
                                BubbleBackground
                                    .frame(width: 10, height: 10)
                                    .clipShape(Circle())
                            }
                      
                            ChatBubble(message: reply)
//                                .padding(.horizontal, -20)
                                .scaleEffect(0.9, anchor: reply.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .bottomTrailing:.bottomLeading)
                                .opacity(0.6)
                                .rotationEffect(.init(radians: .pi))
                        
                            if message.timestamp.profile.id == AccountManager.shared.currentProfile?.id {
                                BubbleBackground
                                    .frame(width: 10, height: 10)
                                    .clipShape(Circle())
                            }
                  
                        }
                    }
                    
                    HStack {
                        if let expiryTime = message.expiry, expiryTime + message.timestamp.time < Date.now.timeIntervalSince1970 {
                            Text("Expired Message")
                                .font(.caption2)
                                .italic()
                                .foregroundColor(message.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .white:.primary)
                        } else if let destructive = message.destruction, destructive + message.timestamp.time < Date.now.timeIntervalSince1970 || message.opened.contains(where: {$0.id == AccountManager.shared.currentProfile?.id ?? ""}){
                            Text("Destroyed Message")
                                .font(.caption2)
                                .italic()
                                .foregroundColor(message.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .white:.primary)
                        } else {
                            switch message.type {
                            case .text:
                                textMessage
                            case .audio:
                                audioMessage
                            case .image, .video:
                                if let media = message.media {
                                    ZStack {
                                        ForEach(media.indices, id: \.self) { i in
                                            ZStack {
                                                if let thumbnail = media[i].imageURLString {
                                                    ImageX(urlString: thumbnail)
                                                    
                                                    //                                                    .offset(x: -5 * i, y: -5 * i)
                                                    //                                                .offset(x: -i * 5, y: -i * 5)
                                                } else if let image = media[i].uiImage {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                }
                                                if media[i].type == .video {
                                                    Image(systemName: "play.fill")
                                                        .font(.largeTitle.bold())
                                                        .padding(10)
                                                        .background(.regularMaterial)
                                                        .clipShape(.rect(cornerRadius: 22, style: .continuous))
                                                }
                                            }
//                                            .frame(width: (appearance.size.width - 40) * 0.75 * media[i].ratio,
//                                                   height: (appearance.size.width - 40) * 0.75)
                                            .cornerRadius(20)
                                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                                            .padding(-20)
                                            //                                        .offset(x: -i * 5, y: -i * 5)
                                           
                                        }
                                    }
                                    .matchedGeometryEffect(id: "mediaplayer-\(media[0].id)", in: namespacee.namespace!)

                                }
                            case .sticker:
                                ZStack {
                                    if let thumbnail = message.sticker?.imageURLString {
                                        ImageX(urlString: thumbnail)
                                        
                                    }
                                }
                                .frame(width: (appearance.size.width - 40) * 0.4,
                                       height: (appearance.size.width - 40) * 0.4)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                            }
                        }
                    }
                    .padding(.vertical, ((message.text ?? "").containsOnlyEmoji || message.type == .sticker) ? 0:(message.type == .sticker ? 0:10))
                    .padding(.horizontal, ((message.text ?? "").containsOnlyEmoji || message.type == .sticker) ? 0:(message.type == .sticker ? 0:20))
                    .background {
                        if (!(message.text ?? "").containsOnlyEmoji && message.type != .sticker) {
                            BubbleBackground
                        }
                    }
                    .clipShape(.rect(cornerRadii: .init(topLeading: fromMe ? 22:7, bottomLeading: 22, bottomTrailing: fromMe ? 7:22, topTrailing: 22)))
                    .overlay(alignment: fromMe ? .bottomTrailing:.topLeading) {
                        if message.expiry != nil {
                            Image("Expire")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .opacity(0.5)
                                .padding(4)
                        }
                        if message.destruction != nil {
                            Image("Bomb")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .opacity(0.5)
                                .padding(4)
                        }
                    }
                    .shadow(color: Color("Shadoww"), radius: 10, x: 0, y: 0)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: isLongPressing, perform: { _ in
                                    withAnimation(.spring()) {
                                        self.message.frame = geometry.frame(in: .global)
                                        print("message id: \(message.frame)")
                                        self.viewModel.selectedMessage = self.viewModel.selectedMessage == nil ? message:nil
                                    }
                                })
                            
                        }
                    )
                    .onTapGesture {
                        
                        if let media = message.media, !media.isEmpty, viewModel.selectedMessage == nil {
                            withAnimation(.spring) {
                                navigation.media = media
                            }
                        }
                        
                    }.onScalingLongPress {
                        self.isLongPressing.toggle()
                        self.haptic()
                    }
                    
                  
                    if viewModel.messages.first?.id == message.id && message.timestamp.profile.id == AccountManager.shared.currentProfile?.id  && !message.isReply {
                        HStack {
                            Text(message.timestamp.time.chatTime)
                                .font(.caption)
                              
                            if !message.opened.isEmpty {
                                Text(" ・ \(viewModel.inbox.isGroup ?  "\(message.opened.count)":"read")")
                                    .font(.caption)
                            }
                            
                        }
                        .padding(.horizontal, 10)
                        .opacity(viewModel.selectedMessage == nil ? 1:0.1)
                    }
            
                }
               
                
                if message.timestamp.profile.id != AccountManager.shared.currentProfile?.id && !message.isReply {
                    Spacer(minLength: 0.25 * appearance.size.width)
                }
            }
            .opacity(viewModel.selectedMessage == nil ? 1:viewModel.selectedMessage != message ? 0.1:1)
        }
        .rotationEffect(Angle(degrees: 180))
//        .opacity(message.isSent ? 1:0.5)
        .offset(x: animateShow ? 0:(fromMe ? -AppearanceManager.shared.size.width:AppearanceManager.shared.size.width))
        .opacity(animateShow ? 1:0)
        .animation(.spring(response: 0.5), value: animateShow)
        .onAppear {
            animateShow = true
          
            viewModel.openedMessage(message)
        }
        .onDisappear {
            animateShow = false
        }
    }
    
    var fromColors: [Color] {
        let isSensitive = message.expiry != nil
        let isDestructive = message.destruction != nil
        return isDestructive ? [.red, .red]:isSensitive ? [.indigo, .purple]:AppearanceManager.shared.currentTheme.vibrantColors
    }
    
    var toColors: [Color] {
        let isSensitive = message.expiry != nil
        let isDestructive = message.destruction != nil
        return isDestructive ? [.black, .black]:isSensitive ? [.indigo, .purple]:[.secondary.opacity(0.1), .secondary.opacity(0.2)]
    }
    
    var BubbleBackground: some View {
        ZStack {
            if message.isMessageSendError {
                Color.red.opacity(0.9)
            } else {
                if message.timestamp.profile.id == AccountManager.shared.currentProfile?.id {
                    switch type {
                    case .text, .audio:
                        LinearGradient(colors: fromColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    case .sticker, .image, .video:
                        Color.clear
                    }
                }  else {
                    switch type {
                    case .text, .audio:
                        LinearGradient(colors: toColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    case .sticker, .image, .video:
                        Color.clear
                    }
                }
            }
        }
    }
    
    var textMessage: some View {
        Text(message.text ?? "")
            .font(.system(size: (message.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).containsOnlyEmoji ? 60:15, design: .rounded))
            .foregroundColor(message.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .white:.primary)
    }
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .white, width: 3, spacing: 3)))
    @State var liveConfigurationPlayback: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .black, width: 3, spacing: 3)))
    
    var audioMessage: some View {
        ZStack {
            if let audioURLString = message.media?.first?.audioURLString, let audioURL = URL(string: audioURLString) {
                AudioPlayerControlsView(player: player,
                                        viewModel: AudioPlayeViewModel(url: audioURL),
                                        durationObserver: PlayerDurationObserver(player: player),
                                        itemObserver: PlayerItemObserver(player: player), audioURL: audioURL)
                .onAppear {
                    print("yeet audio appeared: \(audioURL)")
                    let playerItem = AVPlayerItem(url: audioURL)
                    player.replaceCurrentItem(with: playerItem)
                    player.play()
                }
                .simultaneousGesture(TapGesture().onEnded  {
                    print("yeet audio clicked: \(audioURL)")
                    let playerItem = AVPlayerItem(url: audioURL)
                    player.replaceCurrentItem(with: playerItem)
                    player.play()
                })
                .onTapGesture(coordinateSpace: .global) { location in
                    audioPlayerManager.seek(to: location.x)
                }
            }
        }
        .frame(height: 40)
    }
}

struct ChatFunCenterView: View {
    @Environment (\.colorScheme) var colorScheme
    @StateObject var directManager = DirectManager.shared
    @EnvironmentObject var viewModel: ChatManager
    var inbox: Inbox {
        return viewModel.inbox
    }

    var body: some View {
       
            VStack {
                
                HStack {
                    Text("Stickers")
                        .font(.system(size: 18, weight: .bold, design: .rounded))

                    Spacer()
                    Text("Create")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(height: 38)
                        .padding(.horizontal, 10)
                        .vibrantBackground(cornerRadius: 24, colorScheme: colorScheme)
                        .onTapGesture {
                            NavigationManager.shared.path.append("create-sticker|\(inbox.id)")
                            viewModel.showingStickerView = false
                        }
                    DismissButton {
                        viewModel.showingStickerView.toggle()
                    }
                }
       
                Divider()
                if directManager.stickers.isEmpty {
                    ContentUnavailableView {
                        Color.clear
//                        EmptyPostsView(message: "")
                    } description: {
                        Text("No Stickers in this chat")
                    } actions: {
                        
                        Button("Create") {
                            NavigationManager.shared.path.append("create-sticker|\(inbox.id)")
                            viewModel.showingStickerView = false
                        }
                    }

                } else {
                    
                    ScrollView {
                        LazyVGrid(columns: [.init(.flexible(), spacing: 5),
                                            .init(.flexible(), spacing: 5),
                                            .init(.flexible(), spacing: 5)]) {
                                                ForEach(directManager.stickers) { sticker in
                                                    
                                                    ImageX(urlString: sticker.imageURLString)
                                                        .frame(width: (AppearanceManager.shared.size.width - 70) / 3, height: (AppearanceManager.shared.size.width - 70) / 3)
                                                        .onTapGesture {
                                                            viewModel.sticker = sticker
                                                            viewModel.sendMessage()
                                                            viewModel.showingStickerView.toggle()
                                                        }
                                                    
                                                }
                                            }
                    }
                    .frame(width: AppearanceManager.shared.size.width - 60, height: AppearanceManager.shared.size.width - 60)
                }
              
            }
  
            .padding(10)
//            .offset(y: viewModel.showingStickerView ? 0:getRect.height)
//            .animation(.spring(), value: viewModel.showingStickerView )
          
        
    }
    
}

struct ChatBubblePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

enum ChatContextMode {
    case info, reactions, reply, forward
}

struct ChatContextView: View {
    @EnvironmentObject var appearance: AppearanceManager
    
    @EnvironmentObject var viewModel: ChatManager
    @StateObject var navigationManager = NavigationManager.shared
    @Environment (\.dismiss) var dismiss
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Namespace var namespace

    var frame: (CGRect) -> ()
    
    enum ChatTopViewMode {
        case header, voice_call, video_call, context, detail
    }
    
    
    var mode: ChatTopViewMode {
        return viewModel.selectedMessage == nil ? .header:.context
    }

    var emojis: [String] {
        var array: [String] = []
        for i in 0x1F601...0x1F64F {
            guard let scalar = UnicodeScalar(i) else { continue }
            let c = String(scalar)
            array.append(c)
        }
        return array
    }
    
    
    @State var showAllEmojis = false
    var layout = [GridItem(.flexible(), spacing: 5),
                  GridItem(.flexible(), spacing: 5),
                  GridItem(.flexible(), spacing: 5),
                  GridItem(.flexible(), spacing: 5),
                  GridItem(.flexible(), spacing: 5)]
    var body: some View {
        
        
        VStack {

                switch viewModel.contextMode {
                case .reactions:
                    ZStack(alignment: .top) {
                        if !showAllEmojis {
                            HStack {
                                ForEach(emojis.prefix(5), id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 34))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                                self.viewModel.reaction = emoji
                                                self.viewModel.sendMessage()
                                        }
                                }
                                DismissButton {
                                    withAnimation(.spring()) {
                                        showAllEmojis.toggle()
                                    }
                                }
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: layout) {
                                    ForEach(emojis, id: \.self) { emoji in
                                        
                                        Text(emoji)
                                            .font(.system(size: 34))
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                
                                                    self.viewModel.reaction = emoji
                                                    self.viewModel.sendMessage()
                                                
                                            }
                                        
                                    }
                                }
                            }
                            .frame(height: appearance.size.width * 0.75)
                        }
                    }
                    .frame(width: appearance.size.width * 0.75)
                default:
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.title2.bold())
                            .padding(10)
                        Divider()
                            .frame(height: 10)
                        Image(systemName: "face.smiling.fill")
                            .font(.title2.bold())
                            .padding(10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    
                                    self.viewModel.contextMode = .reactions
                                }
                            }
                        Divider()
                            .frame(height: 10)
                        HStack {
                            Image(systemName: "square.filled.on.square")
                                .font(.title2.bold())
                                .padding(10)
                            Divider()
                                .frame(height: 10)
                            Image(systemName: "arrowshape.turn.up.backward.fill")
                                .font(.title2.bold())
                                .padding(10)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        
                                        self.viewModel.reply = viewModel.selectedMessage
                                        print("reply message is: \(self.viewModel.reply)")
                                        viewModel.selectedMessage = nil
                                        print("reply message is: \(self.viewModel.reply)")

                                    }
                                }
                            Divider()
                                .frame(height: 10)
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                                .font(.title2.bold())
                                .padding(10)
                            Divider()
                                .frame(height: 10)
                        }
                        Image(systemName: "trash.fill")
                            .font(.title2.bold())
                            .padding(10)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    viewModel.deleteMessage()
                                    viewModel.selectedMessage = nil
                                }
                            }
                        
                    }
                }
         
        }
        .padding(10)
        .background(.regularMaterial)
//        .background {
//            TransparentBlurView(removeAllFilters: true)
//                .blur(radius: 3, opaque: false)
//                .padding([.horizontal, .top], -6)
//        }
        .clipShape(.rect(cornerRadius: 24, style: .continuous))
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(style: .init(lineWidth: 1.5)).opacity(0.1))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: mode) { _ in
                        withAnimation(.spring()) {
                            frame(geometry.frame(in: .global))
                            
                        }
                    }
                
            }
        )
        .padding(.horizontal)
        .padding(.top, safeAreaInsets.top)
       
    }
    
}

struct ChatInputView: View {
    
    @State var showAllOptions = false
    @EnvironmentObject var viewModel: ChatManager
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase

    @StateObject private var audioRecorder: AudioRecorder = AudioRecorder()
    @StateObject private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    @StateObject private var statusObserver = TypingObserver()

    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .systemBlue, width: 3, spacing: 3)))
    @State var liveConfigurationPlayback: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .white, width: 3, spacing: 3)))
    @Namespace var namespace
    
    @State private var player: AVPlayer?
    @State private var progress: Float = 0.0
    
    @State var showMediaPicker = false
    @FocusState var isFocused: Bool
    @State var isTyping = false
    
    var inbox: Inbox {
        return viewModel.inbox
    }
    
    var body: some View {
    
        VStack {
            if let reply = self.viewModel.reply {
                VStack(alignment: reply.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .trailing:.leading) {
                    HStack {
                        Text("Replying \((reply.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? "yourself":(self.inbox.members.first(where: {$0.id == reply.reply?.timestamp.profile.id })?.fullName ?? self.inbox.name)) )")
                            .font(.caption)
                            .italic()
                            .roundedFont()
                        //                            .updateTitle()
                        Spacer()
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    viewModel.reply = nil
                                }
                            }
                    }
                    ChatBubble(message: reply)
                        
                        .rotationEffect(.init(radians: .pi))
                }
                .padding(.horizontal)
            }
            HStack(spacing: 10) {
                if !audioRecorder.samples.isEmpty {
                    ZStack {
                        if let audioURL = audioRecorder.audioURL, !audioRecorder.isRecording {
                            ZStack {
                                WaveformView(audioURL: audioURL, configuration: liveConfiguration, priority: .high)
                                    .overlay {
                                        GeometryReader { proxy in
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .onAppear {
                                                    //                                                    SwiftUI.Task {
                                                    //                                                        let waveformImageDrawer = WaveformImageDrawer()
                                                    ////
                                                    //                                                        let image = try await waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: liveConfigurationPlayback)
                                                    ////                                                        // need to jump back to main queue
                                                    DispatchQueue.main.async {
                                                        audioPlayerManager.initializePlayer(audioURL)
                                                        let media = prema.Media(id: "audio-note", audioURLString: audioURL.absoluteString)
                                                        viewModel.media = [media]
                                                    }
                                                    //                                                    }
                                                }
                                            
                                        }
                                    }
                                WaveformView(audioURL: audioURL, configuration: liveConfigurationPlayback, priority: .high)
                                    .mask(alignment: .leading) {
                                        GeometryReader { geometry in
                                            Rectangle()
                                                .frame(width: geometry.size.width * CGFloat(audioPlayerManager.progress))
                                                .animation(.linear(duration: 0.1), value: audioPlayerManager.progress)
                                        }
                                    }
                                    .overlay {
                                        GeometryReader { geometry in
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .onTapGesture(coordinateSpace: .global) { location in                                                        print("\n\n\n\n touching: \(location)\n\n\n\n")
                                                    audioPlayerManager.seek(to: location.x / geometry.size.width)
                                                }
                                        }
                                    }
                                //                                        .onTapGesture { location in
                                //                                            audioPlayerManager.seek(to: location)
                                //                                            }
                            }
                            .frame(height: 40)
                            .onAppear {
                                print("showing this")
                            }
                        } else {
                            WaveformLiveCanvas(
                                samples: audioRecorder.samples,
                                configuration: liveConfiguration,
                                shouldDrawSilencePadding: true
                            )
                            .frame(height: 40)
                        }
                        HStack {
                            if !audioRecorder.isRecording {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 24))
                                    .shadow(color: .background, radius: 10, x: 0, y: 0)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            viewModel.media.removeAll()
                                            self.audioRecorder.removeRecording()
                                        }
                                    }
                            }
                            Spacer()
                            HStack {
                                if audioRecorder.isRecording {
                                    Text(audioRecorder.recordingTime.chatTime)
                                        .font(.system(size: 22))
                                        .shadow(color: .background, radius: 10, x: 0, y: 0)
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 24))
                                        .shadow(color: .background, radius: 10, x: 0, y: 0)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                self.audioRecorder.isRecording = false
                                            }
                                        }
                                } else {
                                    Image(systemName: self.audioPlayerManager.isPlaying ? "pause.fill":"play.fill")
                                        .font(.system(size: 24))
                                        .shadow(color: .background, radius: 10, x: 0, y: 0)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                self.audioPlayerManager.isPlaying = !self.audioPlayerManager.isPlaying
                                            }
                                        }
                                    ChatSendButton
                                        .matchedGeometryEffect(id: "send", in: namespace)
                                    
                                }
                            }
                        }
                        .padding()
                        //                        .background(LinearGradient(gradient: .init(stops:
                        //                                                                    [.init(color: .background,
                        //                                                                           location: 0),
                        //                                                                     .init(color: .background.opacity(0.5),
                        //                                                                           location: 0.2),
                        //                                                                     .init(color: .background.opacity(0),
                        //                                                                           location: 0.3),
                        //                                                                     .init(color: .background.opacity(0),
                        //                                                                           location: 0.7),
                        //                                                                     .init(color: .background.opacity(0.5),
                        //                                                                           location: 0.8),
                        //                                                                     .init(color: .background.opacity(1),
                        //                                                                           location: 1)
                        //                                                                    ]), startPoint: .leading, endPoint: .trailing))
                        
                    }
                } else {
                    HStack {
                        if viewModel.text.isEmpty {
                            ChatInputOptionsView
                        }
                        TextField("Good morning", text: $viewModel.text, axis: .vertical)
                            .lineLimit(10)
                            .onChange(of: viewModel.text, { _, t in
                                withAnimation(.spring()) {
                                    viewModel.text = t
                                }
                            })
                            .focused($isFocused)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .overlay {
                                HStack {
                                    Divider()
                                    Spacer()
                                }
                                .padding(.horizontal, -10)
                            }
                        ChatSendButton
                            .matchedGeometryEffect(id: "send", in: namespace)
                    }
                    .horizontalPadding(5)
                }
            }
            .verticalPadding(5)
            .horizontalPadding()
//            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 20, style: .continuous))
            .nonVibrantBlurBackground(cornerRadius: 20, colorScheme: colorScheme)
            .onChange(of: audioRecorder.isRecording) { _,newValue in
                if newValue {
                    liveConfiguration = Waveform.Configuration(
                        style: .striped(.init(color: .systemRed, width: 3, spacing: 3)))
                } else {
                    liveConfiguration = Waveform.Configuration(
                        style: .striped(.init(color: .systemBlue, width: 3, spacing: 3)))
                }
            }
            .onChange(of: viewModel.text) { statusObserver.handleTyping($0, inbox: inbox)
            }
            .onAppear {
                statusObserver.handleInChat(bool: true, inbox: inbox)
            }
            .onDisappear {
                statusObserver.handleInChat(bool: false, inbox: inbox)
            }
            .onChange(of: viewModel.reply) { _,newValue in
                
                self.isFocused = newValue != nil
                
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    statusObserver.handleInChat(bool: true, inbox: inbox)
                } else if newPhase == .inactive {
                    print("Inactive")
                    statusObserver.handleInChat(bool: false, inbox: inbox)
                    AccountManager.shared.updateInboxStatus(to: [inbox], typing: false)
                } else if newPhase == .background {
                    statusObserver.handleInChat(bool: false, inbox: inbox)
                    AccountManager.shared.updateInboxStatus(to: [inbox], typing: false)
                }
            }
            .contextMenu {
                Button("Regular") {
                    viewModel.currentChatMode = .regular
                }
                Button("Sensitive") {
                    viewModel.currentChatMode = .sensitive
                }
                Button("Destructive") {
                    viewModel.currentChatMode = .destructive
                }
            }

        }
        .horizontalPadding()
        .bottomPadding(safeAreaInsets.bottom)
        .keyboardAware()
        .sheet(isPresented: $viewModel.showingStickerView) {
            ChatFunCenterView()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(25)
                .presentationBackground(.thinMaterial)
        }
            
    }
   
    
    var ChatInputOptionsView: some View {
        HStack(spacing: 5) {
            /*
            Image(systemName: "camera.fill")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 40, height: 40)
             */
            //                .background(Blur())
            //                .cornerRadius(10)
            //                .shadow(color: .shadow, radius: 4, x: 2, y: 2)
            Image(systemName: "face.smiling.fill")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.showingStickerView.toggle()
                }
            //                .background(Blur())
            //                .cornerRadius(10)
            //                .shadow(color: .shadow, radius: 4, x: 2, y: 2)
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .onTapGesture {
                    showMediaPicker.toggle()
                }
                .showMediaPicker(isPresented: $showMediaPicker, type: .direct) { media in
                    viewModel.media = media
                    viewModel.sendMessage()
                }
            //                .background(Blur())
            //                .cornerRadius(10)
            //                .shadow(color: .shadow, radius: 4, x: 2, y: 2)
        }
    }
    @State var shouldScale = false
    
    var imageName: String {
        if viewModel.text.isEmpty && audioRecorder.samples.isEmpty {
            return "waveform.and.mic"
        } else {
            return "paperplane.fill"
        }
    }
    
    var buttonColors: [Color] {
        return viewModel.currentChatMode == .regular ? AppearanceManager.shared.currentTheme.vibrantColors:viewModel.currentChatMode == .sensitive ? [.black]:[.red, .red]
    }
    
    var ChatSendButton: some View {
        ZStack {
            Image(systemName: imageName)
                .font(.system(size: 17, weight: .bold))
        }
        .padding(.horizontal, 7)
        .padding(8)
        .foregroundColor(.white)
        .background(.linearGradient(colors: buttonColors, startPoint: .topLeading, endPoint: .bottom))
        .clipShape(.capsule)
        .shadow(color: Color("Shadoww"), radius: 10, x: 2, y: 2)
        .scaleEffect(shouldScale ? 0.8:1)
        .animation(.spring(response: 0.2), value: shouldScale)
        
        .onTapGesture {
            shouldScale.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                shouldScale.toggle()
            }
            if !audioRecorder.isRecording && audioRecorder.samples.isEmpty && viewModel.text.isEmpty {
                withAnimation(.spring()) {
                    audioRecorder.isRecording = true
                }
            } else {
                viewModel.sendMessage()
                audioRecorder.removeRecording()
            }
        }
    }
    
}

struct CreateStickerView: View {
    @StateObject var viewModel = CreateStickerViewModel()
    @Environment (\.dismiss) var dismiss
    @Environment (\.colorScheme) var colorScheme

    var inboxID: String
    var body: some View {
        GeometryReader {
            let size = $0.size
        VStack {
            HStack {
                DismissButton {
                    dismiss()
                }
                Spacer()
                Text("Create Sticker")
                    .font(.largeTitle.bold())
                    .roundedFont()
            }
            Spacer()
            
            TextField("Name you ssticker", text: $viewModel.text)
                .font(.system(.title2, design: .rounded, weight: .medium))
//            
            Spacer()
            ZStack {
                if let image = viewModel.fetchedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.clear.background(.regularMaterial)
                    VStack {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .opacity(0.2)
                            .frame(width: size.width * 0.7, height: size.width * 0.7)
                    }
                }
            }
            .frame(width: size.width - 40, height: size.width - 40)
            .cornerRadius(20)
//            .shadow(color: .shadow, radius: 10, x: 0, y: 0)
            .onTapGesture {
                viewModel.showPicker.toggle()
            }
            Spacer()
            if viewModel.fetchedImage != nil {
                Button {
                    viewModel.removeBackground()
                } label: {
                    Text("Remove Background")
                        .foregroundColor(.red)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(20)
                }
            }
            Spacer()
            Button {
                viewModel.uploadSticker(inbox: inboxID) { _ in
                    dismiss()
                }
            } label: {
                Text("Done")
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .vibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
            }
            .opacity(viewModel.fetchedImage != nil && !viewModel.text.isEmpty ? 1:0.6)
            .disabled(!(viewModel.fetchedImage != nil && !viewModel.text.isEmpty))
        }
        .padding()
        .showMediaPicker(isPresented: $viewModel.showPicker, type: .profile_avatar) { media in
            self.viewModel.fetchedImage = media.first?.uiImage
        }
        }
    }
}

class AudioPlayeViewModel: ObservableObject {
  let player: AVPlayer
    private var timeObserver: Any?
    @Published var duration: TimeInterval = 0
      @Published var currentTime: TimeInterval = 0
    
  init(url: URL) {
    self.player = AVPlayer()
//      setupPlayer()
  }
    
    private func setupPlayer() {
           // Configure the player
           
           // Update the duration and current time
           duration = player.currentItem?.asset.duration.seconds ?? 0
           currentTime = player.currentTime().seconds ?? 0
           
           // Add a periodic time observer to update the current time
           timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: .main) { [weak self] time in
               self?.currentTime = time.seconds
           }
       }
  
  func pause(_ flag: Bool) {}
    
    func play() {
            player.play()
        }
        
        func pause() {
            player.pause()
        }
        
        func seek(to percentage: Float) {
            let newTime = CMTime(seconds: duration * Double(percentage), preferredTimescale: 1000)
            player.seek(to: newTime) { bool in
                self.play()
            }
        }
    
}

class PlayerDurationObserver {
  let player: AVPlayer
  
  init(player: AVPlayer) {
    self.player = player
  }
}

class PlayerItemObserver {
  let player: AVPlayer
  init(player: AVPlayer) {
    self.player = player
  }
}

let player = AVPlayer()
// MARK: DIVISION
enum Utility {
  static func formatSecondsToHMS(_ seconds: TimeInterval) -> String {
    let secondsInt:Int = Int(seconds.rounded(.towardZero))
    
    let dh: Int = (secondsInt/3600)
    let dm: Int = (secondsInt - (dh*3600))/60
    let ds: Int = secondsInt - (dh*3600) - (dm*60)
    
    let hs = "\(dh > 0 ? "\(dh):" : "")"
    let ms = "\(dm<10 ? "0" : "")\(dm):"
    let s = "\(ds<10 ? "0" : "")\(ds)"
    
    return hs + ms + s
  }
}

struct AudioPlayerControlsView: View {
  private enum PlaybackState: Int {
    case waitingForSelection
    case buffering
    case playing
  }
  
  let player: AVPlayer
  @ObservedObject var viewModel: AudioPlayeViewModel
  let durationObserver: PlayerDurationObserver
  let itemObserver: PlayerItemObserver
    
    var audioURL: URL
  @State private var currentTime: TimeInterval = 0
  @State private var currentDuration: TimeInterval = 0
  @State private var state = PlaybackState.playing
  
    var body: some View {
        SliderX()
            .environmentObject(viewModel)
   
            .padding(.horizontal, -20)
            .padding(.vertical, -10)
            
    }

  // MARK: Private functions
  private func sliderEditingChanged(editingStarted: Bool) {
      
    if editingStarted {
      // Tell the PlayerTimeObserver to stop publishing updates while the user is interacting
      // with the slider (otherwise it would keep jumping from where they've moved it to, back
      // to where the player is currently at)
//      timeObserver.pause(true)
    }
    else {
      // Editing finished, start the seek
      state = .buffering
        let targetTime: Float = Float(CMTime(seconds: currentTime, preferredTimescale: 600).seconds / viewModel.duration)
//      player.seek(to: targetTime) { _ in
//        // Now the (async) seek is completed, resume normal operation
////        self.timeObserver.pause(false)
//        self.state = .playing
//
//      }
        viewModel.seek(to: targetTime)

    }
  }
     
}
struct SliderX: View {

    @EnvironmentObject var viewModel: AudioPlayeViewModel
    @State var isDragging = false
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                Rectangle()
                    .foregroundStyle(Color.vibrant)
                    .frame(width: geometry.size.width * CGFloat(self.viewModel.currentTime / viewModel.duration))
                ZStack {
                    Label("Voice Note", systemImage: "waveform.and.mic")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.3)
                        .align(.center)
                    
                    HStack {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.play()
                            }
                        Text(viewModel.currentTime.chatTime)
                            .font(.caption)
                        Spacer()
                        Text(viewModel.duration.chatTime)
                            .font(.caption)
//                            .timestamp()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
            }
            .cornerRadius(12)
            .animation(.linear(duration: isDragging ? 0:1), value: viewModel.currentTime)
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    // TODO: - maybe use other logic here
                    self.isDragging = true
                    self.viewModel.pause()
                    self.viewModel.seek(to: Float(value.location.x / geometry.size.width))
                }).onEnded({ _ in
                    self.isDragging = false
                    self.viewModel.play()
                }))
        }
    }
}


struct ChatTextField: View {
    
    @StateObject var directManager: DirectManager = .shared
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @EnvironmentObject var viewModel: ChatManager
    @EnvironmentObject var appearance: AppearanceManager
    @State var showChatDetail = false
    @EnvironmentObject var statusViewModel: ActivityStatusManager
    var inbox: Inbox {
        return viewModel.inbox
    }
    @State var expand = false
    
    @State var selection = ""
    var body: some View {
        HStack {
     
            Spacer()
            VStack(alignment: .trailing) {
                HStack {
                    
                    HStack(spacing: 20) {
                        
                        Image(systemName: "video.fill")
                            .font(.title2)
                        Image(systemName: "phone.and.waveform.fill")
                            .font(.title2)
                        
                    }
                    .foregroundStyle(appearance.currentTheme.vibrantGradient)
                    Divider()
                        .frame(height: 20)
                        .horizontalPadding(4)
                    HStack {
                        VStack(alignment: .trailing) {
                            Text(inbox.name)
                                .bold()
                                .roundedFont()
                            if (inbox.isGroup &&  !statusViewModel.online.isEmpty || !statusViewModel.inChat.isEmpty || !statusViewModel.typing.isEmpty) || !inbox.isGroup {
                                Text("\(statusViewModel.statusText)")
                                    .font(.subheadline.italic())
                                    .bold()
                                    .roundedFont()
                                    .foregroundStyle(statusViewModel.statusColor)
                            }
                        }
                        ProfileImageView(avatarImageURL: inbox.avatar)
                            .frame(width: 40, height: 40)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        self.showChatDetail.toggle()
                    }
                    .sheet(isPresented: $showChatDetail) {
                        ChatDetailView(inbox: $viewModel.inbox)
                    }
                }
          
                
            }
            .verticalPadding(10)
            .horizontalPadding(20)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 24, style: .continuous))
            .shadow(color: Color("Shadoww"), radius: 20, x: 4, y: 10)
            .contextMenu {
                Button("chat") {
                    viewModel.selection = "chat"
                }
                Button("visions") {
                    viewModel.selection = "visions"
                }
       
            }
            .matchedGeometryEffect(id: "chatProfile-\(inbox.id)", in: NamespaceWrapper.shared.namespace!)
            
        }
        .topPadding(safeAreaInsets.top)
        .horizontalPadding()
        .onAppear {
            self.statusViewModel.getStatus(inbox: inbox)
        }
    }
}



extension Double {
    var date: Date {
        return Date(timeIntervalSince1970: self)
    }
}

extension View {
    func onScalingLongPress(perform action: @escaping () -> Void) -> some View {
        modifier(ScalingLongPressModifier(action: action))
    }
}

struct ScalingLongPressModifier: ViewModifier {
    @State private var longPressTask: SwiftUI.Task<Void, Never>?
    @State private var shouldScale: Bool = false
    var scaleWhenPressed: Double = 0.975
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(shouldScale ? scaleWhenPressed : 1.0)
            .onLongPressGesture(
                minimumDuration: 0.2,
                maximumDistance: 10,
                perform: {
                    // do nothing
                },
                onPressingChanged: { isPressing in
                    handlePressingChange(isPressing: isPressing)
                })
    }
    
    @MainActor
    private func handlePressingChange(isPressing: Bool) {
        if isPressing {
            longPressTask = SwiftUI.Task {
                // Wait and scale the view
                try? await SwiftUI.Task.sleep(nanoseconds: 200_000_000)
                
                guard !SwiftUI.Task.isCancelled else {
                    return
                }
                
                withAnimation(.spring()) {
                    shouldScale = true
                }
                
                // Wait and trigger the action
                try? await SwiftUI.Task.sleep(nanoseconds: 200_000_000)
                
                guard !SwiftUI.Task.isCancelled else {
                    return
                }
                
                action()
            }
        } else {
            longPressTask?.cancel()
            longPressTask = nil
            
            withAnimation(.spring()) {
                shouldScale = false
            }
        }
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}
