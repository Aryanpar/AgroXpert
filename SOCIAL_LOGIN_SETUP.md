# Google & Facebook Sign-In Setup Guide

## ✅ Code Fixes Completed

1. ✅ Updated `compileSdk` to 36 (fixes warnings)
2. ✅ Improved loading states for Google/Facebook buttons
3. ✅ Added better error handling with helpful messages
4. ✅ Fixed signup.dart to match login.dart improvements

## 🔧 Required Firebase Configuration

### Step 1: Add SHA-1 Fingerprint to Firebase

Your SHA-1 fingerprint:
```
9E:E9:DD:0E:04:54:C4:B0:E6:7B:2F:D8:27:B9:92:8E:C0:BD:3B:BC
```

**Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ttime-91668**
3. Click ⚙️ **Project Settings** → **Your apps**
4. Find Android app with package: **com.example.aa_new**
5. Click **Add fingerprint**
6. Paste SHA-1: `9E:E9:DD:0E:04:54:C4:B0:E6:7B:2F:D8:27:B9:92:8E:C0:BD:3B:BC`
7. Click **Save**

### Step 2: Enable Google Sign-In

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Click **Google**
3. Toggle **Enable**
4. Enter **Support email**
5. Click **Save**

### Step 3: Download New google-services.json

1. In Firebase Console → Project Settings → Your apps
2. Click **Download google-services.json**
3. Replace `android/app/google-services.json` with the new file
4. The new file should have `oauth_client` entries (not empty arrays)

## 📱 Facebook Configuration (Optional)

If you want Facebook login:

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use existing
3. Get your **App ID** and **Client Token**
4. Edit `android/app/src/main/res/values/strings.xml`:
   ```xml
   <string name="facebook_app_id">YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_ACTUAL_CLIENT_TOKEN</string>
   ```
5. In Firebase Console → Authentication → Sign-in method → Enable **Facebook**
6. Add Facebook App ID and App Secret in Firebase

## 🚀 After Configuration

Run these commands:
```bash
flutter clean
flutter pub get
flutter run
```

## ⚠️ Common Issues

### Google Sign-In Error 10 (DEVELOPER_ERROR)
- **Cause**: SHA-1 fingerprint not added or wrong google-services.json
- **Fix**: Follow Step 1 & 3 above

### Facebook Login Not Working
- **Cause**: Facebook App ID not configured
- **Fix**: Update `strings.xml` with actual Facebook App ID

### Empty oauth_client in google-services.json
- **Cause**: SHA-1 not added to Firebase
- **Fix**: Add SHA-1 fingerprint and download new google-services.json

## 📝 Notes

- The app package name is: `com.example.aa_new`
- Make sure you're testing on **Android device/emulator** (not Chrome/Web)
- After updating google-services.json, always run `flutter clean` before rebuilding

