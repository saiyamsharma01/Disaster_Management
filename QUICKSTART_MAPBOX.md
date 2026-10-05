# Mapbox Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

**Option A: Using VS Code (Recommended)**

- Open the project in VS Code
- Press `F5` or click the Run button
- The access token is automatically configured!

**Option B: Using Command Line**

```bash
flutter run --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

### 3. Navigate to Map Pages

Once the app is running, you can access these pages with Mapbox maps:

- **Nearby Shelters** - View shelter locations
- **Report Map** - See emergency, food/shelter, or volunteer reports
- **IVR Outcome** - Crisis response locations
- **SOS Page** - Real-time SOS alerts with danger zones

## 📱 Pages with Mapbox Integration

| Page | Feature | Route |
|------|---------|-------|
| Nearby Shelters | 11 shelter locations with capacity info | `/nearby_shelters` |
| Report Map | Emergency/Food/Volunteer reports | `/report_map/:choice` |
| IVR Outcome | Crisis response visualization | `/ivr_outcome/:choice` |
| SOS Emergency | Real-time alerts with hotspot detection | `/sos_page` |

## 🔧 Building for Release

### Android APK

```bash
flutter build apk --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

### iOS

```bash
flutter build ios --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

## ❓ Quick Troubleshooting

**Maps not showing?**

- Check your internet connection (maps need network)
- Ensure the access token is being passed correctly
- Try `flutter clean` and `flutter pub get`

**Build errors?**

- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter doctor`

**Import errors in IDE?**

- Restart your IDE
- Run `flutter pub get`
- Check `pubspec.yaml` for correct dependency

## 📚 More Information

- **Detailed Setup**: See `MAPBOX_SETUP.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **Mapbox Documentation**: https://docs.mapbox.com/

## 🎯 What's Included

✅ Mapbox Maps SDK v2.0.0
✅ 4 pages with interactive maps
✅ Custom markers and annotations
✅ Zoom controls
✅ Camera animations
✅ Real-time data (Firestore integration on SOS page)
✅ Responsive layouts
✅ Circle overlays for danger zones

## 🔐 Security Note

The access token in `.vscode/launch.json` is for development. For production:

- Use environment variables
- Set up token restrictions in Mapbox dashboard
- Never commit sensitive tokens to public repositories

---

**That's it! You're ready to explore maps in your app! 🗺️**
