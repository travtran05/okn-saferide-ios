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
                // Simple camera orientation - let the system handle it
                let rotationAngle: CGFloat = 0
                
                // Apply rotation if supported
                if connection.isVideoRotationAngleSupported(rotationAngle) {
                    connection.videoRotationAngle = rotationAngle
                    print("Camera rotation set to \(rotationAngle)°")
                } else {
                    print("Camera rotation \(rotationAngle)° not supported")
                }
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
    
    // Method to force camera orientation update
    func forceOrientationUpdate() {
        DispatchQueue.main.async {
            // This will trigger updateUIView which calls updateOrientation
        }
    }
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    @Published var isAuthorized = false
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
    var onFrameCapture: ((CMSampleBuffer) -> Void)?
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: AVCaptureSession.wasInterruptedNotification,
            object: session
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: AVCaptureSession.interruptionEndedNotification,
            object: session
        )
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        print("Camera session was interrupted")
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("Camera session interruption ended")
        DispatchQueue.main.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        // Check if session is already configured
        guard !session.isRunning else {
            print("Camera session already running")
            return
        }
        
        // Stop session first to avoid conflicts
        if session.isRunning {
            session.stopRunning()
        }
        
        session.beginConfiguration()
        
        // Use high preset for better quality
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera device")
            session.commitConfiguration()
            return
        }
        
        do {
            // Configure device settings to avoid conflicts
            try device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            device.exposureMode = .continuousAutoExposure
            device.unlockForConfiguration()
            
            let input = try AVCaptureDeviceInput(device: device)
            
            // Remove existing inputs first
            for existingInput in session.inputs {
                session.removeInput(existingInput)
            }
            
            if session.canAddInput(input) {
                session.addInput(input)
                print("Camera input added successfully")
            } else {
                print("Cannot add camera input")
            }
            
            // Add video output for face tracking with minimal settings
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            // Remove existing outputs first
            for existingOutput in session.outputs {
                session.removeOutput(existingOutput)
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                print("Video output added successfully")
            } else {
                print("Cannot add video output")
            }
            
        } catch {
            print("Camera setup error: \(error)")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
        // Start camera session with delay to avoid conflicts
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.1) {
            if !self.session.isRunning {
                self.session.startRunning()
                print("Camera session started successfully: \(self.session.isRunning)")
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onFrameCapture?(sampleBuffer)
    }
    
    // Method to force camera orientation update
    func forceOrientationUpdate() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    // Method to restart camera session
    func restartCameraSession() {
        DispatchQueue.global(qos: .userInteractive).async {
            if self.session.isRunning {
                self.session.stopRunning()
                print("Camera session stopped for restart")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setupCamera()
            }
        }
    }
}
