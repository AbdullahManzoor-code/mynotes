#!/bin/bash

# BrowserStack iOS Integration Test Build Script
# This script builds iOS integration tests for BrowserStack

# ==========================================
# Configuration
# ==========================================

OUTPUT_DIR="build/ios_integration"
PRODUCT_DIR="$OUTPUT_DIR/Build/Products"
SCHEME="Runner"
WORKSPACE="ios/Runner.xcworkspace"
CONFIG="Flutter/Release.xcconfig"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==========================================
# Functions
# ==========================================

check_prerequisites() {
    echo -e "${CYAN}🔍 Checking prerequisites...${NC}"
    
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${RED}❌ Xcode not found. Please install Xcode.${NC}"
        exit 1
    fi
    
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found. Please install Flutter.${NC}"
        exit 1
    fi
    
    if [ ! -f "$WORKSPACE" ]; then
        echo -e "${RED}❌ Xcode workspace not found at $WORKSPACE${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
}

build_ios_test_package() {
    echo -e "${CYAN}🏗️  Building iOS test package...${NC}"
    
    # Create output directory
    mkdir -p "$PRODUCT_DIR"
    
    # Build for testing
    echo -e "${YELLOW}Building with xcodebuild...${NC}"
    
    pushd ios || exit 1
    
    xcodebuild \
        -workspace "$SCHEME.xcworkspace" \
        -scheme "$SCHEME" \
        -config Flutter/Release.xcconfig \
        -derivedDataPath "$OUTPUT_DIR" \
        -sdk iphoneos \
        build-for-testing
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to build iOS test package${NC}"
        popd || exit 1
        exit 1
    fi
    
    popd || exit 1
    
    echo -e "${GREEN}✅ iOS test package built successfully${NC}"
}

find_xctestrun_file() {
    echo -e "${CYAN}🔍 Finding xctestrun file...${NC}"
    
    # Find the xctestrun file
    XCTESTRUN=$(find "$PRODUCT_DIR" -name "*.xctestrun" | head -1)
    
    if [ -z "$XCTESTRUN" ]; then
        echo -e "${RED}❌ xctestrun file not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Found: $XCTESTRUN${NC}"
}

create_test_package_zip() {
    echo -e "${CYAN}📦 Creating test package zip...${NC}"
    
    XCTESTRUN_FILENAME=$(basename "$XCTESTRUN")
    XCTESTRUN_DIR=$(dirname "$XCTESTRUN")
    
    # Create zip file with test package
    pushd "$PRODUCT_DIR" || exit 1
    
    zip -r "ios_test_package.zip" "Release-iphoneos" "$XCTESTRUN_FILENAME"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to create zip file${NC}"
        popd || exit 1
        exit 1
    fi
    
    TEST_PACKAGE_ZIP="$(pwd)/ios_test_package.zip"
    
    popd || exit 1
    
    echo -e "${GREEN}✅ Test package created: $TEST_PACKAGE_ZIP${NC}"
}

# ==========================================
# Main Execution
# ==========================================

echo -e "${CYAN}🚀 iOS Integration Test Builder${NC}"
echo -e "${CYAN}================================${NC}"
echo ""

# Check prerequisites
check_prerequisites

# Build test package
build_ios_test_package

# Find xctestrun file
find_xctestrun_file

# Create zip package
create_test_package_zip

echo ""
echo -e "${GREEN}✨ Build complete!${NC}"
echo -e "${GREEN}Test package: $TEST_PACKAGE_ZIP${NC}"
echo ""
echo "Next steps:"
echo "1. Upload the zip file to BrowserStack using:"
echo "   ./scripts/browserstack_upload_ios.sh"
echo "2. Or use the API directly with the zip file path"
