//
//  ChatView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/15/23.
//

import AVFoundation
import DSWaveformImage
import DSWaveformImageViews
import SwiftUI
import Combine

struct SelectedInbox: Identifiable {
    var id: String {
        return inbox.id
    }
    var inbox: Inbox
    var frame: CGRect
}

struct ChatView: View {
    
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Environment (\.colorScheme) var colorScheme
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var chatManager: ChatManager
    @Namespace var namespace
    init(inbox: Inbox) {
        self._chatManager = StateObject(wrappedValue: ChatManager(inbox))
    }
    var GodIsGood = true
    @State var headerFrame: CGRect = .zero
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
            
            ChatTopView() { frame in
                headerFrame = frame
            }
            //        .matchedGeometryEffect(id: "chatProfile-\(chatManager.inbox.id)", in: NamespaceWrapper.shared.namespace!)
            .environmentObject(chatManager)
            .scaleEffect(message == nil ? 0.4:1)
            .position(x: finalX, y:  finalY)
            .animation(.spring(), value: message)
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
            ZStack {
                MessagesView(namespace: _namespace)
                    .environmentObject(chatManager)
                    .opacity(chatManager.reply == nil ? 1:0.1)
                    .ignoresSafeArea()

            }
            .onTapGesture {
                withAnimation(.spring()) {
                    chatManager.selectedMessage = nil
                }
            }
                chatContextMenuAndHeader
                    .opacity(chatManager.reply == nil ? 1:0.1)
                    .opacity(chatManager.selectedMessage == nil ? 0:1)
            VStack {
                if chatManager.selectedMessage == nil {
                    ChatTextField(inbox: chatManager.inbox)
                        .environmentObject(appearance)
//                        .matchedGeometryEffect(id: "chatProfile-\(chatManager.inbox.id)", in: NamespaceWrapper.shared.namespace!)
                }
                
                Spacer()
     
                ChatInputView(inbox: chatManager.inbox)
                    .ignoresSafeArea()
                }
            .ignoresSafeArea()
       
        }
        .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
        .ignoresSafeArea()
    }
}


struct MessagesView: View {
    
    @EnvironmentObject var chatManager: ChatManager
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @Namespace var namespace
    
    var body: some View {
        GeometryReader { proxy in
            List {
                LazyVStack {
                    ForEach(chatManager.messages) { message in
                        ChatBubble(message: message, namespace: _namespace)
                            .matchedGeometryEffect(id: "chat-bubble-\(message.id)", in: namespace)
                            .horizontalPadding(-20)
                            .listRowBackground(Color.clear)
                    }
                }
                .listRowBackground(Color.clear)
                .padding(.top, safeAreaInsets.top + 50)
                .padding(.bottom, 50)
            }
            .scrollDismissesKeyboard(.immediately)
            .rotationEffect(Angle(degrees: 180))
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .keyboardAware()
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
    
}

struct ChatBubble: View {
    @EnvironmentObject var appearance: AppearanceManager
    @Environment (\.colorScheme) var colorScheme
    @ObservedObject var message: Message
    @StateObject private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    @EnvironmentObject var viewModel: ChatManager
    @Namespace var namespace
    var type: MessageType {
        return message.type
    }
    
    var showRecentTimestamp: Bool {
        if let firstIndex = viewModel.messages.firstIndex(of: message), firstIndex != (viewModel.messages.count - 1) {
            if message.timestamp.time - viewModel.messages[firstIndex + 1].timestamp.time < 300 {
                return false
            }
        }
        return true
    }
    @State var isLongPressing = false
    var body: some View {
        VStack {
            
            if showRecentTimestamp && !message.isReply {
                Text(message.timestamp.time.chatTime)
                    .font(.caption)
                    .opacity(viewModel.selectedMessage == nil ? 1:0.1)
                
            }
          
            HStack {
                if message.timestamp.profile.id == AccountManager.shared.currentProfile?.id && !message.isReply {
                    Spacer(minLength: 0.25 * appearance.size.width)
                }
                
                
               
                VStack(alignment: message.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .trailing:.leading) {
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
                                Text(message.text ?? "")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(message.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .white:.primary)
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
                                            }
//                                            .frame(width: (appearance.size.width - 40) * 0.75 * media[i].ratio,
//                                                   height: (appearance.size.width - 40) * 0.75)
                                            .cornerRadius(20)
                                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                                            .padding(-20)
                                            //                                        .offset(x: -i * 5, y: -i * 5)
                                        }
                                    }
                                    
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
                    .padding(.vertical ,message.type == .sticker ? 0:10)
                    .padding(.horizontal, message.type == .sticker ? 0:20)
                    .background(BubbleBackground.opacity(message.type == .sticker ? 0:1))
                    .cornerRadius(22)
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
                    .simultaneousGesture(LongPressGesture().onEnded({ _ in
                        self.isLongPressing.toggle()
                    }))
                    .opacity(viewModel.selectedMessage == nil ? 1:viewModel.selectedMessage != message ? 0.1:1)
           
                    if viewModel.messages.first?.id == message.id && message.timestamp.profile.id == AccountManager.shared.currentProfile?.id  && !message.isReply {
                        Text(message.timestamp.time.chatTime)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .opacity(viewModel.selectedMessage == nil ? 1:0.1)
                    }
            
                }
                
                
                if message.timestamp.profile.id != AccountManager.shared.currentProfile?.id && !message.isReply {
                    Spacer(minLength: 0.25 * appearance.size.width)
                }
            }
      
        }
        .rotationEffect(Angle(degrees: 180))
        .opacity(message.isSent ? 1:0.5)
    }
    
    var fromColors: [Color] {
        let isSensitive = message.expiry != nil
        let isDestructive = message.destruction != nil
        return isDestructive ? [.red, .red]:isSensitive ? [.indigo, .purple]:AppearanceManager.shared.currentTheme.vibrantColors
    }
    
    var toColors: [Color] {
        let isSensitive = message.expiry != nil
        let isDestructive = message.destruction != nil
        return isDestructive ? [.red, .red]:isSensitive ? [.indigo, .purple]:[.secondary.opacity(0.1), .secondary.opacity(0.2)]
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
    
    var TextMessage: some View {
        Text(message.text ?? "")
            .font(.system(size: 15, design: .rounded))
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
//                .onAppear {
//                    print("yeet audio appeared: \(audioURL)")
//                    let playerItem = AVPlayerItem(url: audioURL)
//                    player.replaceCurrentItem(with: playerItem)
//                    player.play()
//                }
//                .simultaneousGesture(TapGesture().onEnded  {
//                    print("yeet audio clicked: \(audioURL)")
//                    let playerItem = AVPlayerItem(url: audioURL)
//                    player.replaceCurrentItem(with: playerItem)
//                    player.play()
//                })
            }
            //                                        .onTapGesture { location in
            //                                            audioPlayerManager.seek(to: location)
            //                                            }
        }
        .frame(height: 40)
    }
}

