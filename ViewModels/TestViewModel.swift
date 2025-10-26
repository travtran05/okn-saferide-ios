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
    
    let testDuration: Int = 10
    let faceTracker = FaceTracker()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe face tracker updates
        faceTracker.$faceDetected
            .assign(to: \.faceDetected, on: self)
            .store(in: &cancellables)
        
        faceTracker.$faceCentered
            .assign(to: \.faceCentered, on: self)
            .store(in: &cancellables)
    }
    
    // Start test sequence - IMMEDIATELY GO TO LANDSCAPE
    func startTest() {
        currentOrientation = .landscape
        currentPhase = .positioning
    }
    
    // Start OKN test - STAY IN LANDSCAPE
    func startOKNTest() {
        // Change phase immediately - no delays
        currentPhase = .oknTest
        timeRemaining = testDuration
        eyeTrackingData = EyeTrackingData()
        
        // Start timers immediately
        testTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.completeTest()
            }
        }
        
        eyeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.collectEyeData()
        }
    }
    
    // Collect real eye tracking data
    private func collectEyeData() {
        let currentTime = Double(testDuration - timeRemaining) + (Double(timeRemaining) / 10.0)
        
        eyeTrackingData.eyeX.append(faceTracker.eyeX)
        eyeTrackingData.eyeY.append(faceTracker.eyeY)
        eyeTrackingData.time.append(currentTime)
    }
    
    // Complete test and calculate results - RETURN TO PORTRAIT
    func completeTest() {
        testTimer?.invalidate()
        eyeTrackingTimer?.invalidate()
        
        let gain = OKNCalculator.calculateOKNGain(
            eyeXData: eyeTrackingData.eyeX,
            eyeYData: eyeTrackingData.eyeY,
            timeData: eyeTrackingData.time
        )
        
        testResults.oknGain = gain
        testResults.interpretation = OKNCalculator.getInterpretation(oknGain: gain)
        testResults.color = OKNCalculator.getColor(oknGain: gain)
        
        currentOrientation = .portrait
        currentPhase = .results
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
