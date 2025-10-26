import Foundation
import SwiftUI
import Combine
import UIKit

class TestViewModel: ObservableObject {
    @Published var currentPhase: TestPhase = .idle
    @Published var faceDetected: Bool = false
    @Published var faceCentered: Bool = false
    @Published var timeRemaining: Int = 10
    @Published var eyeTrackingData = EyeTrackingData()
    @Published var testResults = TestResults()
    @Published var currentOrientation: UIInterfaceOrientationMask = .portrait
    
    private var testTimer: Timer?
    private var eyeTrackingTimer: Timer?
    private var stripeAnimationValue: Double = 0.0
    
    let testDuration: Int = 10
    
    // Start test sequence
    func startTest() {
        // Stay in portrait for positioning
        currentOrientation = .portrait
        currentPhase = .positioning
        
        // Simulate face detection after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.faceDetected = true
            self.faceCentered = true
        }
    }
    
    // Start OKN test - SWITCH TO LANDSCAPE
    func startOKNTest() {
        // Force landscape orientation
        currentOrientation = .landscape
        
        // Immediately update phase
        self.currentPhase = .oknTest
        self.timeRemaining = self.testDuration
        self.eyeTrackingData = EyeTrackingData()
        
        // Start countdown timer
        self.testTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.completeTest()
            }
        }
        
        // Start eye tracking simulation (50ms intervals)
        self.eyeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.simulateEyeMovement()
        }
    }
    
    // Simulate eye movement following stripes
    private func simulateEyeMovement() {
        stripeAnimationValue += 0.01
        let eyeX = sin(stripeAnimationValue * 2 * .pi) * 0.3
        let eyeY = sin(stripeAnimationValue * .pi) * 0.1
        
        eyeTrackingData.eyeX.append(eyeX)
        eyeTrackingData.eyeY.append(eyeY)
        eyeTrackingData.time.append(Double(testDuration - timeRemaining) + Double(timeRemaining) / 10.0)
    }
    
    // Complete test and calculate results - RETURN TO PORTRAIT
    func completeTest() {
        testTimer?.invalidate()
        eyeTrackingTimer?.invalidate()
        
        // Calculate OKN gain
        let gain = OKNCalculator.calculateOKNGain(
            eyeXData: eyeTrackingData.eyeX,
            eyeYData: eyeTrackingData.eyeY,
            timeData: eyeTrackingData.time
        )
        
        testResults.oknGain = gain
        testResults.interpretation = OKNCalculator.getInterpretation(oknGain: gain)
        testResults.color = OKNCalculator.getColor(oknGain: gain)
        
        // Return to portrait orientation
        currentOrientation = .portrait
        self.currentPhase = .results
    }
    
    // Reset test
    func resetTest() {
        currentOrientation = .portrait
        currentPhase = .idle
        faceDetected = false
        faceCentered = false
        timeRemaining = testDuration
        eyeTrackingData = EyeTrackingData()
        testResults = TestResults()
    }
}
