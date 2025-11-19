#!/usr/bin/env bash
testDeepShiftBasicContentReplacement() {
    echo "🧪 Testing basic string replacement in file content"
    
    # Create testDeepShift files with content to replace
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    echo "old_project_name v1.0.0" > testDeepShift_file.txt
    echo "old_project_name" > another_file.md
    
    # Run the replacement
    deepShift "old_project_name" "new_project_name"
    
    # Verify replacements
    if grep -q "new_project_name v1.0.0" testDeepShift_file.txt && \
       grep -q "new_project_name" another_file.md; then
      echo "✅ SUCCESS: Basic content replacement works"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Content replacement failed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
