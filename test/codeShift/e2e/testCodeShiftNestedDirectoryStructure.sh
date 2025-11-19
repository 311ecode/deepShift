#!/usr/bin/env bash

testCodeShiftNestedDirectoryStructure() {
    echo "🏗️ Testing nested directory structure"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create nested structure
    mkdir -p dir1/subdir
    mkdir -p dir2
    touch dir1/testCodeShiftFile.sh
    touch dir1/subdir/testCodeShiftNested.sh
    touch dir2/testCodeShiftAnother.sh
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "renamed" >/dev/null 2>&1
    
    # Verify nested files were renamed
    if [[ -f "$testCodeShift_dir/dir1/renamedFile.sh" ]] && \
       [[ -f "$testCodeShift_dir/dir1/subdir/renamedNested.sh" ]] && \
       [[ -f "$testCodeShift_dir/dir2/renamedAnother.sh" ]]; then
      echo "✅ SUCCESS: Nested files renamed correctly"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Nested files not renamed properly"
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
