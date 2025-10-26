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
                    cameraManager.checkAuthorization()
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
        .onReceive(viewModel.$currentOrientation) { orientation in
            // Update app orientation based on test phase
            AppDelegate.orientationLock = orientation
            
            // Force orientation change using modern iOS 16+ API
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let geometryPreferences: UIWindowScene.GeometryPreferences
                
                if orientation == .landscape {
                    geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
                } else {
                    geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                }
                
                windowScene.requestGeometryUpdate(geometryPreferences) { error in
                    print("Orientation update error: \(error)")
                }
                
                windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }
}

#Preview {
    ContentView()
}
