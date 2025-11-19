#!/usr/bin/env bash

testCodeShiftMissingParametersHandling() {
    echo "⚠️ Testing missing parameters handling"
    
    # Test with no parameters
    local output1
    output1=$(codeShift 2>&1)
    local exit_code1=$?
    
    # Test with only directory
    local testCodeShift_dir=$(mktemp -d)
    local output2
    output2=$(codeShift "$testCodeShift_dir" 2>&1)
    local exit_code2=$?
    rm -rf "$testCodeShift_dir"
    
    if [[ $exit_code1 -ne 0 ]] && [[ $exit_code2 -ne 0 ]]; then
      echo "✅ SUCCESS: Missing parameters properly rejected"
      return 0
    else
      echo "❌ ERROR: Should have failed with missing parameters"
      return 1
    fi
}
