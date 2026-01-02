// Android Manifest for WonderWorld Learning Adventure
// Location: android/app/src/main/AndroidManifest.xml

/*
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="WonderWorld"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <!-- For audio playback -->
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
</manifest>
*/

// This file provides Android configuration notes.
// After running `flutter create .` in the frontend folder, 
// the actual AndroidManifest.xml will be generated.

const androidConfig = '''
WonderWorld Learning Adventure - Android Configuration

1. App Name: WonderWorld
2. Package Name: com.wonderworld.learning
3. Target SDK: 34 (Android 14)
4. Minimum SDK: 21 (Android 5.0)

Required Permissions:
- INTERNET (API calls)
- ACCESS_NETWORK_STATE (network check)
- MODIFY_AUDIO_SETTINGS (sound effects)

App Icon Guidelines:
- Foreground: Star emoji with gradient background
- Background: Purple (#6B4EFF)
- Create adaptive icons for Android 8+

Splash Screen:
- Use Android 12 splash screen API
- Purple background with star animation
''';
