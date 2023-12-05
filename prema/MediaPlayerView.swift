//
//  MediaPlayerView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 12/3/23.
//

import AVFoundation
import VideoPlayer
import SwiftUI

struct MediaPlayerView: View {
    
    var media: [Media]
//    @State var selection: Media?
    var body: some View {
        
            TabView {
                ForEach(media) { media in
                    switch media.type {
                    case .image:
                        ImageViewerView(media: media)
                    case .video:
                        VideoPlayerView(media: media)
                    default:
                        Color.clear
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 22, style: .continuous))
            .clipped()
            .onAppear {
                VideoPlayer.preload(urls: media.filter {$0.type == .video }.map { $0.videoURLString?.url ?? URL(string: "google.com")! })
            }
        
        
        
    }
}

struct ImageViewerView: View {
    var media: Media
    @State var showControls = true
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            ImageX(urlString: media.imageURLString)
            VStack {
                HStack {
                    Spacer()
                    DismissButton {
                        withAnimation(.spring()) {
                            NavigationManager.shared.media = nil
                        }
                    }
                }
                Spacer()
//                HStack {
//                    Image(systemName: "play.fill")
//                        .font(.largeTitle.bold())
//                        .foregroundStyle(.white)
//                    Spacer()
//                    Button {
//                        play.toggle()
//                    } label: {
//                        Image(systemName: play ? "pause.fill":"play.fill")
//                            .font(.largeTitle.bold())
//                            .foregroundStyle(.white)
//                    }
//                    Spacer()
//                    Button {
//                        media.downloadToPhotoLibrary()
//                    } label: {
//                        Image(systemName: "square.and.arrow.down.fill")
//                            .font(.title.bold())
//                            .foregroundStyle(.white)
//                    }
//                    .foregroundStyle(.white)
//                }
            }
            .background(.linearGradient(colors: [.black, .black.opacity(0), .black.opacity(0), .black.opacity(0), .black], startPoint: .top, endPoint: .bottom))
            .contentShape(.rect)
            .opacity(showControls ? 1:0)
            
        }
        .onTapGesture {
            withAnimation {
                showControls.toggle()
            }
        }
    }
}

struct VideoPlayerView: View {
    
    var media: Media
    
    @State var play = false
    @State var time: CMTime = .zero
    
    @State var autoReplay = true
    @State var mute = false
    
    @State var isLoading = true
    @State var isPaused = true
    @State var totalDuration: Double = .zero
    @State var currentDuration: Float = .zero

    @State var bufferProgress: Double = .zero
    @State var playProgress: Double = .zero

    @State var error: String?

    @State var showControls = true
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            if let url = media.videoURLString?.url {
                VideoPlayer(url: url, play: $play, time: $time)
                    .autoReplay(autoReplay)
                    .mute(mute)
                    .onBufferChanged { progress in
                        // Network loading buffer progress changed
                    }
                    .onPlayToEndTime {
                        // Play to the end time.
                    }
                    .onReplay {
                        // Replay after playing to the end.
                    }
                    .onStateChanged { state in
                        switch state {
                        case .loading:
                            isLoading = true
                        case .playing(let totalDuration):
                            self.totalDuration = totalDuration
                            isLoading = false
                            isPaused = true
                        case .paused(let playProgress, let bufferProgress):
                            self.playProgress = playProgress
                            self.bufferProgress = bufferProgress
                            if bufferProgress == 1 {
                                self.play.toggle()
                            }
                        case .error(let error):
                            self.error = error.localizedDescription
                        }
                    }
                    .onChange(of: time, perform: { time in
                        currentDuration = Float(time.seconds) / Float(totalDuration)
                    })
            }
            if isLoading {
                SpinnerView()
            }
            VStack {
                HStack {
                    Text("\(currentDuration.durationTime)")
                    CustomSliderView(percentage: $currentDuration) {
                        self.play = false
                    } onEnded: {
                        self.play = true

                    }
                    .frame(height: 20)
                        .onChange(of: currentDuration) { _,val in
                            if !play {
                                self.time = CMTimeMakeWithSeconds(max(0, Double(val)), preferredTimescale: self.time.timescale)
                            }
//                        if val {
//                          play = false
//                          let tm = Double(currentDuration)
//                          self.time = CMTimeMakeWithSeconds(max(0, tm), preferredTimescale: self.time.timescale)
//                        } else {
//                          // user is done sliding so play movie at point he/she slid to
//                          let tm = Double(currentDuration)
//                          self.time = CMTimeMakeWithSeconds(max(0, tm), preferredTimescale: self.time.timescale)
//                          DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                          play = true
//                          }
//                        }
                      }
                    Text("\(time.durationTime)")
                    DismissButton {
                        withAnimation(.spring()) {
                            NavigationManager.shared.media = nil
                        }
                    }
                }
                Spacer()
                HStack {
                    Button {
                        mute.toggle()
                    } label: {
                        Image(systemName: mute ? "speaker.wave.1.fill":"speaker.slash.fill")
                            .font(.title2.bold())
                    }
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        play.toggle()
                    } label: {
                        Image(systemName: play ? "pause.fill":"play.fill")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Button {
                        media.downloadToPhotoLibrary()
                    } label: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding(10)
            .background(.linearGradient(colors: [.black, .black.opacity(0), .black.opacity(0), .black.opacity(0), .black], startPoint: .top, endPoint: .bottom))
            .opacity(showControls ? 1:0)
        }
        .contentShape(.rect)
        .simultaneousGesture(TapGesture().onEnded { _ in
            withAnimation {
                showControls.toggle()
            }
        })
                             
    }
}

extension TimeInterval {
    var hours:  Int { return Int(self / 3600) }
    var minute: Int { return Int(self.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(self.truncatingRemainder(dividingBy: 60)) }
    var durationTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}

extension Float {
    var hours:  Int { return Int(self / 3600) }
    var minute: Int { return Int(self.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(self.truncatingRemainder(dividingBy: 60)) }
    var durationTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}

extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var durationTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}

struct CustomSliderView: View {

    @Binding var percentage: Float // or some value binded

    var onStart: () -> ()
    var onEnded: () -> ()
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100))
            }
            .cornerRadius(12)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    onStart()
                    // TODO: - maybe use other logic here
                    self.percentage = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                })
            .onEnded { _ in
                onEnded()
            })
        }
    }
}
