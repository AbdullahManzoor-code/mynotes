# BrowserStack Integration Test Upload Script
# This script builds and uploads APK files to BrowserStack

# ==========================================
# Configuration
# ==========================================

# Set your BrowserStack credentials here
# or pass them as environment variables: BS_USERNAME and BS_API_KEY
$BS_USERNAME = $env:BS_USERNAME || "abdullahmanzoorc_P4flur"
$BS_API_KEY = $env:BS_API_KEY || "Yfzfd8B4xT2QyP8krsYV"

# BrowserStack API endpoints
$BS_UPLOAD_APP_URL = "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app"
$BS_UPLOAD_TEST_SUITE_URL = "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite"

# APK paths
$APP_APK_PATH = "android/build/app/outputs/apk/debug/app-debug.apk"
$TEST_APK_PATH = "android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"

# ==========================================
# Functions
# ==========================================

function Build-APKs {
    Write-Host "📦 Building APK files..." -ForegroundColor Cyan
    
    # Navigate to android directory
    Push-Location android
    
    # Build app debug APK
    Write-Host "🔨 Building app debug APK..." -ForegroundColor Yellow
    & ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build app APK" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    # Build test APK
    Write-Host "🔨 Building test APK..." -ForegroundColor Yellow
    & ./gradlew app:assembleAndroidTest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build test APK" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    Write-Host "✅ APK files built successfully" -ForegroundColor Green
}

function Upload-AppAPK {
    Write-Host "📤 Uploading app APK to BrowserStack..." -ForegroundColor Cyan
    
    if (-not (Test-Path $APP_APK_PATH)) {
        Write-Host "❌ App APK not found at $APP_APK_PATH" -ForegroundColor Red
        exit 1
    }
    
    try {
        $response = Invoke-RestMethod -Uri $BS_UPLOAD_APP_URL `
            -Method Post `
            -Authentication Basic `
            -Credential (New-Object System.Management.Automation.PSCredential($BS_USERNAME, (ConvertTo-SecureString $BS_API_KEY -AsPlainText -Force))) `
            -Form @{file = Get-Item $APP_APK_PATH}
        
        Write-Host "✅ App uploaded successfully" -ForegroundColor Green
        Write-Host "App URL: $($response.app_url)" -ForegroundColor Green
        Write-Host "Expiry: $($response.expiry)" -ForegroundColor Green
        
        return $response.app_url
    }
    catch {
        Write-Host "❌ Failed to upload app APK: $_" -ForegroundColor Red
        exit 1
    }
}

function Upload-TestAPK {
    Write-Host "📤 Uploading test APK to BrowserStack..." -ForegroundColor Cyan
    
    if (-not (Test-Path $TEST_APK_PATH)) {
        Write-Host "❌ Test APK not found at $TEST_APK_PATH" -ForegroundColor Red
        exit 1
    }
    
    try {
        $response = Invoke-RestMethod -Uri $BS_UPLOAD_TEST_SUITE_URL `
            -Method Post `
            -Authentication Basic `
            -Credential (New-Object System.Management.Automation.PSCredential($BS_USERNAME, (ConvertTo-SecureString $BS_API_KEY -AsPlainText -Force))) `
            -Form @{file = Get-Item $TEST_APK_PATH}
        
        Write-Host "✅ Test APK uploaded successfully" -ForegroundColor Green
        Write-Host "Test Suite URL: $($response.test_suite_url)" -ForegroundColor Green
        Write-Host "Expiry: $($response.expiry)" -ForegroundColor Green
        
        return $response.test_suite_url
    }
    catch {
        Write-Host "❌ Failed to upload test APK: $_" -ForegroundColor Red
        exit 1
    }
}

function Run-IntegrationTests {
    param (
        [string]$AppUrl,
        [string]$TestSuiteUrl,
        [string[]]$Devices = @("Google Pixel 7-13.0")
    )
    
    Write-Host "🚀 Running integration tests on BrowserStack..." -ForegroundColor Cyan
    
    $testPayload = @{
        app = $AppUrl
        testSuite = $TestSuiteUrl
        devices = $Devices
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" `
            -Method Post `
            -Authentication Basic `
            -Credential (New-Object System.Management.Automation.PSCredential($BS_USERNAME, (ConvertTo-SecureString $BS_API_KEY -AsPlainText -Force))) `
            -ContentType "application/json" `
            -Body $testPayload
        
        Write-Host "✅ Tests started successfully" -ForegroundColor Green
        Write-Host "Build ID: $($response.build_id)" -ForegroundColor Green
        Write-Host "View results at: https://app-automate.browserstack.com" -ForegroundColor Green
        
        return $response.build_id
    }
    catch {
        Write-Host "❌ Failed to run tests: $_" -ForegroundColor Red
        exit 1
    }
}

# ==========================================
# Main Execution
# ==========================================

Write-Host "🚀 BrowserStack Integration Test Helper" -ForegroundColor Magenta
Write-Host "======================================" -ForegroundColor Magenta
Write-Host ""

# Check if credentials are set
if ($BS_USERNAME -eq "your_browserstack_username") {
    Write-Host "⚠️  Please set BrowserStack credentials:" -ForegroundColor Yellow
    Write-Host "   Set environment variable BS_USERNAME" -ForegroundColor Yellow
    Write-Host "   Set environment variable BS_API_KEY" -ForegroundColor Yellow
    Write-Host "   Or edit this script with your credentials" -ForegroundColor Yellow
    exit 1
}

# Build APKs
Build-APKs

# Upload APKs
$appUrl = Upload-AppAPK
$testSuiteUrl = Upload-TestAPK

# Optional: Run tests
Write-Host ""
Write-Host "Would you like to run the tests now? (Y/n)" -ForegroundColor Cyan
$response = Read-Host
if ($response -ne "n") {
    Write-Host "Which devices would you like to test on? (comma-separated)" -ForegroundColor Cyan
    Write-Host "Examples: Google Pixel 7-13.0, Google Pixel 6-12.0, Samsung Galaxy S23-13.0" -ForegroundColor Gray
    $deviceInput = Read-Host "Devices [Google Pixel 7-13.0]"
    
    if ([string]::IsNullOrWhiteSpace($deviceInput)) {
        $devices = @("Google Pixel 7-13.0")
    } else {
        $devices = $deviceInput.Split(",") | ForEach-Object { $_.Trim() }
    }
    
    $buildId = Run-IntegrationTests -AppUrl $appUrl -TestSuiteUrl $testSuiteUrl -Devices $devices
}

Write-Host ""
Write-Host "✨ All done! Check BrowserStack dashboard for results." -ForegroundColor Green