struct ChatFunCenterView: View {
    @Environment (\.colorScheme) var colorScheme
    @StateObject var directViewModel = DirectManager.shared
    @EnvironmentObject var viewModel: ChatManager
    
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
//                            NavigationManager.shared.path.append("create-sticker")
                        }
                    DismissButton {
                        viewModel.showingStickerView.toggle()
                    }
                }
                 /*
                Divider()
                if directViewModel.stickers.isEmpty {
                    ContentUnavailableView {
                        Color.clear
//                        EmptyPostsView(message: "")
                    } description: {
                        Text("No Stickers in this chat")
                    } actions: {
                        
                        Button("Create") {
                            NavigationManager.shared.path.append("create-sticker")
                        }
                    }

                } else {
                    
                    ScrollView {
                        LazyVGrid(columns: [.init(.flexible(), spacing: 5),
                                            .init(.flexible(), spacing: 5),
                                            .init(.flexible(), spacing: 5)]) {
                                                ForEach(directViewModel.stickers) { sticker in
                                                    
                                                    ImageX(sticker.imageURL)
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
                  */
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

struct ChatTopView: View {
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
//    @StateObject var statusViewModel = ActivityStatusViewModel()
    
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
                                        .font(.system(size: 40))
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
                                            .font(.system(size: 40))
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
                                        
                                        self.viewModel.reply = self.viewModel.selectedMessage
                                        viewModel.selectedMessage = nil
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
        .onAppear {
//            self.statusViewModel.getStatus(inbox: viewModel.inbox)
        }
    }
    
}

struct ChatInputView: View {
    
    @State var showAllOptions = false
    @StateObject var viewModel: ChatManager
    @Environment (\.safeAreaInsets) var safeAreaInsets

    @StateObject private var audioRecorder: AudioRecorder = AudioRecorder()
    @StateObject private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
//    @StateObject private var statusObserver = TypingObserver()

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
    
    init(inbox: Inbox) {
        self._viewModel = StateObject(wrappedValue: ChatManager(inbox))
        
    }
    
