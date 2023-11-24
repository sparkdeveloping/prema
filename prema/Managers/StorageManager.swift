//
//  StorageManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import FirebaseStorage
import Foundation

class StorageManager {
    
    
    static func uploadMedia(media: [Media], locationName: String, onSuccess: @escaping
                            ([[String: Any]]) -> (), onError: @escaping(String) -> ()) {
        
        var dict: [[String: Any]] = []
        
        for (index, item) in media.enumerated() {
            
            switch item.type {
                
            case .image:
                if let data = item.uiImage?.pngData() {
                    self.uploadImageToFirebaseStorage(location: locationName, imageData: data, imageName: item.id) { urlString in
                        
                        dict.append(["imageURL":urlString])
                        if index == media.count - 1 {
                            onSuccess(dict)
                        }
                    } onError: { error in
                        onError(error)
                    }

                }
            case .video:
                if let urlString = item.videoURLString, let url = URL(string: urlString) {
                    self.uploadVideoOrAudioToFirebaseStorage(location: locationName, videoURL: url, videoName: item.id) { url in
                        
                        if let data = item.uiImage?.pngData() {
                            self.uploadImageToFirebaseStorage(location: locationName, imageData: data, imageName: item.id) { urlString in
                                
                                dict.append(["imageURL":urlString, "videoURL":url])
                                
                                if index == media.count - 1 {
                                    onSuccess(dict)
                                }
                                
                            } onError: { error in
                                onError(error)
                            }

                        }
                        
                    } onError: { error in
                        onError(error)
                    }

                }
            case .audio:
                if let urlString = item.audioURLString, let url = URL(string: urlString) {
                    self.uploadVideoOrAudioToFirebaseStorage(location: locationName, videoURL: url, videoName: item.id) { url in
                        
                        dict.append(["audioURL":url])
                        if index == media.count - 1 {
                            onSuccess(dict)
                        }
                    } onError: { error in
                        onError(error)
                    }

                }
            }
            
        }
        
    }
    
    static func uploadVideoOrAudioToFirebaseStorage(location: String, videoURL: URL, videoName: String, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let videoReference = storageReference.child("\(location)/\(videoName)")
        
        videoReference.putFile(from: videoURL, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error)")
            } else {
                print("Video uploaded successfully!")
                videoReference.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // Successfully obtained the download URL
                        onSuccess(downloadURL.absoluteString)
                    } else if let error = error {
                        print("Error getting download URL: \(error)")
                        onError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(location: String, imageData: Data, imageName: String, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let imageReference = storageReference.child("\(location)/\(imageName)")
        
        imageReference.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error)")
                onError(error.localizedDescription)
            } else {
                print("Image uploaded successfully!")
                imageReference.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // Successfully obtained the download URL
                        onSuccess(downloadURL.absoluteString)
                    } else if let error = error {
                        print("Error getting download URL: \(error)")
                        onError(error.localizedDescription)
                    }
                }
            }
        }
    }

    
}
