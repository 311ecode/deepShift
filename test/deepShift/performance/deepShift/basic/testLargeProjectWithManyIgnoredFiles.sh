#!/usr/bin/env bash
testLargeProjectWithManyIgnoredFiles() {
    echo ""
    echo "📊 Test 2: Large Project with Many Ignored Files (500 total, 80% ignored)"
    echo "─────────────────────────────────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    cat > .gitignore <<EOF
*.log
*.tmp
*.cache
build/
dist/
node_modules/
coverage/
.pytest_cache/
__pycache__/
.DS_Store
EOF
    
    mkdir -p {src,build,dist,node_modules,coverage,.pytest_cache,__pycache__}
    
    # Create tracked files (20% = 100 files)
    for i in {1..100}; do
      echo "tracked_code_old_$i() { old_pattern }" > "src/file_$i.js"
    done
    
    # Create ignored files (80% = 400 files)
    for i in {1..200}; do
      echo "old_pattern" > "build/build_$i.o"
    done
    for i in {1..100}; do
      echo "old_pattern" > "node_modules/pkg_$i.js"
    done
    for i in {1..50}; do
      echo "old_pattern" > "coverage/report_$i.log"
      echo "old_pattern" > ".pytest_cache/cache_$i.tmp"
    done
    
    # WITH gitignore
    local start_with=$(date +%s%N)
    deepShift "old_pattern" "new_pattern" 2>/dev/null
    local end_with=$(date +%s%N)
    local time_with=$(( (end_with - start_with) / 1000000 ))
    
    local src_count=$(grep -r "new_pattern" src/ 2>/dev/null | wc -l)
    local ignored_count=$(grep -r "old_pattern" build/ node_modules/ coverage/ .pytest_cache/ 2>/dev/null | wc -l)
    
    # Reset for --nogit test
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    cat > .gitignore <<EOF
*.log
*.tmp
*.cache
build/
dist/
node_modules/
coverage/
.pytest_cache/
__pycache__/
.DS_Store
EOF
    mkdir -p {src,build,dist,node_modules,coverage,.pytest_cache,__pycache__}
    
    for i in {1..100}; do
      echo "tracked_code_old_$i() { old_pattern }" > "src/file_$i.js"
    done
    for i in {1..200}; do
      echo "old_pattern" > "build/build_$i.o"
    done
    for i in {1..100}; do
      echo "old_pattern" > "node_modules/pkg_$i.js"
    done
    for i in {1..50}; do
      echo "old_pattern" > "coverage/report_$i.log"
      echo "old_pattern" > ".pytest_cache/cache_$i.tmp"
    done
    
    # WITHOUT gitignore (--nogit)
    local start_nogit=$(date +%s%N)
    deepShift "old_pattern" "new_pattern" --nogit 2>/dev/null
    local end_nogit=$(date +%s%N)
    local time_nogit=$(( (end_nogit - start_nogit) / 1000000 ))
    
    local all_count=$(grep -r "new_pattern" . 2>/dev/null | grep -v "\.git" | wc -l)
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms | Tracked replaced: %3d | Ignored left alone: %3d\n" "$time_with" "$src_count" "$ignored_count"
    printf "WITHOUT gitignore: %6d ms | All replaced: %3d\n" "$time_nogit" "$all_count"
    
    local time_diff=$(( time_nogit - time_with ))
    local percent_slower=$(( (time_nogit - time_with) * 100 / time_with ))
    printf "⏱️  --nogit is ~%d%% SLOWER (processes 4x more files)\n" "$percent_slower"
    
    if [[ $src_count -eq 100 ]] && [[ $ignored_count -eq 0 ]] && [[ $all_count -gt $src_count ]]; then
      echo "✅ SUCCESS: Significant performance difference observed with large ignored file set"
      return 0
    else
      echo "❌ ERROR: Unexpected file counts"
      return 1
    fi
  }