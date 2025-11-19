#!/usr/bin/env bash

testDeepShiftScopeFlags() {
    echo "🚩 Testing Scope Control Flags (--files-only, --content-only)"

    # --- Test 1: Files Only Mode ---
    # Should rename the file but NOT change its content
    local test_dir_files=$(mktemp -d)
    cd "$test_dir_files" || return 1
    
    echo "test_string content" > "test_string.txt"
    
    deepShift "test_string" "new_string" --files-only
    
    if [[ -f "new_string.txt" ]] && [[ ! -f "test_string.txt" ]]; then
        if grep -q "test_string content" "new_string.txt"; then
            echo "✅ SUCCESS: --files-only renamed file but preserved content"
        else
            echo "❌ ERROR: --files-only improperly modified content"
            cat "new_string.txt"
            cd - >/dev/null; rm -rf "$test_dir_files"; return 1
        fi
    else
        echo "❌ ERROR: --files-only failed to rename file"
        ls -R
        cd - >/dev/null; rm -rf "$test_dir_files"; return 1
    fi
    cd - >/dev/null
    rm -rf "$test_dir_files"

    # --- Test 2: Content Only Mode ---
    # Should change content but NOT rename the file
    local test_dir_content=$(mktemp -d)
    cd "$test_dir_content" || return 1
    
    echo "test_string content" > "test_string.txt"
    
    deepShift "test_string" "new_string" --content-only
    
    if [[ -f "test_string.txt" ]]; then
        if grep -q "new_string content" "test_string.txt"; then
             echo "✅ SUCCESS: --content-only updated content but preserved filename"
        else
             echo "❌ ERROR: --content-only failed to update content"
             cat "test_string.txt"
             cd - >/dev/null; rm -rf "$test_dir_content"; return 1
        fi
    else
        echo "❌ ERROR: --content-only improperly renamed file"
        ls -R
        cd - >/dev/null; rm -rf "$test_dir_content"; return 1
    fi
    cd - >/dev/null
    rm -rf "$test_dir_content"

    # --- Test 3: Mutually Exclusive Flags ---
    # Should fail when both are provided
    local test_dir_mutex=$(mktemp -d)
    cd "$test_dir_mutex" || return 1
    
    local output
    output=$(deepShift "a" "b" --files-only --content-only 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "✅ SUCCESS: Mutually exclusive flags correctly rejected"
    else
        echo "❌ ERROR: Should have failed when both flags provided"
        cd - >/dev/null; rm -rf "$test_dir_mutex"; return 1
    fi
    
    cd - >/dev/null
    rm -rf "$test_dir_mutex"

    return 0
}
