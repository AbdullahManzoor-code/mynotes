# BrowserStack iOS Integration Test Upload Script (PowerShell)
# This script uploads iOS test packages to BrowserStack and runs tests

# ==========================================
# Configuration
# ==========================================

$BS_USERNAME = $env:BS_USERNAME || "your_browserstack_username"
$BS_API_KEY = $env:BS_API_KEY || "your_browserstack_api_key"

$BS_UPLOAD_TEST_PACKAGE_URL = "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/test-package"
$BS_RUN_TESTS_URL = "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/build"

# Test package path
$TEST_PACKAGE_ZIP = if ($args.Count -gt 0) { $args[0] } else { "build/ios_integration/Build/Products/ios_test_package.zip" }

# ==========================================
# Functions
# ==========================================

function Check-Credentials {
    if ($BS_USERNAME -eq "your_browserstack_username" -or $BS_API_KEY -eq "your_browserstack_api_key") {
        Write-Host "⚠️  Please set BrowserStack credentials:" -ForegroundColor Yellow
        Write-Host "   `$env:BS_USERNAME = 'your_username'" -ForegroundColor Yellow
        Write-Host "   `$env:BS_API_KEY = 'your_api_key'" -ForegroundColor Yellow
        exit 1
    }
}

function Upload-TestPackage {
    Write-Host "📤 Uploading iOS test package to BrowserStack..." -ForegroundColor Cyan
    
    if (-not (Test-Path $TEST_PACKAGE_ZIP)) {
        Write-Host "❌ Test package not found at $TEST_PACKAGE_ZIP" -ForegroundColor Red
        Write-Host "⚠️  Run .\scripts\build_ios_tests.ps1 first" -ForegroundColor Yellow
        exit 1
    }
    
    try {
        $cred = New-Object System.Management.Automation.PSCredential(
            $BS_USERNAME, 
            (ConvertTo-SecureString $BS_API_KEY -AsPlainText -Force)
        )
        
        $response = Invoke-RestMethod -Uri $BS_UPLOAD_TEST_PACKAGE_URL `
            -Method Post `
            -Authentication Basic `
            -Credential $cred `
            -Form @{file = Get-Item $TEST_PACKAGE_ZIP}
        
        Write-Host "✅ Test package uploaded successfully" -ForegroundColor Green
        Write-Host "Test Package URL: $($response.test_package_url)" -ForegroundColor Green
        
        return $response.test_package_url
    }
    catch {
        Write-Host "❌ Failed to upload test package: $_" -ForegroundColor Red
        exit 1
    }
}

function Run-Tests {
    param(
        [string]$TestPackageUrl,
        [string]$Devices = "iPhone 14-17.4"
    )
    
    Write-Host "🚀 Running iOS integration tests on BrowserStack..." -ForegroundColor Cyan
    
    # Parse devices
    $deviceList = $Devices.Split(",") | ForEach-Object { $_.Trim() }
    $devicesJson = @($deviceList) | ConvertTo-Json
    
    $payload = @{
        testPackage = $TestPackageUrl
        devices = $deviceList
        networkLogs = "true"
        deviceLogs = "true"
    } | ConvertTo-Json
    
    try {
        $cred = New-Object System.Management.Automation.PSCredential(
            $BS_USERNAME, 
            (ConvertTo-SecureString $BS_API_KEY -AsPlainText -Force)
        )
        
        $response = Invoke-RestMethod -Uri $BS_RUN_TESTS_URL `
            -Method Post `
            -Authentication Basic `
            -Credential $cred `
            -ContentType "application/json" `
            -Body $payload
        
        Write-Host "✅ Tests started successfully" -ForegroundColor Green
        Write-Host "Build ID: $($response.build_id)" -ForegroundColor Green
        Write-Host "View results at: https://app-automate.browserstack.com" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to run tests: $_" -ForegroundColor Red
        exit 1
    }
}

# ==========================================
# Main Execution
# ==========================================

Write-Host "🚀 BrowserStack iOS Integration Test Uploader" -ForegroundColor Magenta
Write-Host "===========================================" -ForegroundColor Magenta
Write-Host ""

Check-Credentials

# Upload test package
$testPackageUrl = Upload-TestPackage

# Ask if user wants to run tests
Write-Host ""
Read-Host -Prompt "Would you like to run the tests now? (Y/n)" -OutVariable response | Out-Null
$response = if ([string]::IsNullOrWhiteSpace($response)) { "Y" } else { $response }

if ($response -ne "n" -and $response -ne "N") {
    Write-Host "Which devices would you like to test on? (comma-separated)" -ForegroundColor Cyan
    Write-Host "Examples: iPhone 14-17.4, iPhone 13-16.5, iPad Pro 12.9-17.4" -ForegroundColor Yellow
    $devices = Read-Host -Prompt "Devices [iPhone 14-17.4]"
    
    if ([string]::IsNullOrWhiteSpace($devices)) {
        $devices = "iPhone 14-17.4"
    }
    
    Run-Tests -TestPackageUrl $testPackageUrl -Devices $devices
}

Write-Host ""
Write-Host "✨ All done! Check BrowserStack dashboard for results." -ForegroundColor Green
