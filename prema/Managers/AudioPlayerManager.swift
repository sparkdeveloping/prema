//
//  AudioPlayer.swift
//  Elixer
//
//  Created by Denzel Nyatsanza on 1/1/23.
//

import AVFoundation
import SwiftUI

class AudioPlayerManager: ObservableObject {
    
    @Published var player: AVPlayer?
    @Published var progress: Float = 0
    
    @Published var isPlaying: Bool = false {
        didSet {
            guard oldValue != isPlaying else { return }
            if isPlaying {
                playAudio()
            } else {
                pauseAudio()
            }
        }
    }

    func initializePlayer(_ url: URL) {
        self.player = AVPlayer(url: url)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        _ = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let duration = self.player?.currentItem?.duration
            self.progress = Float(time.seconds / (duration?.seconds ?? 1))
            print("\n\n\n\n\n progress - \(self.progress) \n\n\n\n\n")
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(self.playerDidFinishPlaying),
                             name: .AVPlayerItemDidPlayToEndTime,
                             object: self.player?.currentItem
                )
        }
    }
    
    @objc func playerDidFinishPlaying() {
        self.player?.seek(to: .zero)
        self.progress = 0
        self.isPlaying = false
    }
    
    func playAudio() {
        self.player?.play()
    }
    
    func pauseAudio() {
        self.player?.pause()
    }
    
    func seek(to: Double) {
        let duration = self.player?.currentItem?.duration ?? .zero
        let seekTime = CMTimeMultiplyByFloat64(duration, multiplier: to)
        self.player?.seek(to: seekTime)
        self.progress = Float(to)
        self.isPlaying = true
    }
    
}
