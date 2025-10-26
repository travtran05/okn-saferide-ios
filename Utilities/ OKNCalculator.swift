import Foundation

class OKNCalculator {
    // Constants from original Flutter app
    static let stripeWidth: Double = 44.0
    static let stripeGap: Double = 44.0
    static let stripePeriod: Double = stripeWidth + stripeGap
    static let stripeSpeed: Double = 0.1 // degrees per second
    
    static func calculateOKNGain(eyeXData: [Double], eyeYData: [Double], timeData: [Double]) -> Double {
        guard eyeXData.count >= 10 else {
            return 0.0
        }
        
        // Calculate stimulus velocity
        let stimulusVelocity = stripeSpeed
        
        // Calculate eye velocity using numerical differentiation
        var eyeVelocities: [Double] = []
        
        for i in 1..<eyeXData.count {
            let velocity = (eyeXData[i] - eyeXData[i-1]) / 0.05 // 50ms intervals
            eyeVelocities.append(velocity)
        }
        
        // Calculate OKN gain as ratio of eye velocity to stimulus velocity
        guard !eyeVelocities.isEmpty else {
            return 0.0
        }
        
        let avgEyeVelocity = eyeVelocities.reduce(0, +) / Double(eyeVelocities.count)
        let oknGain = abs(avgEyeVelocity / stimulusVelocity)
        
        return oknGain
    }
    
    static func getInterpretation(oknGain: Double) -> String {
        if oknGain >= 1.0 {
            return "Unlikely Impaired\nSafe to drive"
        } else if oknGain >= 0.75 {
            return "Possible Impairment\nUse caution"
        } else {
            return "Likely Impaired\nDo not drive"
        }
    }
    
    static func getColor(oknGain: Double) -> String {
        if oknGain >= 1.0 {
            return "green"
        } else if oknGain >= 0.75 {
            return "orange"
        } else {
            return "red"
        }
    }
}
