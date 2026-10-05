# Sahaaya - Quick Start Guide 🚀

## ✅ App is Ready to Run!

Your Sahaaya app is configured with **Mapbox Maps** and ready to run on multiple platforms.

## 🎯 Choose Your Platform

### 1️⃣ **Chrome (Web) - Easiest!** ✨

```bash
flutter run -d chrome --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

Or in **VS Code**: Press `F5` → Select **"Flutter (Chrome)"**

### 2️⃣ **Mobile/Desktop**

```bash
flutter run --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

Or in **VS Code**: Press `F5` → Select **"Flutter (Mobile/Desktop)"**

### 3️⃣ **Edge Browser**

```bash
flutter run -d edge --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

Or in **VS Code**: Press `F5` → Select **"Flutter (Edge)"**

## 🗺️ Map Technology

The app uses **smart platform detection**:

| Platform | Map Technology | Style |
|----------|----------------|-------|
| Web (Chrome/Edge) | flutter_map | OpenStreetMap |
| Mobile (Android/iOS) | Mapbox SDK | Mapbox Streets |
| Desktop | flutter_map | OpenStreetMap |

**Both provide the same features** - just optimized for each platform!

## 📱 Features Working

✅ Interactive maps with zoom controls
✅ Custom markers and annotations  
✅ Real-time SOS alerts with Firestore
✅ Nearby shelter locations
✅ Emergency report visualization
✅ Circle overlays for danger zones
✅ Responsive design (mobile + desktop)
✅ Firebase authentication
✅ AI-powered chatbot
✅ Multi-language support

## 🎮 VS Code Launch Configurations

You have **3 pre-configured launch options** in `.vscode/launch.json`:

1. **Flutter (Mobile/Desktop)** - For Android, iOS, Windows, macOS, Linux
2. **Flutter (Chrome)** - For Google Chrome browser
3. **Flutter (Edge)** - For Microsoft Edge browser

Just press `F5` and select your target!

## 📦 What's Included

```
Your Project
├── Mapbox Maps SDK (mobile)
├── flutter_map (web)  
├── Firebase Integration
├── Google Generative AI
├── Multi-language Support
├── 4 Map-based Pages
└── Complete Documentation
```

## 📄 Documentation

- **`QUICKSTART_MAPBOX.md`** - Mapbox setup & usage
- **`WEB_SETUP.md`** - Running on Chrome/Edge
- **`MAPBOX_SETUP.md`** - Detailed Mapbox guide
- **`IMPLEMENTATION_SUMMARY.md`** - Technical details

## 🚨 First Time Setup

If this is your first time running the app:

```bash
# 1. Install dependencies
flutter pub get

# 2. Check Flutter setup
flutter doctor

# 3. Run on Chrome (easiest)
flutter run -d chrome --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

## 🎯 Page Routes

Once running, navigate to:

| Page | Route | Description |
|------|-------|-------------|
| Home | `/` | Landing page |
| Login | `/login` | User login |
| Dashboard | `/dashboard` | Main dashboard |
| Nearby Shelters | `/nearby_shelters` | 11 shelters with map |
| SOS Emergency | `/sos_page` | Real-time alerts |
| Report Map | `/report_map/1` | Emergency reports |
| IVR Outcome | `/ivr_outcome/1` | Crisis response |
| Chatbot | `/chatbot_care` | AI assistant |

## 💡 Pro Tips

### Hot Reload

- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### DevTools

Access at the URL shown in console (usually `http://127.0.0.1:9101`)

### Browser DevTools

Press `F12` to debug web app

## 🔍 Common Issues

### Issue: "Module not found"

```bash
flutter clean
flutter pub get
```

### Issue: Maps not showing

- Check internet connection
- Ensure access token is passed
- Check browser console (F12)

### Issue: Chrome closes immediately

- This is normal! Check the browser - app is running
- The terminal message is just a cleanup warning

## 🏗️ Build for Production

### Web

```bash
flutter build web --release --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

Output: `build/web/`

### Android APK

```bash
flutter build apk --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

### iOS

```bash
flutter build ios --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

## 🎉 That's It!

Your app is **production-ready** with:

- ✅ Professional maps (Mapbox + OpenStreetMap)
- ✅ Multi-platform support (Web + Mobile + Desktop)
- ✅ Real-time data (Firestore)
- ✅ AI features (Google Generative AI)
- ✅ Complete documentation

---

## 🚀 Ready to Launch?

**Quick Start Command:**

```bash
flutter run -d chrome --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

**Then navigate to:** `http://localhost:PORT` (shown in terminal)

**Have fun building! 🎨✨**
