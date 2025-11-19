#!/usr/bin/env bash

testCodeShiftMultipleFilesMatching() {
    echo "📚 Testing multiple files matching pattern"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create multiple matching files
    touch testCodeShiftOne.sh
    touch testCodeShiftTwo.sh
    touch testCodeShiftThree.md
    touch notMatching.sh
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "updated" >/dev/null 2>&1
    
    # Check all were renamed
    if [[ -f "$testCodeShift_dir/updatedOne.sh" ]] && \
       [[ -f "$testCodeShift_dir/updatedTwo.sh" ]] && \
       [[ -f "$testCodeShift_dir/updatedThree.md" ]] && \
       [[ -f "$testCodeShift_dir/notMatching.sh" ]]; then
      echo "✅ SUCCESS: All matching files renamed"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Not all files renamed correctly"
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
