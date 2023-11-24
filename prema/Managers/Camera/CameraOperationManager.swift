//
//  CameraManager.swift
//  Elixer
//
//  Created by Denzel Anderson on 7/17/22.
//

import ARVideoKit
import ARKit
import Foundation
import Photos
import SwiftUI

enum DevicePosition {
    case front, back
}


protocol CameraOperationManagerDelegate {
    func managerDidCapturePhoto(clips: [EditClip])
    func manager(didStartRecording: Bool)
    func managerDurationForRecording(current: TimeInterval, total: TimeInterval)
    func managerDidCompleteRecording(clips: [EditClip])
    func managerDidPauseRecording(clips: [EditClip])
    func manager(recordingCompleted: Bool)
    func manager(error: String?)
}

class CameraOperationManager: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    var clips: [EditClip] = []
    var arView: ARSCNView?
    var recorder: RecordAR?
    
    var devicePosition: DevicePosition = .front
    
    var configuration: ARConfiguration?
    var options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
    
    var maxRecordingDuration: Double = 45
    var currentDuration: Double = 0
    
    var delegate: CameraOperationManagerDelegate?
    
    deinit {
        self.resetManager()
    }
    
    func configure(_ arView: ARSCNView) {
        
        arView.delegate = self
        arView.session.delegate = self
        switch devicePosition {
        case .front:
            self.configuration = ARFaceTrackingConfiguration()
            if let configuration = configuration as? ARFaceTrackingConfiguration {
                configuration.isWorldTrackingEnabled = true
            }
        case .back:
            self.configuration = ARWorldTrackingConfiguration()
            if let configuration = configuration as? ARWorldTrackingConfiguration {
                configuration.userFaceTrackingEnabled = true
            }
        }
        
        arView.bounds = UIScreen.main.bounds
        arView.delegate = self

        self.arView = arView

        recorder = RecordAR(ARSceneKit: self.arView!)
        recorder?.prepare(configuration)
        recorder?.delegate = self
        self.startPreview()
    }
    
    func capturePhoto() {
        let image = recorder?.photo()
        let media = prema.Media(uiImage: image)
        self.currentDuration = self.clips.reduce(0) { $0 + ($1.media.videoURLString?.url?.asset?.duration.seconds ?? 0) }
        let clip = EditClip(media: media, overlay: AnyView(EmptyView()))
        self.clips.append(clip)
        delegate?.managerDidCapturePhoto(clips: self.clips)
    }
    
    func startRecording() {
        self.currentDuration = self.clips.reduce(0) { $0 + ($1.media.videoURLString?.url?.asset?.duration.seconds ?? 0) }
        self.delegate?.manager(didStartRecording: true)
        self.recorder?.record(forDuration: 10) { videoPath in
//            self.delegate?.manager(didStartRecording: true)
        }
    }
    
    func pauseRecording() {
        self.recorder?.stop { videoPath in
            let media = Media(videoURLString: videoPath.absoluteString)
            let clip = EditClip(media: media, overlay: AnyView(EmptyView()))
            self.clips.append(clip)
            self.delegate?.managerDidPauseRecording(clips: self.clips)
        }
    }
    
    func startPreview() {
        guard arView != nil else { return }
        if let configuration = configuration {
            self.arView!.session.run(configuration, options: options)
            print("started preview")
        }
    }
    
    func pausePreview() {
        guard arView != nil else { return }
        arView!.session.pause()
    }
    
    func resetManager() {
        pausePreview()
        self.clips.forEach { clip in
            if let url = clip.media.videoURLString {
//                url.deleteFile()
            }
        }
        self.clips.removeAll()
        startPreview()
    }
    
    func flipDevicePosition() async -> () {
        pausePreview()
        devicePosition = (devicePosition == .front) ? .back:.front
        switch devicePosition {
        case .front:
            self.configuration = ARFaceTrackingConfiguration()
            if let configuration = configuration as? ARFaceTrackingConfiguration {
                configuration.isWorldTrackingEnabled = true
            }
        case .back:
            self.configuration = ARWorldTrackingConfiguration()
            if let configuration = configuration as? ARWorldTrackingConfiguration {
                configuration.userFaceTrackingEnabled = true
            }
        }
        recorder?.prepare(configuration)
        startPreview()
    }
    
    
    
    func fetchPhotos(completion: @escaping (UIImage) -> ()) {
        // Sort the images by descending creation date and fetch the first 3 x
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        
//        let totalImageCountNeeded = 1 // <-- The number of images to fetch
        if let asset = fetchResult.firstObject {
            PHImageManager.default().requestImageData(for: asset, options: PHImageRequestOptions(), resultHandler: { data, _, _, _ in
                if let data = data {
                    completion(UIImage(data: data) ?? UIImage())
                }
            })
        }
        
    }
    
}

extension CameraOperationManager: RecordARDelegate {
    func recorder(didUpdateRecording duration: TimeInterval) {
        if duration >= maxRecordingDuration {
            pauseRecording()
            self.delegate?.managerDidCompleteRecording(clips: self.clips)
        }
        self.delegate?.managerDurationForRecording(current: duration, total: self.clips.reduce(0, { $0 + ($1.media.videoURLString?.url?.asset?.duration.seconds ?? 0)}) + duration)
    }
    
    func recorder(didEndRecording path: URL, with noError: Bool) {
        self.delegate?.managerDidPauseRecording(clips: self.clips)
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        self.delegate?.manager(error: error?.localizedDescription)
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        //
    }
}


extension URL {
    var asset: AVAsset? {
        return AVURLAsset(url: self)
    }
}

extension AVURLAsset {
    func duration() -> CMTime {
        return self.duration
    }
}
