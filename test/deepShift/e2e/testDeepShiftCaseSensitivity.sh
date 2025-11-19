#!/usr/bin/env bash
testDeepShiftCaseSensitivity() {
    echo "🔠 Testing case sensitivity"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    echo "OldString" > testDeepShift1.txt
    echo "oldstring" > testDeepShift2.txt
    
    # Replace only exact case match
    deepShift "OldString" "NewString"
    
    if grep -q "NewString" testDeepShift1.txt && \
       grep -q "oldstring" testDeepShift2.txt; then
      echo "✅ SUCCESS: Case sensitivity maintained"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Case sensitivity not working"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
