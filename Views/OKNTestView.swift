import SwiftUI
import Combine

struct OKNTestView: View {
    @ObservedObject var cameraManager: CameraManager
    let timeRemaining: Int
    
    var body: some View {
        ZStack {
            // Layer 1: White background with black stripes (moving)
            StripesView()
                .ignoresSafeArea()
                .opacity(0.8) // Slightly transparent so camera shows through
            
            // Layer 2: Camera preview (behind stripes)
            CameraView(session: cameraManager.session)
                .ignoresSafeArea()
                .opacity(0.2) // Very faint to see face position
            
            // Layer 3: UI elements on top
            VStack {
                Spacer()
                
                // Timer circle
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 120, height: 120)
                    
                    Text("\(timeRemaining)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer().frame(height: 30)
                
                // Instructions
                Text("Follow the moving stripes\nwith your eyes")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                
                Spacer()
            }
        }
    }
}
