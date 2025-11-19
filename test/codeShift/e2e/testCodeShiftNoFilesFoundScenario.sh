#!/usr/bin/env bash

testCodeShiftNoFilesFoundScenario() {
    echo "🚫 Testing no files found scenario"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create files that don't match pattern
    touch unrelated1.sh
    touch unrelated2.sh
    touch other.md
    
    cd "$original_pwd" || return 1
    
    # Try to match non-existent pattern
    local output
    output=$(codeShift "$testCodeShift_dir" "nomatch" "replacement" 2>&1)
    local exit_code=$?
    
    rm -rf "$testCodeShift_dir"
    
    # Check for failure code AND the message (allowing for "files or directories")
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "No files.*found"; then
      echo "✅ SUCCESS: No files found scenario handled correctly"
      return 0
    else
      echo "❌ ERROR: Should have reported no files found"
      return 1
    fi
}
