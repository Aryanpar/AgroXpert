# Generate Facebook Key Hash for Android
# Run: .\generate_keyhash.ps1

Write-Host "Generating Facebook Key Hash..." -ForegroundColor Green
Write-Host ""

$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $keystorePath)) {
    Write-Host "Error: Debug keystore not found at $keystorePath" -ForegroundColor Red
    exit 1
}

# Export certificate to temporary file
$tempCert = [System.IO.Path]::GetTempFileName()
keytool -exportcert -alias androiddebugkey -keystore $keystorePath -storepass android -keypass android -file $tempCert 2>&1 | Out-Null

if (Test-Path $tempCert) {
    # Read certificate
    $certBytes = [System.IO.File]::ReadAllBytes($tempCert)
    
    # Calculate SHA1
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    $hash = $sha1.ComputeHash($certBytes)
    
    # Convert to Base64
    $keyHash = [Convert]::ToBase64String($hash)
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Your Facebook Key Hash:" -ForegroundColor Yellow
    Write-Host $keyHash -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Green
    Write-Host "1. Go to: https://developers.facebook.com/apps/1220475616667912/settings/basic/" -ForegroundColor White
    Write-Host "2. Scroll to 'Key Hashes' section" -ForegroundColor White
    Write-Host "3. Click 'Add Key Hash'" -ForegroundColor White
    Write-Host "4. Paste the hash above" -ForegroundColor White
    Write-Host "5. Save changes" -ForegroundColor White
    Write-Host ""
    
    # Clean up
    Remove-Item $tempCert -ErrorAction SilentlyContinue
} else {
    Write-Host "Error: Failed to export certificate" -ForegroundColor Red
}

