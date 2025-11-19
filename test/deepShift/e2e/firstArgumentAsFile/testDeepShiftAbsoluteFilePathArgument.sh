#!/usr/bin/env bash
testDeepShiftAbsoluteFilePathArgument() {
    echo "🗺️ Testing absolute file path as first argument"
    
    local testDeepShift_dir=$(mktemp -d)
    # Store the absolute path to this temp directory
    local abs_testDeepShift_dir=$(cd "$testDeepShift_dir" && pwd)
    
    cd "$testDeepShift_dir" || return 1
    
    # 1. Create the source file
    echo "content" > "TargetFile.txt"
    
    # 2. Create a referencing file
    echo "Referencing TargetFile inside text" > "Reference.md"
    
    # 3. Construct the ABSOLUTE path to the file
    local abs_file_path="$abs_testDeepShift_dir/TargetFile.txt"
    
    # 4. Run replacement using the ABSOLUTE path
    # Logic should:
    #   a) Detect "$abs_file_path" exists
    #   b) Run basename -> "TargetFile.txt"
    #   c) Strip extension -> "TargetFile"
    #   d) Use "TargetFile" as the search string
    deepShift "$abs_file_path" "RenamedFile"
    
    # 5. Verify
    # "TargetFile.txt" should become "RenamedFile.txt"
    # Content "TargetFile" in Reference.md should become "RenamedFile"
    if [[ -f "RenamedFile.txt" ]] && \
       grep -q "Referencing RenamedFile inside text" "Reference.md"; then
      echo "✅ SUCCESS: Absolute file path argument correctly handled"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Absolute path handling failed"
      ls -R
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
