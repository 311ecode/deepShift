#!/usr/bin/env bash

testCodeShiftInvalidDirectoryHandling() {
    echo "⚠️ Testing invalid directory handling"
    
    local original_pwd=$(pwd)
    
    # Try with non-existent directory
    local output
    output=$(codeShift "/nonexistent/directory" "old" "new" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "ERROR.*Directory not found"; then
      echo "✅ SUCCESS: Invalid directory handled correctly"
      return 0
    else
      echo "❌ ERROR: Should have failed for invalid directory"
      return 1
    fi
}
