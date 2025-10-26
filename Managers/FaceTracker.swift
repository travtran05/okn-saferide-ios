import Foundation
import AVFoundation
import Vision
import UIKit
import Combine

class FaceTracker: NSObject, ObservableObject {
    @Published var faceDetected: Bool = false
    @Published var faceCentered: Bool = false
    @Published var eyeX: Double = 0.0
    @Published var eyeY: Double = 0.0
    @Published var faceRect: CGRect = .zero
    
    private var sequenceHandler = VNSequenceRequestHandler()
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNFaceObservation],
                  let face = observations.first else {
                DispatchQueue.main.async {
                    self?.faceDetected = false
                    self?.faceCentered = false
                }
                return
            }
            
            self.processFaceObservation(face)
        }
        
        // Lower accuracy for better performance
        request.revision = VNDetectFaceLandmarksRequestRevision3
        
        try? sequenceHandler.perform([request], on: pixelBuffer)
    }
    
    private func processFaceObservation(_ face: VNFaceObservation) {
        DispatchQueue.main.async {
            self.faceDetected = true
            self.faceRect = face.boundingBox
            
            // Check if face is centered (within middle 60% of screen)
            let centerX = face.boundingBox.midX
            let centerY = face.boundingBox.midY
            self.faceCentered = (0.3...0.7).contains(centerX) && (0.3...0.7).contains(centerY)
            
            // Extract eye positions
            if let landmarks = face.landmarks {
                self.extractEyePosition(from: landmarks)
            }
        }
    }
    
    private func extractEyePosition(from landmarks: VNFaceLandmarks2D) {
        // Get left and right eye positions
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye,
              let leftPupil = landmarks.leftPupil,
              let rightPupil = landmarks.rightPupil else {
            return
        }
        
        // Calculate normalized eye position (similar to app.js normEyeX function)
        let leftEyePoints = leftEye.normalizedPoints
        let rightEyePoints = rightEye.normalizedPoints
        let leftPupilPoints = leftPupil.normalizedPoints
        let rightPupilPoints = rightPupil.normalizedPoints
        
        if let leftPupilCenter = leftPupilPoints.first,
           let rightPupilCenter = rightPupilPoints.first,
           !leftEyePoints.isEmpty,
           !rightEyePoints.isEmpty {
            
            // Calculate left eye normalized position
            let leftEyeMinX = leftEyePoints.map { $0.x }.min() ?? 0
            let leftEyeMaxX = leftEyePoints.map { $0.x }.max() ?? 1
            let leftSpan = leftEyeMaxX - leftEyeMinX
            let leftNorm = ((leftPupilCenter.x - leftEyeMinX) / leftSpan) * 2 - 1
            
            // Calculate right eye normalized position
            let rightEyeMinX = rightEyePoints.map { $0.x }.min() ?? 0
            let rightEyeMaxX = rightEyePoints.map { $0.x }.max() ?? 1
            let rightSpan = rightEyeMaxX - rightEyeMinX
            let rightNorm = ((rightPupilCenter.x - rightEyeMinX) / rightSpan) * 2 - 1
            
            // Average both eyes (matches app.js implementation)
            self.eyeX = Double((leftNorm + rightNorm) / 2.0)
            self.eyeY = Double((leftPupilCenter.y + rightPupilCenter.y) / 2.0) * 2 - 1
        }
    }
}
