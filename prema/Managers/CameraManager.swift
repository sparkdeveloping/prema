//
//  Camera_ViewModel.swift
//  Elixer
//
//  Created by Denzel Anderson on 5/29/22.
//

import AVFoundation
import Photos
import SwiftUI
import UIKit
import ARVideoKit
import ARKit

enum CaptureMode {
    case normal
}
struct EditClip: Identifiable {
    var id: String {
        return media.id
    }
    var media: Media
    var overlay: AnyView
}
enum PostMediaPreference {
    case stack, single
}
class CameraManager: ObservableObject {
    
    
    
    var arView = ARSCNView()
    
    var manager = CameraOperationManager()
    
    let context = CIContext()
    
    @Published var currentClipDuration: Double = 0
    //    @Published var captureModes: [CaptureMode] = []
    //    @Published var currentFilter: ARObject?
    @Published var changingModes = false {
        didSet {
            //            if !changingModes {
            //                updateNodes()
            //            }
        }
    }
    @Published var currentCaptureMode: CaptureMode = .normal
    @Published var selectedModeIndex = 0
    @Published var isRecording = false
    @Published var recordingComplete = false
    @Published var goToEditor = false
    
    @Published var variationIndex = 0
    @Published var maxQuickieDuration: Double = 15 {
        didSet {
            self.manager.maxRecordingDuration = maxQuickieDuration
        }
    }
    @Published var currentProgress: Double = 0
    @Published var speed: Double = 1
    @Published var timer: Double = 0
    @Published var allowAudioInput = true
    
    @Published var currentNode = SCNNode()
    @Published var previewImage: UIImage?
    
    
    @Published var showAudioPanel =  false
    @Published var flashImage = Image("flash")
    @Published var swappingCamera = false
    @Published var useMulticapture = false
    @Published var useGrid = false
    @Published var expandSpeedOptions = false
    @Published var expandTimerOptions = false
    @Published var showGalleryPanel = false
    @Published var progresses: [Float] = []
    
    @Published var clips: [EditClip]?
    
    func reset(_ clips: [EditClip]) {
        if currentCaptureMode == .normal {
            self.clips?.removeAll()
            self.isRecording = false
            self.manager.resetManager()
        } else {
            self.clips = clips
            if let clips = self.clips  {
                self.manager.clips = clips
            }
        }
        goToEditor.toggle()
        
    }
    
    init() {
        configure()
    }
    
    func configure() {
        manager.configure(self.arView)
        manager.delegate = self
        manager.maxRecordingDuration = maxQuickieDuration
        manager.fetchPhotos { image in
            self.previewImage = image
        }
    }
    
    func startPreview() {
        self.manager.startPreview()
    }
    
    func pausePreview() {
        self.manager.pausePreview()
    }
    
    func takePhoto() {
        manager.capturePhoto()
    }
    
    func takeVideo() {
        manager.startRecording()
    }
    
    func pauseVideo() {
        manager.pauseRecording()
    }
    func swapCamera() {
        SwiftUI.Task {
            await manager.flipDevicePosition()
        }
    }
    
    
}

extension CameraManager: CameraOperationManagerDelegate {
    
    func managerDidCapturePhoto(clips: [EditClip]) {
        DispatchQueue.main.async {
            if self.currentCaptureMode == .normal {
                self.clips = clips
                self.goToEditor = true
            } else {
                
            }
        }
    }
    
    func manager(didStartRecording: Bool) {
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.isRecording = true
            }
            print("\n\n\n\n\n\n\n\n\n\n\n YOU'D BE SHOCKED, WE ARE SENDING ALERTS INDEED: \(self.isRecording) \n\n\n\n\n\n\n\n\n\n\n")
        }
    }
    
    func managerDurationForRecording(current: TimeInterval, total: TimeInterval) {
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.currentClipDuration = current
                self.currentProgress = total / self.maxQuickieDuration
            }
        }
    }
    
    func managerDidCompleteRecording(clips: [EditClip]) {
        DispatchQueue.main.async {
            self.clips = clips
            withAnimation(.spring()) {
                self.isRecording = false
                self.recordingComplete = true
            }
        }
    }
    
    func managerDidPauseRecording(clips: [EditClip]) {
        DispatchQueue.main.async {
            self.clips = clips
            if self.currentCaptureMode == .normal {
                self.goToEditor = true
            }
            withAnimation(.spring()) {
                self.isRecording = false
            }
        }
    }
    
    func manager(recordingCompleted: Bool) {
        
    }
    
    func manager(error: String?) {
        
        
    }
    
}

