//
//  Media.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/3/23.
//

import UIKit
import ExyteMediaPicker
import Foundation
enum MediaType {
    case image, video, audio
}
struct Media: Identifiable, Codable, Hashable {
    
    internal init(id: String = UUID().uuidString, imageURLString: String? = nil, videoURLString: String? = nil, audioURLString: String? = nil, data: Data? = nil, type: MediaType = .image) {
        self.id = id
        self.imageURLString = imageURLString
        self.videoURLString = videoURLString
        self.audioURLString = audioURLString
        self.data = data
        self.type = type
    }
    
  
    
  
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String = UUID().uuidString
    var imageURLString: String? = nil
    var videoURLString: String? = nil
    var audioURLString: String? = nil
    var type: MediaType = .image
    var uiImage: UIImage {
        UIImage(data: data ?? Data()) ?? UIImage()
    }
    var data: Data? = nil

    private enum CodingKeys: String, CodingKey {
        case id
        case imageURLString
        case videoURLString
        case audioURLString
    }


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        imageURLString = try container.decodeIfPresent(String.self, forKey: .imageURLString)
        videoURLString = try container.decodeIfPresent(String.self, forKey: .videoURLString)
        audioURLString = try container.decodeIfPresent(String.self, forKey: .audioURLString)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageURLString, forKey: .imageURLString)
        try container.encode(videoURLString, forKey: .videoURLString)
        try container.encode(audioURLString, forKey: .audioURLString)
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
