// iOS Configuration for WonderWorld Learning Adventure
// Location: ios/Runner/Info.plist

/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>WonderWorld</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>WonderWorld</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
*/

// This file provides iOS configuration notes.
// After running `flutter create .` in the frontend folder,
// the actual Info.plist will be generated.

const iosConfig = '''
WonderWorld Learning Adventure - iOS Configuration

1. App Name: WonderWorld
2. Bundle ID: com.wonderworld.learning
3. Deployment Target: iOS 12.0+
4. Supported Devices: iPhone, iPad

Privacy Descriptions (add to Info.plist if needed):
- NSMicrophoneUsageDescription: For voice activities (if used)
- NSCameraUsageDescription: For AR features (if used)

App Store Guidelines:
- Kids Category: Ages 5 and Under / Ages 6-8
- No third-party analytics or ads
- COPPA/GDPR-K compliant

App Icon:
- 1024x1024 App Store icon
- Various sizes for iPhone/iPad
- Purple star design matching Android

Launch Screen:
- Purple gradient background
- Animated star logo
''';
