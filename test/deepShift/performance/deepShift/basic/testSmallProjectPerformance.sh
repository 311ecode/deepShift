#!/usr/bin/env bash
testSmallProjectPerformance() {
    echo ""
    echo "📊 Test 1: Small Project (100 files)"
    echo "─────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create .gitignore with common patterns
    cat > .gitignore <<EOF
*.log
*.tmp
build/
dist/
node_modules/
.cache/
EOF
    
    # Create project structure
    mkdir -p {src,build,dist,node_modules,src/utils,.cache}
    
    # Add tracked files
    for i in {1..50}; do
      echo "function_old_$i() { old_string_here }" > "src/module_$i.js"
    done
    
    # Add ignored files
    for i in {1..30}; do
      echo "old_string_here" > "build/output_$i.o"
      echo "old_string_here" > ".cache/cache_$i.tmp"
    done
    
    # Add node_modules files
    for i in {1..20}; do
      echo "old_string_here" > "node_modules/pkg_$i.js"
    done
    
    # Test WITH gitignore checking
    local start_with=$(date +%s%N)
    deepShift "old_string_here" "new_string_here" 2>/dev/null
    local end_with=$(date +%s%N)
    local time_with=$(( (end_with - start_with) / 1000000 ))  # Convert to milliseconds
    
    local tracked_count=$(grep -r "new_string_here" src/ 2>/dev/null | wc -l)
    local ignored_count=$(grep -r "old_string_here" build/ .cache/ node_modules/ 2>/dev/null | wc -l)
    
    # Reset for second test
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    cat > .gitignore <<EOF
*.log
*.tmp
build/
dist/
node_modules/
.cache/
EOF
    
    mkdir -p {src,build,dist,node_modules,src/utils,.cache}
    for i in {1..50}; do
      echo "function_old_$i() { old_string_here }" > "src/module_$i.js"
    done
    for i in {1..30}; do
      echo "old_string_here" > "build/output_$i.o"
      echo "old_string_here" > ".cache/cache_$i.tmp"
    done
    for i in {1..20}; do
      echo "old_string_here" > "node_modules/pkg_$i.js"
    done
    
    # Test WITHOUT gitignore checking (--nogit)
    local start_nogit=$(date +%s%N)
    deepShift "old_string_here" "new_string_here" --nogit 2>/dev/null
    local end_nogit=$(date +%s%N)
    local time_nogit=$(( (end_nogit - start_nogit) / 1000000 ))
    
    local all_count=$(grep -r "new_string_here" . 2>/dev/null | grep -v "\.git" | wc -l)
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    # Display results
    printf "WITH gitignore:    %6d ms | Tracked: %2d | Ignored: %2d\n" "$time_with" "$tracked_count" "$ignored_count"
    printf "WITHOUT gitignore: %6d ms | All files processed: %2d\n" "$time_nogit" "$all_count"
    
    local time_diff=$(( time_nogit - time_with ))
    if [[ $time_diff -gt 0 ]]; then
      printf "⏱️  --nogit is %.1f%% SLOWER (processes ignored files)\n" "$(( time_diff * 100 / time_with ))"
    else
      printf "⏱️  --nogit is %.1f%% FASTER\n" "$(( -time_diff * 100 / time_nogit ))"
    fi
    
    if [[ $tracked_count -gt 0 ]] && [[ $ignored_count -eq 0 ]] && [[ $all_count -gt $tracked_count ]]; then
      echo "✅ SUCCESS: Gitignore filtering working correctly"
      return 0
    else
      echo "❌ ERROR: Unexpected results"
      echo "   tracked_count=$tracked_count, ignored_count=$ignored_count, all_count=$all_count"
      return 1
    fi
  }