import SwiftUI

struct GreenOverlay: View {
    let faceCentered: Bool
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.3)
            
            // Center circle cutout
            Circle()
                .strokeBorder(faceCentered ? Color.green : Color.red, lineWidth: 4)
                .frame(width: 200, height: 200)
            
            // Crosshair lines
            VStack(spacing: 0) {
                Rectangle()
                    .fill(faceCentered ? Color.green : Color.red)
                    .frame(width: 2, height: 30)
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 2, height: 140)
                Rectangle()
                    .fill(faceCentered ? Color.green : Color.red)
                    .frame(width: 2, height: 30)
            }
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(faceCentered ? Color.green : Color.red)
                    .frame(width: 30, height: 2)
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 140, height: 2)
                Rectangle()
                    .fill(faceCentered ? Color.green : Color.red)
                    .frame(width: 30, height: 2)
            }
        }
    }
}
