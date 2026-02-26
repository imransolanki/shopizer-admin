#!/bin/bash

# API Diagnostic and Fix Tool with Authentication
# Usage: ./api-fix-tool.sh "api1" "api2" "api3"

BACKEND_URL="http://localhost:8080"
ADMIN_DIR="/Users/imran/Documents/imransolanki-github/ai_agentic_workshop/shopizer-admin"
USERNAME="admin@shopizer.com"
PASSWORD="password"
TOKEN=""

echo "=========================================="
echo "API Diagnostic and Fix Tool"
echo "=========================================="
echo ""

# Function to login and get JWT token
get_auth_token() {
    echo "🔐 Authenticating..."
    
    local response=$(curl -s -X POST "$BACKEND_URL/api/v1/private/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")
    
    TOKEN=$(echo "$response" | grep -o '"token":"[^"]*"' | sed 's/"token":"\(.*\)"/\1/')
    
    if [ -n "$TOKEN" ]; then
        echo "✅ Authentication successful"
        return 0
    else
        echo "❌ Authentication failed"
        echo "Response: $response"
        return 1
    fi
}

# Function to test API endpoint
test_api() {
    local endpoint=$1
    echo "Testing: $endpoint"
    
    if [ -n "$TOKEN" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$endpoint")
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint")
    fi
    
    if [ "$response" = "200" ]; then
        echo "✅ Status: $response - OK"
        return 0
    else
        echo "❌ Status: $response - FAILED"
        return 1
    fi
}

# Function to find correct endpoint
find_correct_endpoint() {
    local failed_endpoint=$1
    local base_url=$(echo "$failed_endpoint" | sed 's/\?.*//')
    
    echo ""
    echo "🔍 Searching for correct endpoint..."
    
    # Try common variations
    local variations=(
        "$base_url"
        "${base_url}s"  # plural
        "${base_url%s}" # singular
    )
    
    for variant in "${variations[@]}"; do
        local test_url="${variant}?count=10&lang=en&page=0"
        
        if [ -n "$TOKEN" ]; then
            local status=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$test_url")
        else
            local status=$(curl -s -o /dev/null -w "%{http_code}" "$test_url")
        fi
        
        if [ "$status" = "200" ]; then
            echo "✅ Found working endpoint: $variant"
            echo "   Full URL: $test_url"
            return 0
        fi
    done
    
    echo "❌ No working endpoint found"
    return 1
}

# Function to find service file using the endpoint
find_service_file() {
    local endpoint=$1
    local path=$(echo "$endpoint" | sed "s|$BACKEND_URL/api||" | sed 's/\?.*//' | sed 's|^/||')
    
    echo ""
    echo "🔍 Searching for service file using: $path"
    
    # Search for the endpoint in TypeScript files
    cd "$ADMIN_DIR" 2>/dev/null || return 1
    
    local results=$(grep -r "/$path" src --include="*.ts" 2>/dev/null | grep -v "node_modules" | head -5)
    
    if [ -n "$results" ]; then
        echo "📁 Found in files:"
        echo "$results" | while read -r line; do
            echo "   $line"
        done
        return 0
    else
        echo "❌ No service file found"
        return 1
    fi
}

# Function to suggest fix
suggest_fix() {
    local failed_endpoint=$1
    local working_endpoint=$2
    
    echo ""
    echo "🔧 Suggested Fix:"
    echo "   Replace: $failed_endpoint"
    echo "   With:    $working_endpoint"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <api-endpoint-1> [api-endpoint-2] ..."
    echo ""
    echo "Example:"
    echo "  $0 'http://localhost:8080/api/v1/product?count=200&lang=en&page=0'"
    echo ""
    exit 1
fi

# Authenticate first
get_auth_token
echo ""

failed_apis=()
fixed_apis=()

# Process each API
for api in "$@"; do
    echo ""
    echo "=========================================="
    echo "Processing: $api"
    echo "=========================================="
    
    if test_api "$api"; then
        echo "✅ API is working correctly"
        continue
    fi
    
    failed_apis+=("$api")
    
    # Try to find correct endpoint
    if find_correct_endpoint "$api"; then
        fixed_apis+=("$api")
    fi
    
    # Find service file
    find_service_file "$api"
    
    echo ""
done

# Summary
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total APIs tested: $#"
echo "Failed APIs: ${#failed_apis[@]}"
echo "Fixed APIs: ${#fixed_apis[@]}"
echo ""

if [ ${#failed_apis[@]} -gt 0 ]; then
    echo "Failed APIs:"
    for api in "${failed_apis[@]}"; do
        echo "  ❌ $api"
    done
fi

echo ""
echo "=========================================="
