#!/usr/bin/env bash

# @file testDirShift.sh
# @brief Test suite for dirShift utility

testDirShift() {
  export LC_NUMERIC=C

  local testDirShiftFunctions=(
    "testDirShiftExplicitMove"
    "testDirShiftRecursivePattern"
    "testDirShiftIgnoresFiles"
    "testDirShiftContentUpdate"
  )

  local ignored_testDirShifts=() 

  bashTestRunner testDirShiftFunctions ignored_testDirShifts
  return $?
}

testDirShiftExplicitMove() {
    echo "📂 Testing Explicit Directory Move"
    local test_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    
    cd "$test_dir" || return 1
    
    # Setup
    mkdir -p src/auth/login
    echo "import x from 'src/auth/login'" > src/main.ts
    
    if [[ "$DEBUG" == "1" ]]; then
       echo "[TEST_DEBUG] Created structure at $test_dir"
       ls -R
    fi

    # Explicit move: src/auth -> src/security
    # Note: When running inside test_dir, "src/auth" is a valid relative path
    dirShift "src/auth" "src/security" >/dev/null 2>&1
    local ret=$?
    
    if [[ "$DEBUG" == "1" ]]; then
       echo "[TEST_DEBUG] dirShift exit code: $ret"
       echo "[TEST_DEBUG] Post-execution structure:"
       ls -R
       echo "[TEST_DEBUG] Content of main.ts:"
       cat src/main.ts
    fi

    # Validation
    local success=0
    if [[ -d "src/security/login" ]] && [[ ! -d "src/auth" ]] && \
       grep -q "src/security/login" src/main.ts; then
       echo "✅ SUCCESS: Explicit move worked"
    else
       echo "❌ ERROR: Explicit move failed"
       success=1
    fi

    # Cleanup safely
    cd "$original_pwd" || return 1
    rm -rf "$test_dir"
    
    return $success
}

testDirShiftRecursivePattern() {
    echo "🔄 Testing Recursive Pattern Rename"
    local test_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    
    cd "$test_dir" || return 1
    
    mkdir -p src/utils
    mkdir -p src/api/utils
    touch src/utils/a.ts
    
    dirShift "utils" "helpers" >/dev/null 2>&1
    
    local success=0
    if [[ -d "src/helpers" ]] && [[ -d "src/api/helpers" ]]; then
        echo "✅ SUCCESS: Recursive directory rename worked"
    else
        echo "❌ ERROR: Recursive rename failed"
        [[ "$DEBUG" == "1" ]] && ls -R
        success=1
    fi

    cd "$original_pwd" || return 1
    rm -rf "$test_dir"
    return $success
}

testDirShiftIgnoresFiles() {
    echo "🛡️  Testing File Exclusion"
    local test_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    
    cd "$test_dir" || return 1
    
    mkdir -p src/common
    touch src/common.ts  # Should NOT be renamed
    
    dirShift "common" "shared" >/dev/null 2>&1
    
    local success=0
    if [[ -d "src/shared" ]] && [[ -f "src/common.ts" ]]; then
        echo "✅ SUCCESS: Directory renamed, File ignored"
    else
        echo "❌ ERROR: Files were accidentally renamed"
        [[ "$DEBUG" == "1" ]] && ls -R
        success=1
    fi

    cd "$original_pwd" || return 1
    rm -rf "$test_dir"
    return $success
}

testDirShiftContentUpdate() {
    echo "📝 Testing Content Updates"
    local test_dir=$(mktemp -d)
    local original_pwd=$(pwd)
    
    cd "$test_dir" || return 1
    
    mkdir -p src/modules
    echo "import m from './modules'" > src/index.ts
    echo "const modules = true" > src/config.ts
    
    dirShift "modules" "packages" >/dev/null 2>&1
    
    local success=0
    if [[ ! -d "src/packages" ]]; then
          echo "❌ ERROR: Directory not renamed"
          success=1
    elif ! grep -q "./packages" src/index.ts; then
        echo "   ❌ ERROR: Import paths NOT updated"
        success=1
    elif ! grep -q "const packages = true" src/config.ts; then
        echo "   ❌ ERROR: Content variables NOT updated"
        success=1
    else
        echo "✅ SUCCESS: Full content update verified"
    fi

    cd "$original_pwd" || return 1
    rm -rf "$test_dir"
    return $success
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && testDirShift
