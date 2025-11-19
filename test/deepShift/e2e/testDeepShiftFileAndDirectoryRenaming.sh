#!/usr/bin/env bash
testDeepShiftFileAndDirectoryRenaming() {
    echo "📁 Testing file and directory renaming"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create testDeepShift structure
    mkdir -p "project_oldname/src"
    echo "content" > "project_oldname/file_oldname.txt"
    echo "content" > "file_oldname.md"
    
    # Run renaming
    deepShift "oldname" "newname"
    
    # Verify renames
    if [[ -d "project_newname" ]] && \
       [[ -f "project_newname/file_newname.txt" ]] && \
       [[ -f "file_newname.md" ]]; then
      echo "✅ SUCCESS: File and directory renaming works"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Renaming failed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
