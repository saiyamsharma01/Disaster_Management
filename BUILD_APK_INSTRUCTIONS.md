# Building SAHAAYA APK - Complete Guide

## ✅ Completed Changes

I've successfully updated your app with the following changes:

### 1. **App Name Changed to SAHAAYA**

- ✅ Android (`AndroidManifest.xml`)
- ✅ iOS (`Info.plist`)
- ✅ Web (`manifest.json`)

### 2. **Icon Configuration Added**

- ✅ `flutter_launcher_icons` package installed
- ✅ Configuration added to `pubspec.yaml`
- ✅ Ready to generate icons from your logo

---

## 🚀 Quick Start (3 Steps)

### Step 1: Save Your Logo

1. **Save the SAHAAYA logo image** you provided in chat
2. **Place it at:** `assets/images/sahaaya_logo.png`
    - Right-click the image → Save As
    - Name it: `sahaaya_logo.png`
    - Location: Inside the `assets/images/` folder in your project

### Step 2: Run the Setup Script

Open PowerShell in your project directory and run:

```powershell
.\setup_icon_and_build.ps1
```

This automated script will:

- ✅ Check if your logo is in the correct location
- ✅ Generate all app icons automatically
- ✅ Build your APK (or App Bundle)
- ✅ Show you where the final APK is located

### Step 3: Install Your App

After the build completes, find your APK at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer this file to your Android device and install it!

---

## 📱 Manual Steps (Alternative)

If you prefer to run commands manually:

### 1. Save the logo

Place `sahaaya_logo.png` in `assets/images/`

### 2. Generate icons

```powershell
flutter pub run flutter_launcher_icons
```

### 3. Build APK

```powershell
flutter build apk --release
```

### 4. (Optional) Build for Play Store

```powershell
flutter build appbundle --release
```

---

## 📋 What's Been Changed

### Files Modified:

1. **`android/app/src/main/AndroidManifest.xml`**
    - Changed label from "cgc" to "SAHAAYA"

2. **`ios/Runner/Info.plist`**
    - Changed CFBundleDisplayName to "SAHAAYA"
    - Changed CFBundleName to "SAHAAYA"

3. **`web/manifest.json`**
    - Changed name to "SAHAAYA"
    - Updated description

4. **`pubspec.yaml`**
    - Added `flutter_launcher_icons` configuration
    - Set icon path to your logo

### Files Created:

- ✅ `setup_icon_and_build.ps1` - Automated build script
- ✅ `ICON_SETUP_INSTRUCTIONS.md` - Detailed instructions
- ✅ `BUILD_APK_INSTRUCTIONS.md` - This file

---

## 🎨 Icon Requirements

Your logo image should be:

- **Format:** PNG
- **Recommended Size:** 1024x1024 pixels (or larger)
- **Background:** Transparent or white works best
- Your logo already looks perfect for this! ✅

---

## 🔧 Troubleshooting

### Error: "Logo file not found"

- Make sure the file is named exactly: `sahaaya_logo.png`
- Check it's in the correct folder: `assets/images/`
- The path should be: `assets/images/sahaaya_logo.png`

### Error: "No connected devices"

- This is normal when building APK
- The APK file will still be created
- Just copy it to your phone to install

### Error: "Gradle build failed"

- Make sure you have enough disk space
- Run: `flutter clean` then try again

---

## 📦 Output Locations

### APK (for direct installation):

```
build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (for Play Store):

```
build/app/outputs/bundle/release/app-release.aab
```

---

## ✨ Next Steps After Building

1. **Transfer APK to your phone**
    - Use USB cable, email, or cloud storage

2. **Enable "Install from Unknown Sources"** on your Android device
    - Settings → Security → Unknown Sources

3. **Install the APK**
    - Open the APK file on your phone
    - Follow the installation prompts

4. **Launch SAHAAYA!** 🎉
    - Your app will now show up with the SAHAAYA name and logo!

---

## 📸 What You'll See

After installation, your app will display:

- **Name:** SAHAAYA (instead of "cgc")
- **Icon:** Your beautiful blue logo with the hand and plant design
- All functionality remains the same, just with the new branding!

---

**Need Help?** If you encounter any issues, check the troubleshooting section or reach out for
assistance.

**Ready to build?** Just run: `.\setup_icon_and_build.ps1`
