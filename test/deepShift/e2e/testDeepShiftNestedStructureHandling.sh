#!/usr/bin/env bash
testDeepShiftNestedStructureHandling() {
    echo "🏗️ Testing complex nested structure handling"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create complex nested structure
    mkdir -p "oldproject/src/oldmodule"
    mkdir -p "oldproject/docs/oldsection"
    echo "oldcontent" > "oldproject/file_old.txt"
    echo "oldcontent" > "oldproject/src/oldmodule/module_old.py"
    echo "oldcontent" > "oldproject/docs/oldsection/doc_old.md"
    
    # Perform comprehensive replacement
    deepShift "old" "new"
    
    # Verify all replacements
    if [[ -d "newproject" ]] && \
       [[ -d "newproject/src/newmodule" ]] && \
       [[ -d "newproject/docs/newsection" ]] && \
       grep -q "newcontent" "newproject/file_new.txt" && \
       grep -q "newcontent" "newproject/src/newmodule/module_new.py" && \
       grep -q "newcontent" "newproject/docs/newsection/doc_new.md"; then
      echo "✅ SUCCESS: Complex nested structure handled correctly"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Nested structure handling failed"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
