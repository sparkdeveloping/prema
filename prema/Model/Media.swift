//
//  Media.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import UIKit
import ExyteMediaPicker
import Foundation
import CoreMedia
import AVFoundation
import Photos

enum MediaType {
    case image, video, audio
}

struct Media: Identifiable, Hashable, Codable {
    init(id: String = UUID().uuidString, imageURLString: String? = nil, videoURLString: String? = nil, audioURLString: String? = nil, uiImage: UIImage? = nil, ratio: CGFloat = 1) {
        self.id = id
        self.imageURLString = imageURLString
        self.videoURLString = videoURLString
        self.audioURLString = audioURLString
        self.uiImage = uiImage
        self.ratio = ratio
    }
    
    enum MediaType: String, Codable {
        case audio, image, video
    }

    var type: MediaType {
        if audioURLString != nil {
            return .audio
        }
        if videoURLString != nil {
            return .video
        }
        return .image
    }

    var id = UUID().uuidString
    var imageURLString: String?
    var videoURLString: String?
    var audioURLString: String?

    // Non-Codable properties
    var uiImage: UIImage? = nil
    var ratio: CGFloat = 1

    private enum CodingKeys: String, CodingKey {
        case type, id, imageURLString, videoURLString, audioURLString, uiImage, ratio
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decoding properties
        id = try container.decode(String.self, forKey: .id)
        imageURLString = try container.decodeIfPresent(String.self, forKey: .imageURLString)
        videoURLString = try container.decodeIfPresent(String.self, forKey: .videoURLString)
        audioURLString = try container.decodeIfPresent(String.self, forKey: .audioURLString)
        uiImage = nil // You might need to handle this based on the actual data format
        ratio = try container.decode(CGFloat.self, forKey: .ratio)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encoding properties
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(imageURLString, forKey: .imageURLString)
        try container.encode(videoURLString, forKey: .videoURLString)
        try container.encode(audioURLString, forKey: .audioURLString)
        try container.encode(ratio, forKey: .ratio)

        // You might need to handle encoding of `uiImage` based on the actual data format
    }
}



extension [String : Any] {
    func parseMedia(_ id: String? = nil) -> Media {
        var _id = self["id"] as? String ?? UUID().uuidString
        if let id {
            _id = id
        }
        let imageURLString = self["imageURL"] as? String
        
        let videoURLString = self["videoURL"] as? String
        
        let audioURLString = self["audioURL"] as? String
        
        
        return .init(id: _id, imageURLString: imageURLString, videoURLString: videoURLString, audioURLString: audioURLString)
    }
}

extension prema.Media {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["imageURL"] = self.imageURLString
        dict["videoURL"] = self.videoURLString
        dict["audioURL"] = self.audioURLString
        
        return dict
    }
}

extension String {
    var url: URL? {
        return URL(string: self)
    }
}

extension AVAsset {
    var thumbnail: Data? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            guard let data = UIImage(cgImage: thumbnailImage).pngData() else { return nil }
            return data
        } catch let error {
            print(error)
        }
        return nil
    }
}

extension Media {
    func downloadToPhotoLibrary() {
        DispatchQueue.global(qos: .background).async {
            if let url = self.videoURLString?.url,
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            } else if let url = self.imageURLString?.url {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? url.lastPathComponent)
                    print("Download Finished")
                    // always update the UI from the main thread
                    DispatchQueue.main.async() { 
                        guard let image = UIImage(data: data) else { return }
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
            }
        }
        
        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
        
    }
}
