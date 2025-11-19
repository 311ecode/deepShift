#!/usr/bin/env bash
testDirectoryRenamingPerformance() {
    echo ""
    echo "📊 Test 5: Directory Renaming Performance (100 directories)"
    echo "──────────────────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "old_build/" > .gitignore
    
    # Create tracked directories
    for i in {1..50}; do
      mkdir -p "src/old_module_$i"
      echo "content" > "src/old_module_$i/index.js"
    done
    
    # Create ignored directories
    for i in {1..50}; do
      mkdir -p "old_build/output_$i"
      echo "content" > "old_build/output_$i/file.o"
    done
    
    # WITH gitignore
    local start_with=$(date +%s%N)
    deepShift "old_" "new_" 2>/dev/null
    local end_with=$(date +%s%N)
    local time_with=$(( (end_with - start_with) / 1000000 ))
    
    local src_dirs=$(find src -type d -name "new_*" | wc -l)
    local build_dirs=$(find old_build -type d -name "old_*" 2>/dev/null | wc -l)
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "old_build/" > .gitignore
    
    for i in {1..50}; do
      mkdir -p "src/old_module_$i"
      echo "content" > "src/old_module_$i/index.js"
    done
    for i in {1..50}; do
      mkdir -p "old_build/output_$i"
      echo "content" > "old_build/output_$i/file.o"
    done
    
    # WITHOUT gitignore
    local start_nogit=$(date +%s%N)
    deepShift "old_" "new_" --nogit 2>/dev/null
    local end_nogit=$(date +%s%N)
    local time_nogit=$(( (end_nogit - start_nogit) / 1000000 ))
    
    local all_dirs=$(find . -type d -name "new_*" 2>/dev/null | grep -v "\.git" | wc -l)
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms | Tracked dirs renamed: %2d | Ignored untouched: %2d\n" "$time_with" "$src_dirs" "$build_dirs"
    printf "WITHOUT gitignore: %6d ms | All dirs renamed: %2d\n" "$time_nogit" "$all_dirs"
    
    echo "✅ SUCCESS: Directory renaming performance measured"
    return 0
  }