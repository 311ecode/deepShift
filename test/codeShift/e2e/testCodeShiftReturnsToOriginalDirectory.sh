#!/usr/bin/env bash

testCodeShiftReturnsToOriginalDirectory() {
    echo "🏠 Testing return to original directory"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    
    # Create testCodeShift file
    touch "$testCodeShift_dir/testCodeShiftFile.sh"
    
    # Record pwd before
    local before_pwd=$(pwd)
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "new" >/dev/null 2>&1
    
    # Record pwd after
    local after_pwd=$(pwd)
    
    rm -rf "$testCodeShift_dir"
    
    if [[ "$before_pwd" == "$after_pwd" ]]; then
      echo "✅ SUCCESS: Returned to original directory"
      return 0
    else
      echo "❌ ERROR: Not in original directory. Before: $before_pwd, After: $after_pwd"
      return 1
    fi
}
