import AVFoundation
import SwiftUI
import os.log

final class CameraModel: ObservableObject {
    let camera = Camera()
    
    @Published var viewfinderImage: Image?
    @Published var photo: CIImage?
    var isPhotosLoaded = false
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image.image
                photo = image
            }
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> Data? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return imageData
    }
    public func setFlashlight(_ brightness: Float) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            Logger().error("Failed to obtain video input.")
            return
        }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if brightness == 0 {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: brightness)
                }
                device.unlockForConfiguration()
            } catch {
                Logger().error("\(error.localizedDescription)")
            }
        } else {
            Logger().error("Device has no flashlight.")
        }
    }
}

struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

 extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

 extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
