import SwiftUI

struct IdleView: View {
    let onStartTest: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("OKN SafeRide")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Impairment Detection Test")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                
                Button(action: onStartTest) {
                    Text("START TEST")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
        }
    }
}
