import Foundation

enum TestPhase {
    case idle
    case positioning
    case oknTest
    case results
}

struct EyeTrackingData {
    var eyeX: [Double] = []
    var eyeY: [Double] = []
    var time: [Double] = []
}

struct TestResults {
    var oknGain: Double = 0.0
    var interpretation: String = ""
    var color: String = "" // "green", "orange", "red"
}
