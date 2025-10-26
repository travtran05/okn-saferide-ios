import SwiftUI

struct StripesView: View {
    let stripeWidth: CGFloat = 44
    let stripeGap: CGFloat = 44
    let speed: CGFloat = 220.0 // pixels per second (matches app.js STIM_SPEED)
    
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let period = stripeWidth + stripeGap
                    let numStripes = Int(ceil(size.width / period)) + 3
                    
                    // Calculate animated offset based on time
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    let animatedOffset = (CGFloat(elapsed) * speed).truncatingRemainder(dividingBy: period)
                    
                    // White background
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(.white)
                    )
                    
                    // Draw black vertical stripes moving left to right
                    for i in 0..<numStripes {
                        let x = -animatedOffset + CGFloat(i) * period
                        let rect = CGRect(x: x, y: 0, width: stripeWidth, height: size.height)
                        context.fill(
                            Path(rect),
                            with: .color(.black)
                        )
                    }
                    
                    // RED CENTER LINE (horizontal, middle of screen)
                    let centerY = size.height / 2
                    let centerLine = Path { path in
                        path.move(to: CGPoint(x: 0, y: centerY))
                        path.addLine(to: CGPoint(x: size.width, y: centerY))
                    }
                    context.stroke(centerLine, with: .color(.red), lineWidth: 2)
                }
            }
        }
    }
}
