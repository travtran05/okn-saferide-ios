import SwiftUI

struct StripesView: View {
    @State private var offset: CGFloat = 0
    
    let stripeWidth: CGFloat = 44
    let stripeGap: CGFloat = 44
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()
                
                // Black stripes moving horizontally
                Canvas { context, size in
                    let period = stripeWidth + stripeGap
                    let numStripes = Int(ceil(size.width / period)) + 2
                    
                    // Draw black vertical stripes
                    for i in 0..<numStripes {
                        let x = offset + CGFloat(i) * period
                        let rect = CGRect(x: x, y: 0, width: stripeWidth, height: size.height)
                        context.fill(
                            Path(rect),
                            with: .color(.black)
                        )
                    }
                }
            }
        }
        .onAppear {
            // Animate stripes moving from right to left
            withAnimation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
            ) {
                offset = -(stripeWidth + stripeGap)
            }
        }
    }
}
