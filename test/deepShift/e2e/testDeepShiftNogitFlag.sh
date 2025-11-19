#!/usr/bin/env bash
testDeepShiftNogitFlag() {
    echo "🚫 Testing --nogit/-n flag (skip gitignore checks)"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create git repo with gitignore
    git init -q
    git config user.email "testDeepShift@example.com"
    git config user.name "Test User"
    echo "*.log" > .gitignore
    
    echo "old_string" > testDeepShift.log
    echo "old_string" > testDeepShift.txt
    
    # Run with --nogit flag (should process both files, skipping gitignore)
    deepShift "old_string" "new_string" --nogit
    
    # Both files should be replaced despite .gitignore
    if grep -q "new_string" testDeepShift.log && \
       grep -q "new_string" testDeepShift.txt; then
      echo "✅ SUCCESS: --nogit flag skips gitignore checks"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Files not processed with --nogit flag"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
