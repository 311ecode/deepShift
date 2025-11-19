#!/usr/bin/env bash
testDeeplyNestedStructurePerformance() {
    echo ""
    echo "📊 Test 3: Deeply Nested Structure (10 levels deep, 50 files per level)"
    echo "──────────────────────────────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "node_modules/" > .gitignore
    
    # Create deep nested tracked structure
    mkdir -p src/a/b/c/d/e/f/g/h/i/j
    for i in {1..10}; do
      mkdir -p "src/level_$i"
      for j in {1..50}; do
        echo "const old_val = 'old_value'" > "src/level_$i/file_$j.js"
      done
    done
    
    # Create deep nested ignored structure
    mkdir -p node_modules/pkg/deep/nested/structure/here/we/go/down/further
    for i in {1..10}; do
      mkdir -p "node_modules/pkg_$i/sub/deep/nested"
      for j in {1..50}; do
        echo "old_value" > "node_modules/pkg_$i/sub/deep/nested/file_$j.js"
      done
    done
    
    # WITH gitignore
    local start_with=$(date +%s%N)
    deepShift "old_value" "new_value" 2>/dev/null
    local end_with=$(date +%s%N)
    local time_with=$(( (end_with - start_with) / 1000000 ))
    
    local src_count=$(grep -r "new_value" src/ 2>/dev/null | wc -l)
    local nm_count=$(grep -r "old_value" node_modules/ 2>/dev/null | wc -l)
    
    # Reset for --nogit
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "node_modules/" > .gitignore
    
    mkdir -p src/a/b/c/d/e/f/g/h/i/j
    for i in {1..10}; do
      mkdir -p "src/level_$i"
      for j in {1..50}; do
        echo "const old_val = 'old_value'" > "src/level_$i/file_$j.js"
      done
    done
    
    mkdir -p node_modules/pkg/deep/nested/structure/here/we/go/down/further
    for i in {1..10}; do
      mkdir -p "node_modules/pkg_$i/sub/deep/nested"
      for j in {1..50}; do
        echo "old_value" > "node_modules/pkg_$i/sub/deep/nested/file_$j.js"
      done
    done
    
    # WITHOUT gitignore
    local start_nogit=$(date +%s%N)
    deepShift "old_value" "new_value" --nogit 2>/dev/null
    local end_nogit=$(date +%s%N)
    local time_nogit=$(( (end_nogit - start_nogit) / 1000000 ))
    
    local all_count=$(grep -r "new_value" . 2>/dev/null | grep -v "\.git" | wc -l)
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms | Tracked: %3d | Ignored untouched: %3d\n" "$time_with" "$src_count" "$nm_count"
    printf "WITHOUT gitignore: %6d ms | All: %3d\n" "$time_nogit" "$all_count"
    
    local time_diff=$(( time_nogit - time_with ))
    local percent_slower=$(( (time_nogit - time_with) * 100 / time_with ))
    printf "⏱️  --nogit is ~%d%% SLOWER (traverses deeper into ignored dirs)\n" "$percent_slower"
    
    if [[ $src_count -gt 0 ]] && [[ $nm_count -eq 0 ]]; then
      echo "✅ SUCCESS: Nested structure performance measured"
      return 0
    else
      echo "❌ ERROR: Unexpected behavior with nested structures"
      return 1
    fi
  }