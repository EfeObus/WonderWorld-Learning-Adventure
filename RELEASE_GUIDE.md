# 🚀 Google Play Store Release Guide

## WonderWorld Learning Adventure - Release Preparation

This guide walks you through releasing the app to the Google Play Store.

---

## 📋 Pre-Release Checklist

### 1. App Configuration ✅
- [x] Unique Application ID: `com.wonderworld.learning`
- [x] Version configured in `pubspec.yaml`
- [x] App name: "WonderWorld Learning"
- [x] Portrait orientation locked

### 2. Security Configuration ✅
- [x] ProGuard rules for code obfuscation
- [x] R8 shrinking and minification enabled
- [x] Network security config (HTTPS only)
- [x] Cleartext traffic disabled
- [x] Backup disabled for privacy
- [x] Data extraction rules configured

### 3. Privacy & Compliance ✅
- [x] COPPA compliance (no data collection)
- [x] Privacy policy created
- [x] No advertising SDKs
- [x] No analytics tracking
- [x] Designed for Families policy compatible

---

## 🔑 Step 1: Create Signing Key

```bash
# Navigate to android folder
cd frontend/android

# Generate a new keystore
keytool -genkey -v -keystore wonderworld-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias wonderworld

# You will be prompted for:
# - Keystore password (save this securely!)
# - Key password (can be same as keystore)
# - Your name, organization, city, country
```

⚠️ **IMPORTANT**: Save your keystore and passwords securely! If lost, you cannot update your app.

---

## 🔐 Step 2: Configure Signing

1. Copy the template:
```bash
cp key.properties.template key.properties
```

2. Edit `key.properties` with your actual values:
```properties
storePassword=your_actual_password
keyPassword=your_actual_password
keyAlias=wonderworld
storeFile=wonderworld-release-key.jks
```

---

## 📦 Step 3: Build Release APK/AAB

### Build App Bundle (Recommended for Play Store):
```bash
cd frontend
flutter build appbundle --release
```

The bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (for testing):
```bash
flutter build apk --release --split-per-abi
```

APKs will be at: `build/app/outputs/flutter-apk/`

---

## 🧪 Step 4: Test Release Build

```bash
# Install release APK on device
flutter install --release

# Or install specific ABI
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Test Checklist:
- [ ] App launches without crashes
- [ ] All navigation works correctly
- [ ] Voice recognition functions
- [ ] Audio plays correctly
- [ ] Progress saves and loads
- [ ] Back button behavior is correct

---

## 🏪 Step 5: Play Console Setup

### Create Developer Account
1. Go to https://play.google.com/console
2. Pay $25 one-time registration fee
3. Complete developer account verification

### Create App Listing
1. Click "Create app"
2. Enter app name: "WonderWorld Learning Adventure"
3. Select "App" and "Free"
4. Declare app is designed for children

### Configure "Designed for Families"
1. Go to "Policy and programs" → "App content"
2. Answer target audience questions:
   - Target age: 0-5, 6-8 (or your specific range)
   - Appeal to children: Yes
   - Content appropriate for children: Yes
3. Complete Teacher Approved questionnaire (optional)

---

## 📝 Step 6: Store Listing Content

### Required Assets:
- [ ] **App Icon**: 512x512 PNG
- [ ] **Feature Graphic**: 1024x500 PNG
- [ ] **Screenshots**: At least 2 phone screenshots (min 320px, max 3840px)
- [ ] **Short Description**: Max 80 characters
- [ ] **Full Description**: Max 4000 characters

### Suggested Short Description:
```
Fun learning for kids 2-8! Letters, numbers, and social skills adventures! 🌟
```

### Suggested Full Description:
```
🌟 WonderWorld Learning Adventure 🌟

The perfect educational companion for children ages 2-8! 

📚 LITERACY ZONE
• Trace letters with fun animations
• Learn phonics and letter sounds
• Build words and vocabulary
• Interactive story time

🔢 NUMERACY ZONE
• Learn counting with colorful objects
• Fun addition and subtraction games
• Explore shapes and patterns
• Math puzzles and challenges

❤️ SOCIAL-EMOTIONAL LEARNING
• Identify and express feelings
• Kindness activities
• Calm corner for relaxation
• Friendship stories

✨ KEY FEATURES
• Voice recognition for interactive feedback
• No ads or in-app purchases
• Works offline - learn anywhere!
• Progress tracking with stars and rewards
• Safe for children - no data collection

Built with love for curious young minds! 🎨
```

---

## 📄 Step 7: Privacy Policy

1. Host your privacy policy online (GitHub Pages, your website, etc.)
2. Add the URL to Play Console under "App content" → "Privacy policy"
3. The PRIVACY_POLICY.md file in this project can be converted to a webpage

---

## 🚦 Step 8: Submit for Review

1. Complete all required sections in Play Console
2. Upload your AAB file
3. Fill out content rating questionnaire
4. Complete data safety form:
   - Data collected: None
   - Data shared: None
   - Security practices: Encrypted storage
5. Submit for review

### Review Timeline:
- First submission: Up to 7 days
- Updates: Usually 1-3 days

---

## 🔄 Updating the App

For future updates:

1. Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # version: major.minor.patch+buildNumber
```

2. Build new bundle:
```bash
flutter build appbundle --release
```

3. Upload to Play Console and roll out

---

## 📱 Version Naming Convention

| Version | Meaning |
|---------|---------|
| 1.0.0+1 | Initial release |
| 1.0.1+2 | Bug fixes |
| 1.1.0+3 | New features |
| 2.0.0+4 | Major update |

---

## ⚠️ Common Issues

### Build fails with signing error
- Ensure `key.properties` exists and has correct paths
- Verify keystore file exists at specified location

### App rejected for children's policy
- Remove any third-party SDKs that collect data
- Ensure no ads or IAP are present
- Verify privacy policy is comprehensive

### ProGuard strips needed code
- Add keep rules to `proguard-rules.pro`
- Test release build thoroughly

---

## 📞 Support

For questions about this release process, refer to:
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Designed for Families](https://support.google.com/googleplay/android-developer/answer/9893335)

---

Good luck with your release! 🎉
