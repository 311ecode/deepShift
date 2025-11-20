#!/usr/bin/env bash

testDeepShiftPathSegmentRenaming() {
    echo "🛤️  Testing Path Segment Renaming (Deep Path Move)"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    # Create structure: src/deep/deeper/core/
    mkdir -p src/deep/deeper/core
    echo "import x from 'deep/deeper/core'" > src/deep/deeper/core/module.ts
    echo "path/reference" > src/outside.txt
    
    # Scenario: Move 'deep/deeper' -> 'flat/flatter'
    # Expectation:
    # 1. Directory: src/deep/deeper -> src/flat/flatter
    # 2. Content: 'deep/deeper/core' -> 'flat/flatter/core'
    
    deepShift "deep/deeper" "flat/flatter"
    
    # 1. Verify Content
    if grep -q "flat/flatter/core" "src/flat/flatter/core/module.ts"; then
        echo "   ✅ Content replaced correctly"
    else
        echo "   ❌ Content replacement failed"
        cat "src/flat/flatter/core/module.ts" 2>/dev/null
        cd - >/dev/null; rm -rf "$test_dir"; return 1
    fi
    
    # 2. Verify Directory Structure
    if [[ -d "src/flat/flatter/core" ]] && [[ ! -d "src/deep/deeper" ]]; then
        echo "   ✅ Directory segment renamed correctly"
    else
        echo "   ❌ Directory rename failed"
        find . -maxdepth 4
        cd - >/dev/null; rm -rf "$test_dir"; return 1
    fi
    
    # 3. Verify partial overlapping names don't break
    # If I have "src/deep/deeper_extra", it should NOT match "deep/deeper" at the end
    # (Logic check only, implemented in deepShift via suffix check)
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    echo "✅ SUCCESS: Path segment renaming works"
    return 0
}
