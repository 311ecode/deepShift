#!/usr/bin/env bash

testCodeShiftBasicFileDiscovery() {
    echo "🔍 Testing basic file discovery"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create testCodeShift files
    touch testCodeShiftFile1.sh
    touch testCodeShiftFile2.sh
    touch otherFile.sh
    
    cd "$original_pwd" || return 1
    
    # Capture output
    local output
    output=$(codeShift "$testCodeShift_dir" "testCodeShift" "new" 2>&1)
    
    rm -rf "$testCodeShift_dir"
    
    if echo "$output" | grep -q "Files found: 2"; then
      echo "✅ SUCCESS: Correctly discovered 2 matching files"
      return 0
    else
      echo "❌ ERROR: Expected to find 2 files, output: $output"
      return 1
    fi
}
