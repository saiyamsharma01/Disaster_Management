# App Icon and Name Setup Instructions

## Changes Made ✅

1. **App name changed from "cgc" to "SAHAAYA"** in:
    - Android: `android/app/src/main/AndroidManifest.xml`
    - iOS: `ios/Runner/Info.plist`
    - Web: `web/manifest.json`

2. **flutter_launcher_icons package added** and configured in `pubspec.yaml`

## Next Steps

### Step 1: Save the Logo Image

Save your SAHAAYA logo PNG image to:

```
assets/images/sahaaya_logo.png
```

**Important:** The image should be at least 1024x1024 pixels for best quality across all platforms.

### Step 2: Generate App Icons

After saving the logo, run the following command to generate all app icons:

```powershell
flutter pub run flutter_launcher_icons
```

This will automatically create:

- Android icons in various sizes (mipmap folders)
- iOS icons in the Assets.xcassets folder
- Adaptive icons for Android 8.0+

### Step 3: Build the APK

Once the icons are generated, build the APK with:

```powershell
flutter build apk --release
```

The APK will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Alternative: Build App Bundle (Recommended for Play Store)

For Google Play Store submission, use:

```powershell
flutter build appbundle --release
```

The bundle will be at:

```
build/app/outputs/bundle/release/app-release.aab
```

## Troubleshooting

If you get errors about missing image, make sure:

1. The logo file is exactly at `assets/images/sahaaya_logo.png`
2. The image is a valid PNG file
3. The image has a transparent or white background for best results

## Current Status

- ✅ App name changed to SAHAAYA
- ⏳ Logo needs to be saved to `assets/images/sahaaya_logo.png`
- ⏳ Icons need to be generated
- ⏳ APK needs to be built
