//
//  CreateStickerViewModel.swift
//  Prema
//
//  Created by Denzel Nyatsanza on 4/30/23.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import FirebaseFirestore


class CreateStickerViewModel: ObservableObject{
    // MARK: Image Picker Properties
    @Published var showPicker: Bool = false
    @Published var text = ""
    @Published var pickedItem: PhotosPickerItem?{
        didSet {
            // MARK: Extracting Image
            extractImage()
        }
    }
    @Published var fetchedImage: UIImage?
    
    func uploadSticker(inbox: String, completion: @escaping (Error?) -> Void) {
//        SharedDataManager.shared.isloading = true
        guard let profile = AccountManager.shared.currentProfile else { return }
        if let fetchedImage, !text.isEmpty {
            
            
            let media = Media(uiImage: fetchedImage)
            
            StorageManager.uploadMedia(media: [media], locationName: "stickers") { mediaDict in
                mediaDict.forEach { dict in
                    
                    var data: [String: Any] = dict
                    data["name"] = self.text
                    data["inboxID"] = inbox
                    data["timestamp"] = Timestamp(profile: profile, time: Date.now.timeIntervalSince1970).dictionary
                    
                    
                    Ref.firestoreDb.collection("stickers").addDocument(data: data) { error in
                        if let error = error {
                            print("error uploading sticker: \(error.localizedDescription)")
                        }
                        
//                        SharedDataManager.shared.isloading = false
                        DirectManager.shared.fetchStickers()
                        completion(nil)
                    }
                    
                }
            } onError: { error in
                print("error uploading sticker image: \(error)")

//                SharedDataManager.shared.isloading = false
            }

            
            
          
            
        }
    }
    
    func extractImage(){
        if let pickedItem{
            SwiftUI.Task{
                guard let imageData = try? await pickedItem.loadTransferable(type: Data.self) else{return}
                let image = UIImage(data: imageData)
                await MainActor.run(body: {
                    self.fetchedImage = image
                })
            }
        }
    }
    
    // MARK: Removing background using Person Segmentation(Vision)
    func removeBackground(){
        guard let image = fetchedImage?.cgImage else{return}
        // MARK: Request
        let request = VNGeneratePersonSegmentationRequest()
        // MARK: Set this to True only for Testing in Simulator
        // request.usesCPUOnly = true
        
        // MARK: Task Handler
        let task = VNImageRequestHandler(cgImage: image)
        do{
            try task.perform([request])
            
            // MARK: Result
            if let result = request.results?.first{
                let buffer = result.pixelBuffer
                maskWithOriginalImage(buffer: buffer)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: It will Give the Mask/Outline of the Person present in the Image
    // We Need to Mask it With The Original Image, In Order to Remove the Background
    func maskWithOriginalImage(buffer: CVPixelBuffer){
        guard let cgImage = fetchedImage?.cgImage else{return}
        let original = CIImage(cgImage: cgImage)
        let mask = CIImage(cvImageBuffer: buffer)
        
        // MARK: Scaling Properties of the Mask in order to fit perfectly
        let maskX = original.extent.width / mask.extent.width
        let maskY = original.extent.height / mask.extent.height
        
        let resizedMask = mask.transformed(by: CGAffineTransform(scaleX: maskX, y: maskY))
        
        // MARK: Filter Using Core Image
        let filter = CIFilter.blendWithMask()
        filter.inputImage = original
        filter.maskImage = resizedMask
        
        if let maskedImage = filter.outputImage{
            // MARK: Creating UIImage
            let context = CIContext()
            guard let image = context.createCGImage(maskedImage, from: maskedImage.extent) else{return}
            
            // This is Detected Person Image
            self.fetchedImage = UIImage(cgImage: image)
        }
    }
}

