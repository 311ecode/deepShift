#!/usr/bin/env bash
testDeepShiftGitDirectoryExclusion() {
    echo "🚫 Testing .git directory exclusion"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create git repo structure
    mkdir -p .git/hooks
    echo "old_string" > .git/config
    echo "old_string" > regular_file.txt
    
    # Run replacement
    deepShift "old_string" "new_string"
    
    # Verify .git was excluded but regular files processed
    if grep -q "old_string" .git/config && \
       grep -q "new_string" regular_file.txt; then
      echo "✅ SUCCESS: .git directory properly excluded"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: .git exclusion failed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
