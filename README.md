# PhotoMailApp

SwiftUI sample: take a photo on iPhone and email it as a JPEG attachment.

## Requirements
- Xcode (any version that supports iOS 15+)
- iOS 15+ device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project locally), **or** rely on Codemagic which runs XcodeGen for you during CI.

## Local setup
1. Install XcodeGen: `brew install xcodegen`
2. In the repository root, run: `xcodegen generate`
3. Open `PhotoMailApp.xcodeproj` in Xcode.
4. Run on your iPhone (allow Camera permission when prompted).

## Codemagic
Codemagic will install XcodeGen and generate the Xcode project automatically using `project.yml`, then build and (optionally) submit to TestFlight per `codemagic.yaml`.
