#!/usr/bin/env bash
testFileCountScalability() {
    echo ""
    echo "📊 Test 4: Scalability Test - Increasing file counts"
    echo "─────────────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "dist/" > .gitignore
    
    local file_counts=(50 100 200)
    local with_times=()
    local nogit_times=()
    
    for count in "${file_counts[@]}"; do
      # Clean and setup
      cd "$test_dir" && rm -rf *
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test User"
      echo "dist/" > .gitignore
      mkdir -p {src,dist}
      
      for i in $(seq 1 $count); do
        echo "function_old() { old_val }" > "src/file_$i.js"
      done
      for i in $(seq 1 $((count * 2))); do
        echo "old_val" > "dist/build_$i.js"
      done
      
      # WITH gitignore
      local start=$(date +%s%N)
      deepShift "old_val" "new_val" 2>/dev/null
      local end=$(date +%s%N)
      local time_ms=$(( (end - start) / 1000000 ))
      with_times+=($time_ms)
      
      # Reset
      cd "$test_dir" && rm -rf *
      git init -q
      git config user.email "test@example.com"
      git config user.name "Test User"
      echo "dist/" > .gitignore
      mkdir -p {src,dist}
      
      for i in $(seq 1 $count); do
        echo "function_old() { old_val }" > "src/file_$i.js"
      done
      for i in $(seq 1 $((count * 2))); do
        echo "old_val" > "dist/build_$i.js"
      done
      
      # WITHOUT gitignore
      local start=$(date +%s%N)
      deepShift "old_val" "new_val" --nogit 2>/dev/null
      local end=$(date +%s%N)
      local time_ms=$(( (end - start) / 1000000 ))
      nogit_times+=($time_ms)
    done
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    echo "Files | WITH gitignore | WITHOUT gitignore | Difference"
    echo "─────────────────────────────────────────────────────────"
    
    for i in "${!file_counts[@]}"; do
      local files=${file_counts[$i]}
      local with=${with_times[$i]}
      local nogit=${nogit_times[$i]}
      local diff=$(( nogit - with ))
      printf "%3d   | %6d ms       | %6d ms         | +%d ms\n" "$files" "$with" "$nogit" "$diff"
    done
    
    echo "✅ SUCCESS: Scalability test completed"
    return 0
  }