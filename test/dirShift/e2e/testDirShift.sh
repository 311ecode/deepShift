#!/usr/bin/env bash

# @file testDirShift.sh
# @brief Test suite for dirShift utility
# @description Ensures dirShift targets directories only and handles explicit moves

testDirShift() {
  export LC_NUMERIC=C

  testDirShiftFunctions=(
    "testDirShiftExplicitMove"
    "testDirShiftRecursivePattern"
    "testDirShiftIgnoresFiles"
    "testDirShiftContentUpdate"
  )

  ignoredArr=()

  bashTestRunner testDirShiftFunctions ignoredArr
  return $?
}

testDirShiftExplicitMove() {
    echo "📂 Testing Explicit Directory Move"
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    mkdir -p src/auth/login
    echo "import x from 'src/auth/login'" > src/main.ts
    
    # Explicit move
    dirShift "src/auth" "src/security" >/dev/null 2>&1
    
    if [[ -d "src/security/login" ]] && [[ ! -d "src/auth" ]] && \
       grep -q "src/security/login" src/main.ts; then
       echo "✅ SUCCESS: Explicit move worked"
       rm -rf "$test_dir"; return 0
    else
       echo "❌ ERROR: Explicit move failed"
       rm -rf "$test_dir"; return 1
    fi
}

testDirShiftRecursivePattern() {
    echo "🔄 Testing Recursive Pattern Rename"
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    mkdir -p src/utils
    mkdir -p src/api/utils
    touch src/utils/a.ts
    
    # Rename all 'utils' folders to 'helpers'
    dirShift "utils" "helpers" >/dev/null 2>&1
    
    if [[ -d "src/helpers" ]] && [[ -d "src/api/helpers" ]]; then
        echo "✅ SUCCESS: Recursive directory rename worked"
        rm -rf "$test_dir"; return 0
    else
        echo "❌ ERROR: Recursive rename failed"
        ls -R
        rm -rf "$test_dir"; return 1
    fi
}

testDirShiftIgnoresFiles() {
    echo "🛡️  Testing File Exclusion"
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    mkdir -p src/common
    touch src/common.ts  # Should NOT be renamed
    
    dirShift "common" "shared" >/dev/null 2>&1
    
    if [[ -d "src/shared" ]] && [[ -f "src/common.ts" ]]; then
        echo "✅ SUCCESS: Directory renamed, File ignored"
        rm -rf "$test_dir"; return 0
    else
        echo "❌ ERROR: Files were accidentally renamed"
        ls -R
        rm -rf "$test_dir"; return 1
    fi
}

testDirShiftContentUpdate() {
    echo "📝 Testing Content Updates"
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    mkdir -p src/modules
    echo "import m from './modules'" > src/index.ts
    
    dirShift "modules" "packages" >/dev/null 2>&1
    
    if grep -q "./packages" src/index.ts; then
        echo "✅ SUCCESS: Content references updated"
        rm -rf "$test_dir"; return 0
    else
        echo "❌ ERROR: Content not updated"
        cat src/index.ts
        rm -rf "$test_dir"; return 1
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && testDirShift
