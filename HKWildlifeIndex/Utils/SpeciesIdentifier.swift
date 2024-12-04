

import Foundation
import CoreML
import SwiftUI
import os.log
import CoreVideo
import Vision


class SpeciesIdentifier {
    let model : WildlifeClassifier? = try? WildlifeClassifier(configuration: MLModelConfiguration())
    
    func identifyAnimal(image: UIImage, completion: @escaping (Result<[VNClassificationObservation], Error>) -> Void) {
        guard let model = model else {
            Logger().error("Failed to initialize model")
            return
        }
        guard let vnModel = try? VNCoreMLModel(for: model.model) else {
            Logger().error("Failed to initialize vision model")
            return
        }
        guard let buffer = createBuffer(from: image) else { 
            Logger().error("Failed to create buffer")
            return
        }
        do {
            let imageClassificationRequest = VNCoreMLRequest(model: vnModel) { (request, error) in
                if let error {
                    completion(.failure(error))
                }
                if let results = request.results as? [VNClassificationObservation] {
                    completion(.success(results))
                }
            }
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
            try requestHandler.perform([imageClassificationRequest])

            
            imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        } catch {
            completion(.failure(error))
        }
    }
    func createBuffer(from image: UIImage) -> CVPixelBuffer? {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}
