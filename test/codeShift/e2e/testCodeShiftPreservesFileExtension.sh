#!/usr/bin/env bash

testCodeShiftPreservesFileExtension() {
    echo "📄 Testing file extension preservation"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create files with different extensions
    touch testCodeShiftFile.sh
    touch testCodeShiftFile.md
    touch testCodeShiftFile.js
    touch testCodeShiftFile.txt
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "new" >/dev/null 2>&1
    
    # Verify extensions preserved
    if [[ -f "$testCodeShift_dir/newFile.sh" ]] && \
       [[ -f "$testCodeShift_dir/newFile.md" ]] && \
       [[ -f "$testCodeShift_dir/newFile.js" ]] && \
       [[ -f "$testCodeShift_dir/newFile.txt" ]]; then
      echo "✅ SUCCESS: File extensions preserved"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Extensions not preserved correctly"
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
