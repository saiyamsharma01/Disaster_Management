# 🚀 Quick SHA Keys Setup (2 Minutes)

## Step 1: Get Your SHA Keys

### Option A: Double-click the batch file (EASIEST!)

```
📁 Double-click: get_sha_keys.bat
```

### Option B: Run PowerShell script

```powershell
.\get_sha_keys.ps1
```

### Option C: Manual commands

**PowerShell:**

```powershell
cd android
.\gradlew.bat signingReport
```

**Command Prompt:**

```cmd
cd android
gradlew.bat signingReport
```

---

## Step 2: Copy SHA Values

Look for this in the output:

```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**Copy both SHA1 and SHA-256 values!**

---

## Step 3: Add to Firebase Console

1. Open: https://console.firebase.google.com/
2. Select project: **fir-tutorial-826a8**
3. Click ⚙️ → **Project settings**
4. Scroll to **Your apps** → Find Android app
5. Click **"Add fingerprint"**
6. Paste **SHA-1** → Click **Save**
7. Click **"Add fingerprint"** again
8. Paste **SHA-256** → Click **Save**

---

## Step 4: Create Android OAuth Client

1. Open: https://console.cloud.google.com/
2. Select: **fir-tutorial-826a8**
3. Go to: **APIs & Services** → **Credentials**
4. Click **"+ CREATE CREDENTIALS"** → **OAuth client ID**
5. Select: **Android**
6. Name: `Android Debug Client`
7. Package name: **`com.example.cgc`**
8. SHA-1 fingerprint: Paste the SHA-1 from Step 2
9. Click **Create**

---

## Step 5: Download & Replace google-services.json

1. Back to Firebase Console
2. **Project settings** → Your Android app
3. Click **"Download google-services.json"**
4. Replace file at: `android/app/google-services.json`

---

## Step 6: Clean & Rebuild

```powershell
flutter clean
flutter pub get
flutter run
```

---

## ✅ That's It!

Google Sign-In should now work! 🎉

---

## 🔧 Quick Troubleshooting

**If it still doesn't work:**

1. Wait 5-10 minutes (Google Cloud changes take time to propagate)
2. Uninstall the app completely
3. Reinstall: `flutter run`
4. Make sure you added BOTH SHA-1 and SHA-256 to Firebase
5. Verify package name is `com.example.cgc` everywhere

---

## 📝 Your Configuration

- **Package Name:** `com.example.cgc`
- **Firebase Project:** `fir-tutorial-826a8`
- **Build Type:** Debug

---

## 🆘 Still Having Issues?

Check:

- ✅ Firebase Console → Authentication → Sign-in method → Google is **Enabled**
- ✅ Both SHA-1 and SHA-256 are added to Firebase
- ✅ Android OAuth client exists in Google Cloud Console
- ✅ Package name matches everywhere: `com.example.cgc`
- ✅ You waited 5-10 minutes after making changes
- ✅ App was completely uninstalled and reinstalled

---

**Need help?** Check `GOOGLE_AUTH_SETUP_GUIDE.md` for detailed troubleshooting.
