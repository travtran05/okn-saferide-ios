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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    
                    if faceCentered {
                        Button(action: onContinue) {
                            Text("START OKN TEST")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding(.top, 15)
                    }
                    
                    Spacer().frame(height: 20)
                }
            }
        }
}
