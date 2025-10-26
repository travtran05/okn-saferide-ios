import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = TestViewModel()
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            switch viewModel.currentPhase {
            case .idle:
                IdleView(onStartTest: {
                    viewModel.startTest()
                })
                
            case .positioning:
                PositioningView(
                    cameraManager: cameraManager,
                    faceDetected: viewModel.faceDetected,
                    faceCentered: viewModel.faceCentered,
                    onContinue: {
                        viewModel.startOKNTest()
                    }
                )
                
            case .oknTest:
                OKNTestView(
                    cameraManager: cameraManager,
                    timeRemaining: viewModel.timeRemaining
                )
                
            case .results:
                ResultsView(
                    oknGain: viewModel.testResults.oknGain,
                    interpretation: viewModel.testResults.interpretation,
                    colorName: viewModel.testResults.color,
                    onNewTest: {
                        viewModel.resetTest()
                    }
                )
            }
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.currentOrientation) { _, newOrientation in
            // Orientation is now handled directly in TestViewModel
            print("ContentView: Orientation changed to \(newOrientation)")
        }
        .onChange(of: viewModel.currentPhase) { _, newPhase in
            // Force camera orientation update when phase changes
            if newPhase == .oknTest {
                DispatchQueue.main.async {
                    // Force camera orientation update
                    cameraManager.forceOrientationUpdate()
                }
            }
        }
        .onAppear {
            // Start camera immediately on app launch
            cameraManager.checkAuthorization()
            
            // Connect camera to face tracker
            cameraManager.onFrameCapture = { [weak viewModel] sampleBuffer in
                viewModel?.faceTracker.processSampleBuffer(sampleBuffer)
            }
        }
    }
    
    private func updateOrientation(_ orientation: UIInterfaceOrientationMask) {
        print("ContentView: Orientation changed to \(orientation)")
        // Orientation is now handled in TestViewModel
    }
}

#Preview {
    ContentView()
}
