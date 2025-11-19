#!/usr/bin/env bash
testDeepShiftFileAsFirstArgument() {
    echo "🖱️ Testing file path as first argument (Drag & Drop support)"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # 1. Create the "source" file that mimics what a user drags in
    mkdir -p src/components
    touch "src/components/OldComponent.tsx"
    
    # 2. Create a file that actually needs updating
    echo "import OldComponent from './OldComponent';" > "src/App.tsx"
    
    # 3. Run replacement passing the FILE PATH as the first argument
    # Expectation: It extracts "OldComponent" from the path and uses that as the search string
    deepShift "src/components/OldComponent.tsx" "NewComponent"
    
    # 4. Verify contents were updated
    if grep -q "import NewComponent from './NewComponent';" "src/App.tsx"; then
       # 5. Verify the file rename happened (part of standard logic, but confirms the search string was correct)
       if [[ -f "src/components/NewComponent.tsx" ]]; then
          echo "✅ SUCCESS: File path argument correctly parsed to base name"
          cd - >/dev/null
          rm -rf "$testDeepShift_dir"
          return 0
       else
          echo "❌ ERROR: Content replaced, but file renaming failed"
          cd - >/dev/null
          rm -rf "$testDeepShift_dir"
          return 1
       fi
    else
      echo "❌ ERROR: Failed to extract string from file path argument"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
