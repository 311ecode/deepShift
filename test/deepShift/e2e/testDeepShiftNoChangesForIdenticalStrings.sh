#!/usr/bin/env bash
testDeepShiftNoChangesForIdenticalStrings() {
    echo "🔄 Testing no changes for identical strings"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    echo "same_string" > testDeepShift_file.txt
    local original_hash=$(md5sum testDeepShift_file.txt)
    
    # Run with identical strings
    deepShift "same_string" "same_string"
    local new_hash=$(md5sum testDeepShift_file.txt)
    
    if [[ "$original_hash" == "$new_hash" ]]; then
      echo "✅ SUCCESS: No changes made for identical strings"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: File modified with identical strings"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
