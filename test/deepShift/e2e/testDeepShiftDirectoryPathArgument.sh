#!/usr/bin/env bash
testDeepShiftDirectoryPathArgument() {
    echo "📂 Testing directory path as first argument"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # 1. Create a directory structure mimicking "drag and drop"
    mkdir -p "src/features/userAuth"
    touch "src/features/userAuth/login.ts"
    
    # 2. Create referencing file
    echo "import { x } from './features/userAuth/login'" > "src/main.ts"
    
    # 3. Run replacement with DIRECTORY path
    # Logic: Input "src/features/userAuth" -> Extract "userAuth" -> Replace with "adminAuth"
    deepShift "src/features/userAuth" "adminAuth"
    
    # 4. Verify results
    if [[ -d "src/features/adminAuth" ]] && \
       grep -q "import { x } from './features/adminAuth/login'" "src/main.ts"; then
      echo "✅ SUCCESS: Directory path argument handled correctly"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Directory path argument failed"
      ls -R
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
