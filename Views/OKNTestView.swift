import SwiftUI
import Combine

struct OKNTestView: View {
    @ObservedObject var cameraManager: CameraManager
    let timeRemaining: Int
    
    var body: some View {
        ZStack {
            // Layer 1: Camera preview (bottom layer, very faint)
            CameraView(session: cameraManager.session)
                .ignoresSafeArea()
                .opacity(0.15) // Very faint background
            
            // Layer 2: White background with black stripes (main layer)
            StripesView()
                .ignoresSafeArea()
            
            // Layer 3: UI elements on top - centered for landscape
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
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}
