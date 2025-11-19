#!/usr/bin/env bash
testContentReplacementBottleneck() {
    echo ""
    echo "📊 Test 2: Content Replacement Performance"
    echo "──────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    mkdir -p src build
    
    # Create 50 tracked files with content to replace
    for i in {1..50}; do
      echo "Line 1: old_pattern" > "src/file_$i.js"
      echo "Line 2: old_pattern" >> "src/file_$i.js"
      echo "Line 3: old_pattern" >> "src/file_$i.js"
    done
    
    echo ""
    echo "Scenario: 50 files with replacements"
    echo "────────────────────────────────────"
    
    # Measure sed replacement on 50 files
    local start=$(date +%s%N)
    grep -rIl "old_pattern" src/ 2>/dev/null | while IFS= read -r file; do
      sed -i "s/old_pattern/new_pattern/g" "$file"
    done
    local end=$(date +%s%N)
    local sed_time=$(( (end - start) / 1000000 ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    echo "Time to replace in 50 files: $sed_time ms"
    echo "Per-file average:            $(( sed_time / 50 )) ms"
    echo ""
    echo "📌 Key insight: sed operations are I/O intensive"
    echo "   Each sed -i rewrites the entire file."
    return 0
  }