#!/usr/bin/env bash

testCodeShiftDocumentationUpdateViaReplaceAndReadme() {
    echo "📚 Testing documentation update via replaceAndReadme"
    
    local testCodeShift_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    cd "$testCodeShift_dir" || return 1
    
    # Create testCodeShift file
    touch testCodeShiftFeature.sh
    
    # Create README referencing the testCodeShift
    cat > README.md << 'EOF'
# Documentation

This project includes testCodeShiftFeature.sh which provides functionality.

## Running Tests

Execute testCodeShiftFeature to verify behavior.
EOF
    
    cd "$original_pwd" || return 1
    
    # Run batch rename
    codeShift "$testCodeShift_dir" "testCodeShift" "improved" >/dev/null 2>&1
    
    # Check if README was updated by replaceAndReadme
    if [[ -f "$testCodeShift_dir/improvedFeature.sh" ]] && \
       grep -q "improvedFeature" "$testCodeShift_dir/README.md"; then
      echo "✅ SUCCESS: Documentation updated via replaceAndReadme"
      rm -rf "$testCodeShift_dir"
      return 0
    else
      echo "❌ ERROR: Documentation not updated properly"
      cat "$testCodeShift_dir/README.md" 2>/dev/null
      rm -rf "$testCodeShift_dir"
      return 1
    fi
}
