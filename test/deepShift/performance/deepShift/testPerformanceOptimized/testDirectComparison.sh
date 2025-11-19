#!/usr/bin/env bash
testDirectComparison() {
    echo ""
    echo "📊 Test 3: Direct Comparison (Minimal Test Case)"
    echo "───────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "build/" > .gitignore
    
    # Create minimal test case: 10 tracked files only
    mkdir -p src
    for i in {1..10}; do
      echo "const x = 'old_value';" > "src/file_$i.js"
    done
    
    echo ""
    echo "Scenario: SMALL SET - 10 tracked files only (0 ignored)"
    echo "────────────────────────────────────────────────────────"
    
    local start=$(date +%s%N)
    deepShift "old_value" "new_value" 2>/dev/null
    local end=$(date +%s%N)
    local with_gitignore=$(( (end - start) / 1000000 ))
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "build/" > .gitignore
    mkdir -p src
    for i in {1..10}; do
      echo "const x = 'old_value';" > "src/file_$i.js"
    done
    
    local start=$(date +%s%N)
    deepShift "old_value" "new_value" --nogit 2>/dev/null
    local end=$(date +%s%N)
    local without_gitignore=$(( (end - start) / 1000000 ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    echo "WITH gitignore:    $with_gitignore ms"
    echo "WITHOUT gitignore: $without_gitignore ms"
    echo ""
    
    if [[ $with_gitignore -gt $without_gitignore ]]; then
      local diff=$(( with_gitignore - without_gitignore ))
      echo "⚠️  Gitignore is slower by $diff ms"
      echo "   This suggests deepShiftIsPathIgnored has overhead even for"
      echo "   files that should be found immediately."
    else
      echo "✅ Performance is comparable"
    fi
    return 0
  }