#!/usr/bin/env bash

testCodeShiftBasicRenaming() {
    echo "📁 Testing basic file renaming"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create testCodeShift file with content
    echo "testCodeShift content" > testCodeShiftExample.sh
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "new" >/dev/null 2>&1
    
    # Check if file was renamed
    if [[ -f "$testCodeShift_dir/newExample.sh" ]] && [[ ! -f "$testCodeShift_dir/testCodeShiftExample.sh" ]]; then
      echo "✅ SUCCESS: File renamed correctly"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: File not renamed properly"
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
