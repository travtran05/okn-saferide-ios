import SwiftUI
import AVFoundation
import Combine

struct CameraView: UIViewRepresentable {
    class CameraPreview: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateOrientation()
        }
        
        func updateOrientation() {
            if let connection = previewLayer.connection {
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first
                
                let orientation = windowScene?.effectiveGeometry.interfaceOrientation ?? .portrait
                let rotationAngle: CGFloat
                
                // Front-facing camera rotation angles
                // These are tested and correct for iOS front camera
                switch orientation {
                case .portrait:
                    rotationAngle = 90
                case .portraitUpsideDown:
                    rotationAngle = 270
                case .landscapeLeft:
                    rotationAngle = 0
                case .landscapeRight:
                    rotationAngle = 180
                case .unknown:
                    rotationAngle = 90
                @unknown default:
                    rotationAngle = 90
                }
                
                connection.videoRotationAngle = rotationAngle
            }
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        
        // Set initial orientation
        view.updateOrientation()
        
        // Add observer for orientation changes
        context.coordinator.setupOrientationObserver(for: view)
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        private var observer: NSObjectProtocol?
        
        func setupOrientationObserver(for view: CameraPreview) {
            observer = NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                view.updateOrientation()
            }
        }
        
        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {
        // Force immediate orientation update
        DispatchQueue.main.async {
            uiView.updateOrientation()
        }
    }
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    @Published var isAuthorized = false
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInitiated)
    var onFrameCapture: ((CMSampleBuffer) -> Void)?
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add video output for face tracking
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onFrameCapture?(sampleBuffer)
    }
}
