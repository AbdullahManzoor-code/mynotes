#!/bin/bash

# BrowserStack iOS Integration Test Upload Script
# This script uploads iOS test packages to BrowserStack and runs tests

# ==========================================
# Configuration
# ==========================================

BS_USERNAME="${BS_USERNAME:-your_browserstack_username}"
BS_API_KEY="${BS_API_KEY:-your_browserstack_api_key}"

BS_UPLOAD_TEST_PACKAGE_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/test-package"
BS_RUN_TESTS_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/build"

# Test package path
TEST_PACKAGE_ZIP="${1:-build/ios_integration/Build/Products/ios_test_package.zip}"

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

check_credentials() {
    if [ "$BS_USERNAME" = "your_browserstack_username" ] || [ "$BS_API_KEY" = "your_browserstack_api_key" ]; then
        echo -e "${YELLOW}⚠️  Please set BrowserStack credentials:${NC}"
        echo -e "${YELLOW}   export BS_USERNAME=your_username${NC}"
        echo -e "${YELLOW}   export BS_API_KEY=your_api_key${NC}"
        exit 1
    fi
}

upload_test_package() {
    echo -e "${CYAN}📤 Uploading iOS test package to BrowserStack...${NC}"
    
    if [ ! -f "$TEST_PACKAGE_ZIP" ]; then
        echo -e "${RED}❌ Test package not found at $TEST_PACKAGE_ZIP${NC}"
        echo -e "${YELLOW}Run ./scripts/build_ios_tests.sh first${NC}"
        exit 1
    fi
    
    response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "$BS_UPLOAD_TEST_PACKAGE_URL" \
        -F "file=@$TEST_PACKAGE_ZIP" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to upload test package: $response${NC}"
        exit 1
    fi
    
    test_package_url=$(echo "$response" | grep -o '"test_package_url":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$test_package_url" ]; then
        echo -e "${RED}❌ Upload failed. Response: $response${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Test package uploaded successfully${NC}"
    echo -e "${GREEN}Test Package URL: $test_package_url${NC}"
    
    echo "$test_package_url"
}

run_tests() {
    local test_package_url=$1
    local devices=${2:-"iPhone 14-17.4"}
    
    echo -e "${CYAN}🚀 Running iOS integration tests on BrowserStack...${NC}"
    
    # Convert devices string to JSON array
    IFS=',' read -ra device_array <<< "$devices"
    devices_json="["
    for device in "${device_array[@]}"; do
        devices_json+="\"$(echo $device | xargs)\","
    done
    devices_json="${devices_json%,}]"
    
    payload="{\"testPackage\": \"$test_package_url\", \"devices\": $devices_json, \"networkLogs\": \"true\", \"deviceLogs\": \"true\"}"
    
    response=$(curl -u "$BS_USERNAME:$BS_API_KEY" \
        -X POST "$BS_RUN_TESTS_URL" \
        -d "$payload" \
        -H "Content-Type: application/json" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to run tests: $response${NC}"
        exit 1
    fi
    
    build_id=$(echo "$response" | grep -o '"build_id":"[^"]*' | cut -d'"' -f4)
    message=$(echo "$response" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$build_id" ]; then
        echo -e "${RED}❌ Test execution failed. Response: $response${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Tests started successfully${NC}"
    echo -e "${GREEN}Build ID: $build_id${NC}"
    echo -e "${GREEN}View results at: https://app-automate.browserstack.com${NC}"
}

# ==========================================
# Main Execution
# ==========================================

echo -e "${MAGENTA}🚀 BrowserStack iOS Integration Test Uploader${NC}"
echo -e "${MAGENTA}===========================================${NC}"
echo ""

check_credentials

# Upload test package
test_package_url=$(upload_test_package)

# Ask if user wants to run tests
echo ""
read -p "Would you like to run the tests now? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${CYAN}Which devices would you like to test on? (comma-separated)${NC}"
    echo -e "${YELLOW}Examples: iPhone 14-17.4, iPhone 13-16.5, iPad Pro 12.9-17.4${NC}"
    read -p "Devices [iPhone 14-17.4]: " devices
    
    if [ -z "$devices" ]; then
        devices="iPhone 14-17.4"
    fi
    
    run_tests "$test_package_url" "$devices"
fi

echo ""
echo -e "${GREEN}✨ All done! Check BrowserStack dashboard for results.${NC}"
