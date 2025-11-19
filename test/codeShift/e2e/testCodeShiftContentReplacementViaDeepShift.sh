#!/usr/bin/env bash

testCodeShiftContentReplacementViaDeepShift() {
    echo "📝 Testing content replacement via deepShift"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create testCodeShift file with content containing the pattern
    cat > testCodeShiftFunction.sh << 'EOF'
#!/bin/bash
# This is a testCodeShift implementation
testCodeShiftFunction() {
  echo "testCodeShift output"
  return 0
}
EOF
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "production" >/dev/null 2>&1
    
    # Check if content was also replaced
    if [[ -f "$testCodeShift_dir/productionFunction.sh" ]] && \
       grep -q "production output" "$testCodeShift_dir/productionFunction.sh" && \
       grep -q "productionFunction" "$testCodeShift_dir/productionFunction.sh"; then
      echo "✅ SUCCESS: Content replacement works via deepShift"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Content replacement failed"
      cat "$testCodeShift_dir/productionFunction.sh" 2>/dev/null
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
