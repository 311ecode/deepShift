#!/usr/bin/env bash

testCodeShiftPartialStringMatching() {
    echo "🔤 Testing partial string matching"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create files with pattern at different positions - ALL LOWERCASE
    touch prefixtestCodeShift.sh      # pattern at end
    touch testCodeShiftSuffix.sh      # pattern at start
    touch pretestCodeShiftings.sh     # pattern in middle
    touch unrelated.sh       # no pattern
    
    [[ -n "$DEBUG" ]] && echo "DEBUG: Created testCodeShift files:" >&2
    [[ -n "$DEBUG" ]] && ls -1 >&2
    
    cd "$original_pwd" || return 1
    
    # Run batch rename searching for 'testCodeShift'
    [[ -n "$DEBUG" ]] && echo "DEBUG: Running codeShift with pattern 'testCodeShift' → 'check'" >&2
    codeShift "$testCodeShift_dir" "testCodeShift" "check" >/dev/null 2>&1
    
    [[ -n "$DEBUG" ]] && echo "DEBUG: After rename, files in $testCodeShift_dir:" >&2
    [[ -n "$DEBUG" ]] && ls -1 "$testCodeShift_dir" >&2
    
    # Verify partial matches work
    if [[ -f "$testCodeShift_dir/prefixcheck.sh" ]] && \
       [[ -f "$testCodeShift_dir/checkSuffix.sh" ]] && \
       [[ -f "$testCodeShift_dir/precheckings.sh" ]] && \
       [[ -f "$testCodeShift_dir/unrelated.sh" ]]; then
      echo "✅ SUCCESS: Partial string matching works"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Partial matching failed"
      echo "   Expected files:"
      echo "     prefixcheck.sh: $(testCodeShift -f "$testCodeShift_dir/prefixcheck.sh" && echo '✓' || echo '✗')"
      echo "     checkSuffix.sh: $(testCodeShift -f "$testCodeShift_dir/checkSuffix.sh" && echo '✓' || echo '✗')"
      echo "     precheckings.sh: $(testCodeShift -f "$testCodeShift_dir/precheckings.sh" && echo '✓' || echo '✗')"
      echo "     unrelated.sh: $(testCodeShift -f "$testCodeShift_dir/unrelated.sh" && echo '✓' || echo '✗')"
      [[ -n "$DEBUG" ]] && echo "DEBUG: Actual files in directory:" >&2
      [[ -n "$DEBUG" ]] && ls -1 "$testCodeShift_dir" >&2
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
