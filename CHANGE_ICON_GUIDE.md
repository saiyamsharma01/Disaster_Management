# Complete Guide: Change App Icon to SAHAAYA Logo

## 🎯 Goal

Replace the default Flutter icon with your custom SAHAAYA logo (the blue circular design).

---

## ✅ Prerequisites

- [x] Your SAHAAYA logo image (the blue circular one)
- [x] Flutter project is set up
- [x] `flutter_launcher_icons` package already added (done!)

---

## 📝 Step-by-Step Instructions

### Step 1: Save Your Logo Image

1. **Locate your logo:**
    - Find the SAHAAYA logo image (the one you shared - blue circle with hand, plant, shield)

2. **Save it properly:**
    - Right-click the image
    - Click "Save Image As..." or "Download Image"
    - **File name:** `sahaaya_logo.png` (exactly this, no spaces, lowercase)
    - **Format:** PNG (keep it as PNG)

3. **Move to correct location:**
    - Open your project folder: `C:/flutter/flutterProject/nnnn/cgc`
    - Navigate to: `assets/images/`
    - Paste the `sahaaya_logo.png` file there

4. **Verify the path:**
   ```
   C:/flutter/flutterProject/nnnn/cgc/assets/images/sahaaya_logo.png
   ```

**Visual confirmation:**

```
cgc/
├── assets/
│   ├── images/
│   │   ├── sahaaya_logo.png  ← YOUR LOGO HERE
│   │   ├── login_pic.png
│   │   └── signup_pic.png
│   └── lotties/
```

---

### Step 2: Verify Configuration (Already Done!)

Your `pubspec.yaml` already has this configuration:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/sahaaya_logo.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/sahaaya_logo.png"
```

✅ This is already set up for you!

---

### Step 3: Generate Icons

Open **PowerShell** or **Command Prompt** in your project directory:

```powershell
# Navigate to your project
cd C:\flutter\flutterProject\nnnn\cgc

# Run the icon generator
flutter pub run flutter_launcher_icons
```

**Expected output:**

```
Creating default icons Android
Creating adaptive icons Android
Overwriting default iOS launcher icon with new icon
```

This creates icons in:

- ✅ `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- ✅ `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- ✅ `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- ✅ `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- ✅ `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- ✅ iOS icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

### Step 4: Clean Build (Important!)

```powershell
# Clean previous build
flutter clean

# Get dependencies again
flutter pub get
```

---

### Step 5: Rebuild APK with New Icon

```powershell
flutter build apk --release
```

**Wait for build to complete** (takes ~10-15 minutes)

---

### Step 6: Install & Test

1. **Locate your new APK:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Transfer to phone:**
    - Copy via USB cable
    - Or upload to Google Drive and download on phone
    - Or email to yourself

3. **Install on Android device:**
    - Tap the APK file
    - Allow installation from unknown sources if prompted
    - Install

4. **Check your home screen:**
    - 🎉 Your app should now show the SAHAAYA logo!
    - App name will be "SAHAAYA"

---

## 🔍 Troubleshooting

### Problem: "Could not find image file"

**Solution:**

```powershell
# Check if file exists
dir assets\images\sahaaya_logo.png
```

If file not found:

- Make sure the file name is exactly: `sahaaya_logo.png` (lowercase, no spaces)
- Make sure it's in `assets/images/` folder
- Check file extension is `.png` (not `.jpg` or `.PNG`)

---

### Problem: "Icon still shows Flutter default"

**Solution:**

```powershell
# Clean everything
flutter clean

# Generate icons again
flutter pub run flutter_launcher_icons

# Rebuild
flutter build apk --release
```

---

### Problem: "Icon looks stretched or pixelated"

**Solution:**

- Your original logo should be at least 1024x1024 pixels
- Make sure it's a square image
- Use PNG format with transparency or white background

---

## 🎨 Advanced: Custom Background Color

If you want to change the adaptive icon background color (currently white):

Edit `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/sahaaya_logo.png"
  adaptive_icon_background: "#4A90E2"  # Change this to your preferred color
  adaptive_icon_foreground: "assets/images/sahaaya_logo.png"
```

Then regenerate:

```powershell
flutter pub run flutter_launcher_icons
flutter build apk --release
```

---

## 📦 Alternative: Use Online Icon Generator

If the automated method doesn't work:

1. **Visit:** https://icon.kitchen or https://appicon.co

2. **Upload** your `sahaaya_logo.png`

3. **Select platforms:**
    - ✓ Android
    - ✓ iOS (if needed)

4. **Download** the generated pack

5. **Replace icons manually:**
    - Extract downloaded zip
    - Copy Android icons to `android/app/src/main/res/mipmap-*/`
    - Replace `ic_launcher.png` in each folder

6. **Rebuild:**
   ```powershell
   flutter build apk --release
   ```

---

## ✅ Quick Checklist

Before rebuilding, make sure:

- [ ] Logo saved as `sahaaya_logo.png` in `assets/images/`
- [ ] Logo is PNG format, at least 512x512 pixels
- [ ] Logo is square (equal width and height)
- [ ] `pubspec.yaml` has `flutter_launcher_icons` configuration
- [ ] Ran `flutter pub run flutter_launcher_icons`
- [ ] Ran `flutter clean`
- [ ] Ready to build APK

---

## 🚀 Quick Command Summary

```powershell
# 1. Save logo to assets/images/sahaaya_logo.png

# 2. Generate icons
flutter pub run flutter_launcher_icons

# 3. Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# 4. Install APK on device
# File location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📸 What You'll See

**Before:**

- Icon: Default Flutter logo (blue and white)
- Name: "cgc"

**After:**

- Icon: 🌱 SAHAAYA logo (blue circle with hand and plant)
- Name: "SAHAAYA"

---

**Questions?** If you encounter any issues, check the troubleshooting section or ask for help!
