import SwiftUI
import Combine

struct PositioningView: View {
    @ObservedObject var cameraManager: CameraManager
    let faceDetected: Bool
    let faceCentered: Bool
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Green overlay
            GreenOverlay(faceCentered: faceCentered)
            
            VStack {
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(faceDetected ? Color.green : Color.red)
                        .frame(width: 20, height: 20)
                    
                    Text(faceDetected ? "Face Detected - Ready!" : "Position your face in the circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                
                if faceCentered {
                    Button(action: onContinue) {
                        Text("START OKN TEST")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
    }
}
