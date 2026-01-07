# PowerShell script to get Facebook Key Hash
# Run this script: .\get_facebook_keyhash.ps1

$keystore = "$env:USERPROFILE\.android\debug.keystore"
$alias = "androiddebugkey"
$password = "android"

Write-Host "Generating Facebook Key Hash..." -ForegroundColor Green
Write-Host ""

# Get the certificate
$cert = keytool -exportcert -alias $alias -keystore $keystore -storepass $password -keypass $password

# Convert to base64 and get SHA1
$certBytes = [System.Convert]::FromBase64String($cert)
$sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
$hash = $sha1.ComputeHash($certBytes)
$base64Hash = [System.Convert]::ToBase64String($hash)

Write-Host "Your Facebook Key Hash is:" -ForegroundColor Yellow
Write-Host $base64Hash -ForegroundColor Cyan
Write-Host ""
Write-Host "Add this to Facebook Developer Console:" -ForegroundColor Green
Write-Host "1. Go to https://developers.facebook.com/" -ForegroundColor White
Write-Host "2. Select your app (App ID: 1220475616667912)" -ForegroundColor White
Write-Host "3. Go to Settings > Basic" -ForegroundColor White
Write-Host "4. Scroll down to 'Key Hashes' section" -ForegroundColor White
Write-Host "5. Click 'Add Key Hash' and paste the hash above" -ForegroundColor White
Write-Host "6. Save changes" -ForegroundColor White

