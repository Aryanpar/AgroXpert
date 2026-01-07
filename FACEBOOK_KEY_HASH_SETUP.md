# Facebook Key Hash Setup Guide

## 🔑 Get Your Facebook Key Hash

### Method 1: Using Online Tool (Easiest)

1. **Get your certificate:**
   ```powershell
   keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android > cert.txt
   ```

2. **Go to:** https://developers.facebook.com/tools/debug/accesstoken/
   - Or use: https://www.base64encode.org/
   - Copy the certificate content from `cert.txt`
   - Convert to SHA1, then to Base64

### Method 2: Using Java (Recommended)

Run this command in PowerShell:

```powershell
$cert = keytool -exportcert -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
$certBytes = [System.Convert]::FromBase64String($cert)
$sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
$hash = $sha1.ComputeHash($certBytes)
$base64Hash = [System.Convert]::ToBase64String($hash)
Write-Host "Your Key Hash: $base64Hash"
```

### Method 3: Using Online Key Hash Generator

1. Go to: https://developers.facebook.com/tools/debug/accesstoken/
2. Or use: https://www.androidexample365.com/2016/03/how-to-generate-android-facebook-key.html
3. Upload your debug.keystore file
4. Get the key hash

## 📱 Add Key Hash to Facebook

1. **Go to Facebook Developers:**
   - https://developers.facebook.com/
   - Login with your Facebook account

2. **Select Your App:**
   - Find app with ID: **1220475616667912**
   - Or create a new app if needed

3. **Add Key Hash:**
   - Go to **Settings** → **Basic**
   - Scroll down to **"Key Hashes"** section
   - Click **"Add Key Hash"**
   - Paste your key hash
   - Click **Save Changes**

4. **For Release Build:**
   - You'll also need the release key hash
   - Generate it from your release keystore

## ⚠️ Important Notes

- **Debug Key Hash:** Use for testing during development
- **Release Key Hash:** Generate from your release keystore for production
- **Multiple Hashes:** You can add multiple key hashes
- **Wait Time:** Changes may take a few minutes to propagate

## 🔍 Quick Check

After adding the key hash, wait 2-3 minutes, then try Facebook login again.

