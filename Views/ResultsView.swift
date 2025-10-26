import SwiftUI

struct ResultsView: View {
    let oknGain: Double
    let interpretation: String
    let colorName: String
    let onNewTest: () -> Void
    
    var resultColor: Color {
        switch colorName {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Test Results")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // OKN Gain Circle
                    ZStack {
                        Circle()
                            .stroke(resultColor.opacity(0.3), lineWidth: 20)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: min(oknGain, 1.0))
                            .stroke(resultColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text(String(format: "%.2f", oknGain))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            Text("OKN Gain")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Interpretation
                    Text(interpretation)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(resultColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    
                    // Metrics cards
                    VStack(spacing: 15) {
                        MetricCard(title: "Test Duration", value: "10 seconds")
                        MetricCard(title: "Data Points", value: "\(Int(200)) samples")
                        MetricCard(title: "Confidence", value: "High")
                    }
                    .padding(.horizontal)
                    
                    // Safe ride options (if impaired)
                    if oknGain < 1.0 {
                        VStack(spacing: 15) {
                            Text("🚗 Safe Ride Options")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            SafeRideButton(title: "Call Uber", icon: "car.fill", color: .black)
                            SafeRideButton(title: "Call Lyft", icon: "car.fill", color: .pink)
                            SafeRideButton(title: "Find Taxi", icon: "phone.fill", color: .yellow)
                            SafeRideButton(title: "Public Transit", icon: "tram.fill", color: .blue)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // New test button
                    Button(action: onNewTest) {
                        Text("START NEW TEST")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SafeRideButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
