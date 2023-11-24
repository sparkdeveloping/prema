//
//  MediaPicker.swift
//  Elixer
//
//  Created by Denzel Nyatsanza on 12/24/22.
//

enum MediaConfigType: String {
    case quickie = "Quickie", feed = "Feed", update = "Update", tv = "TV", cast = "Cast", profile_avatar = "Profile Avatar", profile_banner = "Profile Banner", direct = "Direct"
}

import AVFoundation
import SwiftUI
import YPImagePicker
import SDWebImageSwiftUI

struct MediaPickerModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var type: MediaConfigType
    var max: Int
    var media: ([Media]) -> ()
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ImagePicker(isPresented: $isPresented, type: self.type, max: max) { media in
                    self.media(media)
                }
            }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var type: MediaConfigType
    var media: ([Media]) -> ()
    var max: Int = 7
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> YPImagePicker {
        let picker = configuredPicker()
        
        // Set up the configuration for the picker
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                self.isPresented = false
                return
            }
            
            media(items.map { item in
                switch item {
                case .photo(let photo):
                    return Media(uiImage: photo.image)
                case .video(let video):
                    return Media(videoURLString: video.url.absoluteString, uiImage: video.thumbnail)
                }
            })
            
            self.isPresented = false
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: YPImagePicker, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func configuredPicker() -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = false
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.showsVideoTrimmer = true
        config.startOnScreen = YPPickerScreen.library
        config.targetImageSize = YPImageSize.cappedTo(size: 1024)
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.maxCameraZoomFactor = 2.0
        //        Library
        config.library.options = nil
        config.library.onlySquare = false
        
        config.library.minWidthForItem = nil
        config.library.minNumberOfItems = 1
        
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        config.library.preSelectItemOnMultipleSelection = false
        config.library.defaultMultipleSelection = false
        // Video
        config.video.compression = AVAssetExportPreset1920x1080
        config.video.fileType = .mp4
        // Gallery
        config.gallery.hidesRemoveButton = false
        config.albumName = self.type.rawValue
//        config.shouldSaveNewPicturesToAlbum = true
        config.library.isSquareByDefault =  false
        
        config.library.maxNumberOfItems = max
        config.video.minimumTimeLimit = 3.0
        
        
        config.video.trimmerMinDuration = 3.0
        config.library.defaultMultipleSelection = false
        
        switch self.type {
        case .quickie:
            config.screens = [.library, .video]
            config.showsCrop = .rectangle(ratio: 9 / 16)
            config.library.mediaType = YPlibraryMediaType.video
            config.library.maxNumberOfItems = 4
            config.video.recordingTimeLimit = 120
            config.video.libraryTimeLimit = 120
        case .feed:
            config.screens = [.library, .photo, .video]
            config.showsCrop = .rectangle(ratio: 1)
            config.library.mediaType = YPlibraryMediaType.photoAndVideo
            config.video.recordingTimeLimit = 120
            config.video.libraryTimeLimit = 120
        case .update:
            config.screens = [.library, .photo, .video]
            config.library.mediaType = YPlibraryMediaType.photoAndVideo
            config.video.recordingTimeLimit = 120
            config.video.libraryTimeLimit = 120
            
        case .tv:
            config.screens = [.library, .video]
            config.showsCrop = .rectangle(ratio: 16 / 9)
            config.library.mediaType = YPlibraryMediaType.video
            config.video.recordingTimeLimit = 3600
            
        case .cast:
            config.showsCrop = .rectangle(ratio: 16 / 9)
            config.screens = [.library, .photo, .video]
            config.video.recordingTimeLimit = 7
            config.video.libraryTimeLimit = 7
        case .profile_avatar:
            config.screens = [.library, .photo, .video]
            config.showsCrop = .rectangle(ratio: 1)
            config.library.mediaType = YPlibraryMediaType.photoAndVideo
            config.video.recordingTimeLimit = 7
            config.video.libraryTimeLimit = 7
        case .profile_banner:
            config.screens = [.library, .photo, .video]
            config.showsCrop = .rectangle(ratio: 1)
            config.library.mediaType = YPlibraryMediaType.photoAndVideo
            config.video.recordingTimeLimit = 7
            config.video.libraryTimeLimit = 7
        case .direct:
            config.screens = [.library, .photo, .video]
            config.library.mediaType = YPlibraryMediaType.photoAndVideo
            config.video.recordingTimeLimit = 120
            config.video.libraryTimeLimit = 120
        }
        
    
        return YPImagePicker(configuration: config)
        
    }
}

struct ImageX: View {
    
    var urlImage: URL?
    var shouldFit: Bool
    init(_ url: URL? = nil, urlString: String? = nil, shouldFit: Bool = false) {
        self.shouldFit = shouldFit
        if let string = urlString {
            urlImage = URL(string: string)
        } else {
            urlImage = url
        }
    }
    
    var body: some View {
        if shouldFit {
            WebImage(url: urlImage)
                // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                .onSuccess { image, data, cacheType in
                    // Success
                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                }
                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                .placeholder(Image(systemName: "photo")) // Placeholder Image
                // Supports ViewBuilder as well
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.2)) // Fade Transition with duration
                .scaledToFit()
        }
        WebImage(url: urlImage)
            // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
            .onSuccess { image, data, cacheType in
                // Success
                // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
            }
            .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
            .placeholder(Image(systemName: "photo")) // Placeholder Image
            // Supports ViewBuilder as well
            .placeholder {
                Rectangle().foregroundColor(.gray)
            }
            .indicator(.activity) // Activity Indicator
            .transition(.fade(duration: 0.2)) // Fade Transition with duration
            .scaledToFill()
    }
}

