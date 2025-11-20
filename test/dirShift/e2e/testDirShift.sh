#!/usr/bin/env bash

# @file testDirShift.sh
# @brief Test suite for dirShift utility
# @description Ensures dirShift targets directories only and handles explicit moves

testDirShift() {
  export LC_NUMERIC=C

  local testDirShiftFunctions=(
    "testDirShiftExplicitMove"
    "testDirShiftRecursivePattern"
    "testDirShiftIgnoresFiles"
    "testDirShiftContentUpdate"
  )

  local ignored_testDirShifts=()  # 🚫 No testDirShifts ignored

  bashTestRunner testDirShiftFunctions ignored_testDirShifts
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
    # File referencing the directory
    echo "import m from './modules'" > src/index.ts
    # Variable referencing the name (should also update as per codeShift/deepShift standard)
    echo "const modules = true" > src/config.ts
    
    dirShift "modules" "packages" >/dev/null 2>&1
    
    # Check 1: Directory renamed?
    if [[ ! -d "src/packages" ]]; then
         echo "❌ ERROR: Directory not renamed"
         rm -rf "$test_dir"; return 1
    fi

    # Check 2: Import updated?
    if grep -q "./packages" src/index.ts; then
        echo "   ✅ Import paths updated"
    else
        echo "   ❌ ERROR: Import paths NOT updated"
        cat src/index.ts
        rm -rf "$test_dir"; return 1
    fi

    # Check 3: Variable updated?
    if grep -q "const packages = true" src/config.ts; then
        echo "   ✅ Variables updated"
    else
        echo "   ❌ ERROR: Content variables NOT updated"
        cat src/config.ts
        rm -rf "$test_dir"; return 1
    fi

    echo "✅ SUCCESS: Full content update verified"
    rm -rf "$test_dir"
    return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && testDirShift
