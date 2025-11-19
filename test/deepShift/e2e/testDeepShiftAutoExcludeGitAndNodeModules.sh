#!/usr/bin/env bash
testDeepShiftAutoExcludeGitAndNodeModules() {
    echo "🚫 Testing auto-exclusion of .git and node_modules"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create .git directory with old_string
    mkdir -p .git/hooks
    echo "old_string" > .git/config
    
    # Create node_modules directory with old_string
    mkdir -p node_modules/package
    echo "old_string" > node_modules/package/index.js
    
    # Create regular files with old_string
    echo "old_string" > regular_file.txt
    mkdir -p src
    echo "old_string" > src/component.js
    
    # Run replacement
    deepShift "old_string" "new_string"
    
    # Verify .git and node_modules were excluded, but regular files processed
    if grep -q "old_string" .git/config && \
       grep -q "old_string" node_modules/package/index.js && \
       grep -q "new_string" regular_file.txt && \
       grep -q "new_string" src/component.js; then
      echo "✅ SUCCESS: .git and node_modules auto-excluded, regular files processed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Auto-exclusion failed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