    var body: some View {
    
            if let reply = viewModel.reply {
                VStack(alignment: reply.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? .trailing:.leading) {
                    HStack {
                        Text("Replying \((reply.timestamp.profile.id == AccountManager.shared.currentProfile?.id ? "yourself":(self.viewModel.inbox.members.first(where: {$0.id == reply.reply?.timestamp.profile.id })?.fullName ?? self.viewModel.inbox.name)) ?? "")")
//                            .updateTitle()
                        Spacer()
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
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
                                                    let waveformImageDrawer = WaveformImageDrawer()
                                                    waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: liveConfigurationPlayback) { image in
                                                        // need to jump back to main queue
                                                        DispatchQueue.main.async {
                                                            audioPlayerManager.initializePlayer(audioURL)
//                                                            let media = prema.Media(id: "audio-note", audioURLString: audioURL.absoluteString, uiImage: image)
//                                                            viewModel.media = [media]
                                                        }
                                                    }
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
                        ChatInputOptionsView
                        TextField("Good morning", text: $viewModel.text, axis: .vertical)
                            .lineLimit(10)
                            .focused($isFocused)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
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
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 20, style: .continuous))
//            .background {
//                TransparentBlurView(removeAllFilters: true)
//                    .blur(radius: 3, opaque: false)
//                    .padding([.horizontal, .top], -6)
//            }
            .onChange(of: audioRecorder.isRecording) { newValue in
                if newValue {
                    liveConfiguration = Waveform.Configuration(
                        style: .striped(.init(color: .systemRed, width: 3, spacing: 3)))
                } else {
                    liveConfiguration = Waveform.Configuration(
                        style: .striped(.init(color: .systemBlue, width: 3, spacing: 3)))
                }
            }
//            .onChange(of: viewModel.text) { statusObserver.handleTyping($0, inbox: viewModel.inbox)
//            }
//            .onAppear {
//                statusObserver.handleInChat(bool: true, inbox: viewModel.inbox)
//            }
//            .onDisappear {
//                statusObserver.handleInChat(bool: false, inbox: viewModel.inbox)
//            }
            .onChange(of: viewModel.reply) { newValue in
                
                    self.isFocused = newValue != nil
                
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
            Image(systemName: "camera.fill")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 40, height: 40)
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
        return viewModel.currentChatMode == .regular ? [.teal, .blue]:viewModel.currentChatMode == .sensitive ? [.indigo, .purple]:[.red, .red]
    }
    
    var ChatSendButton: some View {
        ZStack {
            Image(systemName: imageName)
                .font(.system(size: 17, weight: .bold))
        }
        .padding(.horizontal, 7)
        .padding(8)
        .foregroundColor(.white)
        .background(Color.vibrant)
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
/*
struct CreateStickerView: View {
//    @StateObject var viewModel = CreateStickerViewModel()
    @Environment (\.dismiss) var dismiss
    
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
                    .largeTitle()
            }
            Spacer()
            
//            TextField("Name you ssticker", text: $viewModel.text)
//                .font(.system(.title2, design: .rounded, weight: .medium))
            
            Spacer()
            ZStack {
//                if let image = viewModel.fetchedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFill()
//                } else {
                    Color.clear.background(.regularMaterial)
                    VStack {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .opacity(0.2)
                            .frame(width: size.width * 0.7, height: size.width * 0.7)
                    }
//                }
            }
            .frame(width: size.width - 40, height: size.width - 40)
            .cornerRadius(20)
            .shadow(color: .shadow, radius: 10, x: 0, y: 0)
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
*/

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
    var inbox: Inbox
    @StateObject var directManager: DirectManager = .shared
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @EnvironmentObject var viewModel: ChatManager
    @EnvironmentObject var appearance: AppearanceManager
    @State var expand = false
    var body: some View {
        HStack {
     
            Spacer()
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
                VStack(alignment: .trailing) {
                    Text(inbox.name)
                        .bold()
                        .roundedFont()
                    Text("offline")
                        .font(.subheadline.italic())
                        .bold()
                        .roundedFont()
                        .foregroundStyle(.secondary)
                }
                ProfileImageView(avatarImageURL: inbox.avatar)
                    .frame(width: 40, height: 40)
            }
            .verticalPadding(10)
            .horizontalPadding(20)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 24, style: .continuous))
            .shadow(color: Color("Shadoww"), radius: 20, x: 4, y: 10)
            .contextMenu {
                Button("Regular") {
                    viewModel.currentChatMode = .regular
                    withAnimation(.spring()) {
                        expand.toggle()
                    }
                }
                Button("Sensitive") {
                    viewModel.currentChatMode = .sensitive
                    withAnimation(.spring()) {
                        expand.toggle()
                    }
                }
                Button("Destructive") {
                    viewModel.currentChatMode = .destructive
                    withAnimation(.spring()) {
                        expand.toggle()
                    }
                }
            }
            .matchedGeometryEffect(id: "chatProfile-\(inbox.id)", in: NamespaceWrapper.shared.namespace!)
            
        }
        .topPadding(safeAreaInsets.top)
        .horizontalPadding()
    }
}



extension Double {
    var date: Date {
        return Date(timeIntervalSince1970: self)
    }
}
