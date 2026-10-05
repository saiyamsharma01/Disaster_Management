# Google Authentication Setup Guide

## Problem

Google Sign-In is not working properly due to missing or incorrect SHA certificate fingerprints in
Firebase Console.

## Solution: Complete SHA Key Setup

### Step 1: Get Your SHA Keys

#### For Debug Build (Development)

Open **PowerShell** or **Command Prompt** and run:

```powershell
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```

**Look for these lines in the output:**

```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**Copy both SHA-1 and SHA-256 values.**

#### For Release Build (Production - if you have a release keystore)

```powershell
keytool -list -v -keystore path\to\your-release-key.jks -alias your_alias_name
```

Enter your keystore password when prompted, then copy the SHA-1 and SHA-256.

---

### Step 2: Add SHA Keys to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click the ⚙️ **Settings** icon → **Project settings**
4. Scroll down to **Your apps** section
5. Find your Android app
6. Click **Add fingerprint** button
7. Paste your **SHA-1** fingerprint → Click **Save**
8. Click **Add fingerprint** again
9. Paste your **SHA-256** fingerprint → Click **Save**

**Important:** Add BOTH SHA-1 and SHA-256 for better compatibility!

---

### Step 3: Download Updated google-services.json

After adding the SHA keys:

1. Still in Firebase Console → **Project settings**
2. Scroll down to your Android app
3. Click **Download google-services.json** button
4. Replace the old file at: `android/app/google-services.json`

---

### Step 4: Configure OAuth 2.0 Client (Important!)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to: **APIs & Services** → **Credentials**
4. You should see OAuth 2.0 Client IDs listed

**Check if you have:**

- ✅ **Android client** (with your SHA-1)
- ✅ **Web client** (automatically created by Firebase)

If Android client is missing or has wrong SHA-1:

1. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
2. Select **Android**
3. Give it a name (e.g., "Android Client")
4. Enter your **Package name**: `com.example.sahaaya`
5. Paste your **SHA-1** certificate fingerprint
6. Click **Create**

---

### Step 5: Update Android Configuration

Check your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.example.sahaaya"  // Must match Firebase
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

**Important:** The `applicationId` must match the package name in Firebase!

---

### Step 6: Verify google-services.json

Open `android/app/google-services.json` and verify:

```json
{
  "project_info": {
    "project_id": "your-project-id"
  },
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.example.sahaaya"
        }
      },
      "oauth_client": [
        {
          "client_id": "xxxxx.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.example.sahaaya",
            "certificate_hash": "YOUR_SHA1_HERE"
          }
        },
        {
          "client_id": "xxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

**Check:**

- ✅ `package_name` matches everywhere
- ✅ `certificate_hash` matches your SHA-1
- ✅ Both client_type 1 (Android) and 3 (Web) exist

---

### Step 7: Clean and Rebuild

After updating google-services.json:

```powershell
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

---

## Quick Troubleshooting

### Issue: "PlatformException(sign_in_failed)"

**Solution:**

1. SHA-1 not added to Firebase → Add it (Step 2)
2. Wrong package name → Verify it matches everywhere
3. OAuth client not configured → Create Android OAuth client (Step 4)

### Issue: "DEVELOPER_ERROR" or "10:"

**Solution:**

1. SHA-1 mismatch between Firebase and OAuth consent screen
2. Download latest google-services.json after adding SHA keys
3. Create new OAuth 2.0 client ID with correct SHA-1

### Issue: Still not working after adding SHA keys

**Solution:**

1. Wait 5-10 minutes for Firebase/Google Cloud changes to propagate
2. Clear app data and cache
3. Uninstall and reinstall the app
4. Check you're using the correct Google account for testing

---

## Complete Checklist

- [ ] Get SHA-1 and SHA-256 from debug keystore
- [ ] Add both fingerprints to Firebase Console
- [ ] Download updated google-services.json
- [ ] Replace old google-services.json in android/app/
- [ ] Verify OAuth 2.0 Client ID exists with correct SHA-1
- [ ] Verify package name matches everywhere
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Rebuild and test the app
- [ ] Wait 5-10 minutes if it still doesn't work

---

## Commands Reference

### Get SHA-1 and SHA-256 (Debug)

```powershell
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```

### Get SHA-1 and SHA-256 (Release)

```powershell
keytool -list -v -keystore path\to\your-release-key.jks -alias your_alias_name
```

### Find Package Name

```powershell
# In android/app/build.gradle, look for:
applicationId "com.example.sahaaya"
```

---

## Important Notes

1. **SHA-1 is REQUIRED** for Google Sign-In on Android
2. You need SHA-1 for BOTH debug and release builds
3. SHA-256 is optional but recommended
4. Changes can take 5-10 minutes to propagate
5. Always download fresh google-services.json after changes
6. Uninstall app before testing after configuration changes

---

## Need Help?

If Google Sign-In still doesn't work:

1.
Check [Firebase Authentication Debug Logs](https://firebase.google.com/docs/auth/android/start#next_steps)
2. Enable detailed logging in your app
3. Verify you're using correct Google account
4. Check Firebase Console → Authentication → Sign-in method → Google is enabled
5. Make sure Google Sign-In is enabled in Firebase Console

---

## Current Configuration

**Package Name:** `com.example.sahaaya`
**Firebase Project:** (Check Firebase Console)
**Build Type:** Debug (during development)

After following all steps, your Google Sign-In should work correctly! 🎉
