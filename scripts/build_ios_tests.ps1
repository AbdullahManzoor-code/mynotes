# BrowserStack iOS Integration Test Builder (PowerShell)
# This script builds iOS integration tests for BrowserStack

# ==========================================
# Configuration
# ==========================================

$OUTPUT_DIR = "build/ios_integration"
$PRODUCT_DIR = "$OUTPUT_DIR/Build/Products"
$SCHEME = "Runner"
$WORKSPACE = "ios/Runner.xcworkspace"
$CONFIG = "Flutter/Release.xcconfig"

# ==========================================
# Functions
# ==========================================

function Check-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
    
    # Check for xcodebuild
    $xcodebuild = Get-Command xcodebuild -ErrorAction SilentlyContinue
    if (-not $xcodebuild) {
        Write-Host "❌ Xcode not found. Please install Xcode." -ForegroundColor Red
        exit 1
    }
    
    # Check for Flutter
    $flutter = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutter) {
        Write-Host "❌ Flutter not found. Please install Flutter." -ForegroundColor Red
        exit 1
    }
    
    # Check for workspace
    if (-not (Test-Path $WORKSPACE)) {
        Write-Host "❌ Xcode workspace not found at $WORKSPACE" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ All prerequisites met" -ForegroundColor Green
}

function Build-IOSTestPackage {
    Write-Host "🏗️  Building iOS test package..." -ForegroundColor Cyan
    
    # Create output directory
    New-Item -ItemType Directory -Force -Path $PRODUCT_DIR | Out-Null
    
    # Build for testing
    Write-Host "Building with xcodebuild..." -ForegroundColor Yellow
    
    Push-Location "ios"
    
    & xcodebuild `
        -workspace "$SCHEME.xcworkspace" `
        -scheme "$SCHEME" `
        -config Flutter/Release.xcconfig `
        -derivedDataPath "../$OUTPUT_DIR" `
        -sdk iphoneos `
        build-for-testing
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build iOS test package" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    
    Write-Host "✅ iOS test package built successfully" -ForegroundColor Green
}

function Find-XCTestRunFile {
    Write-Host "🔍 Finding xctestrun file..." -ForegroundColor Cyan
    
    $xctestrun = Get-ChildItem -Path $PRODUCT_DIR -Filter "*.xctestrun" -Recurse | Select-Object -First 1
    
    if (-not $xctestrun) {
        Write-Host "❌ xctestrun file not found" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Found: $($xctestrun.FullName)" -ForegroundColor Green
    return $xctestrun.FullName
}

function Create-TestPackageZip {
    param(
        [string]$XCTestRunPath
    )
    
    Write-Host "📦 Creating test package zip..." -ForegroundColor Cyan
    
    $xctestrunName = Split-Path -Leaf $XCTestRunPath
    $xctestrunDir = Split-Path -Parent $XCTestRunPath
    
    Push-Location $PRODUCT_DIR
    
    # Create zip file with test package
    $zipPath = Join-Path (Get-Location) "ios_test_package.zip"
    
    # Remove existing zip if it exists
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    # Create the zip using Compress-Archive
    Compress-Archive -Path @("Release-iphoneos", $XCTestRunPath) `
        -DestinationPath $zipPath -Force
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create zip file" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    
    Write-Host "✅ Test package created: $zipPath" -ForegroundColor Green
    return $zipPath
}

# ==========================================
# Main Execution
# ==========================================

Write-Host "🚀 iOS Integration Test Builder" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Check-Prerequisites

# Build test package
Build-IOSTestPackage

# Find xctestrun file
$xctestrun = Find-XCTestRunFile

# Create zip package
$zipFile = Create-TestPackageZip -XCTestRunPath $xctestrun

Write-Host ""
Write-Host "✨ Build complete!" -ForegroundColor Green
Write-Host "Test package: $zipFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Upload the zip file to BrowserStack using:"
Write-Host "   .\scripts\browserstack_upload_ios.ps1"
Write-Host "2. Or use the API directly with the zip file path"
