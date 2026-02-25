#!/bin/bash

# BrowserStack Integration Test Upload Script (Linux/Mac)
# This script builds and uploads APK files to BrowserStack

# ==========================================
# Configuration
# ==========================================

# Set your BrowserStack credentials here
# or pass them as environment variables: BS_USERNAME and BS_API_KEY
BS_USERNAME="${BS_USERNAME:-your_browserstack_username}"
BS_API_KEY="${BS_API_KEY:-your_browserstack_api_key}"

# BrowserStack API endpoints
BS_UPLOAD_APP_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app"
BS_UPLOAD_TEST_SUITE_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite"

# APK paths
APP_APK_PATH="android/build/app/outputs/apk/debug/app-debug.apk"
TEST_APK_PATH="android/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ==========================================
# Functions
# ==========================================

build_apks() {
    echo -e "${CYAN}📦 Building APK files...${NC}"
    
    # Navigate to android directory
    pushd android || exit 1
    
    # Build app debug APK
    echo -e "${YELLOW}🔨 Building app debug APK...${NC}"
    ./gradlew app:assembleDebug -Ptarget="../integration_test/app_test.dart"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to build app APK${NC}"
        popd || exit 1
        exit 1
    fi
    
    # Build test APK
    echo -e "${YELLOW}🔨 Building test APK...${NC}"
    ./gradlew app:assembleAndroidTest
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to build test APK${NC}"
        popd || exit 1
        exit 1
    fi
    
    popd || exit 1
    echo -e "${GREEN}✅ APK files built successfully${NC}"
}

upload_app_apk() {
    echo -e "${CYAN}📤 Uploading app APK to BrowserStack...${NC}"
    
    if [ ! -f "$APP_APK_PATH" ]; then
        echo -e "${RED}❌ App APK not found at $APP_APK_PATH${NC}"
        exit 1
    fi
    
    response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "$BS_UPLOAD_APP_URL" \
        -F "file=@$APP_APK_PATH" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to upload app APK: $response${NC}"
        exit 1
    fi
    
    app_url=$(echo "$response" | grep -o '"app_url":"[^"]*' | cut -d'"' -f4)
    
    echo -e "${GREEN}✅ App uploaded successfully${NC}"
    echo -e "${GREEN}App URL: $app_url${NC}"
    
    echo "$app_url"
}

upload_test_apk() {
    echo -e "${CYAN}📤 Uploading test APK to BrowserStack...${NC}"
    
    if [ ! -f "$TEST_APK_PATH" ]; then
        echo -e "${RED}❌ Test APK not found at $TEST_APK_PATH${NC}"
        exit 1
    fi
    
    response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "$BS_UPLOAD_TEST_SUITE_URL" \
        -F "file=@$TEST_APK_PATH" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to upload test APK: $response${NC}"
        exit 1
    fi
    
    test_suite_url=$(echo "$response" | grep -o '"test_suite_url":"[^"]*' | cut -d'"' -f4)
    
    echo -e "${GREEN}✅ Test APK uploaded successfully${NC}"
    echo -e "${GREEN}Test Suite URL: $test_suite_url${NC}"
    
    echo "$test_suite_url"
}

run_integration_tests() {
    local app_url=$1
    local test_suite_url=$2
    local devices=${3:-"Google Pixel 7-13.0"}
    
    echo -e "${CYAN}🚀 Running integration tests on BrowserStack...${NC}"
    
    # Convert devices string to JSON array
    IFS=',' read -ra device_array <<< "$devices"
    devices_json="["
    for device in "${device_array[@]}"; do
        devices_json+="\"$(echo $device | xargs)\","
    done
    devices_json="${devices_json%,}]"
    
    payload="{\"app\": \"$app_url\", \"testSuite\": \"$test_suite_url\", \"devices\": $devices_json}"
    
    response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
        -d "$payload" \
        -H "Content-Type: application/json" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to run tests: $response${NC}"
        exit 1
    fi
    
    build_id=$(echo "$response" | grep -o '"build_id":"[^"]*' | cut -d'"' -f4)
    
    echo -e "${GREEN}✅ Tests started successfully${NC}"
    echo -e "${GREEN}Build ID: $build_id${NC}"
    echo -e "${GREEN}View results at: https://app-automate.browserstack.com${NC}"
}

# ==========================================
# Main Execution
# ==========================================

echo -e "${MAGENTA}🚀 BrowserStack Integration Test Helper${NC}"
echo -e "${MAGENTA}======================================${NC}"
echo ""

# Check if credentials are set
if [ "$BS_USERNAME" = "your_browserstack_username" ] || [ "$BS_API_KEY" = "your_browserstack_api_key" ]; then
    echo -e "${YELLOW}⚠️  Please set BrowserStack credentials:${NC}"
    echo -e "${YELLOW}   export BS_USERNAME=your_username${NC}"
    echo -e "${YELLOW}   export BS_API_KEY=your_api_key${NC}"
    echo -e "${YELLOW}   Or edit this script with your credentials${NC}"
    exit 1
fi

# Build APKs
build_apks

# Upload APKs
app_url=$(upload_app_apk)
test_suite_url=$(upload_test_apk)

# Optional: Run tests
echo ""
read -p "Would you like to run the tests now? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${CYAN}Which devices would you like to test on? (comma-separated)${NC}"
    echo -e "${YELLOW}Examples: Google Pixel 7-13.0, Google Pixel 6-12.0, Samsung Galaxy S23-13.0${NC}"
    read -p "Devices [Google Pixel 7-13.0]: " devices
    
    if [ -z "$devices" ]; then
        devices="Google Pixel 7-13.0"
    fi
    
    run_integration_tests "$app_url" "$test_suite_url" "$devices"
fi

echo ""
echo -e "${GREEN}✨ All done! Check BrowserStack dashboard for results.${NC}"
