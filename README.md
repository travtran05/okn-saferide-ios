# OKN SafeRide - Native iOS

Native iOS app for impairment detection using Optokinetic Nystagmus (OKN) eye tracking.

## Features
- ✅ Portrait orientation (idle, positioning, results)
- ✅ Auto-rotate to landscape during 10-second OKN test
- ✅ Auto-rotate back to portrait after test
- ✅ Camera-based eye tracking
- ✅ Moving black/white vertical stripes (OKN stimulus)
- ✅ Real-time OKN gain calculation
- ✅ Color-coded results (green/orange/red)
- ✅ Safe ride suggestions

## Requirements
- iOS 16.0+
- Xcode 15.0+
- iPhone with front camera

## Setup
1. Clone this repository:
```bash
   git clone https://github.com/YOUR_USERNAME/okn-saferide-ios.git
   cd okn-saferide-ios
```

2. Open `OKNSafeRide.xcodeproj` in Xcode

3. Select your development team:
   - Click project → Signing & Capabilities
   - Choose your Apple ID under "Team"

4. Connect iPhone via USB and run (Cmd + R)

5. Trust developer on iPhone:
   - Settings → General → Device Management → Trust

## Testing on iPhone
- App starts in portrait
- Tap "START TEST"
- Position face in green circle (portrait)
- Tap "START OKN TEST"
- **Phone auto-rotates to landscape**
- Follow moving stripes for 10 seconds
- **Phone auto-rotates back to portrait**
- View results

## Demo/Research Purpose Only
This app is for demonstration and research purposes only. Not a medical device.

## License
MIT
