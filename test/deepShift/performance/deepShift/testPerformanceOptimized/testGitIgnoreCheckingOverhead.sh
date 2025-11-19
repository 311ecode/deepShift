#!/usr/bin/env bash
testGitIgnoreCheckingOverhead() {
    echo ""
    echo "📊 Test 1: Gitignore Checking Overhead Analysis"
    echo "──────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "node_modules/" > .gitignore
    
    # Create 200 files (100 tracked, 100 in node_modules)
    mkdir -p src node_modules/pkg
    for i in {1..100}; do
      echo "content" > "src/file_$i.js"
    done
    for i in {1..100}; do
      echo "content" > "node_modules/pkg/file_$i.js"
    done
    
    echo ""
    echo "Scenario: 200 total files (100 tracked, 100 ignored)"
    echo "────────────────────────────────────────────────────"
    
    # Measure grep + gitignore checking (current implementation)
    local start=$(date +%s%N)
    grep -rIl "content" . 2>/dev/null | while IFS= read -r file; do
      deepShiftIsPathIgnored "$file" 2>/dev/null >/dev/null
    done
    local end=$(date +%s%N)
    local grep_plus_gitignore=$(( (end - start) / 1000000 ))
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "node_modules/" > .gitignore
    mkdir -p src node_modules/pkg
    for i in {1..100}; do
      echo "content" > "src/file_$i.js"
    done
    for i in {1..100}; do
      echo "content" > "node_modules/pkg/file_$i.js"
    done
    
    # Measure grep only (without gitignore checking)
    local start=$(date +%s%N)
    grep -rIl "content" . 2>/dev/null | wc -l
    local end=$(date +%s%N)
    local grep_only=$(( (end - start) / 1000000 ))
    
    # Measure gitignore checking overhead
    local overhead=$(( grep_plus_gitignore - grep_only ))
    local overhead_percent=$(( (grep_plus_gitignore - grep_only) * 100 / grep_only ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    echo "Grep + gitignore checks:  $grep_plus_gitignore ms"
    echo "Grep only:                $grep_only ms"
    echo "Overhead per file:        ~$(( overhead / 200 )) ms"
    echo "Total overhead:           $overhead_percent%"
    echo ""
    
    if [[ $overhead_percent -gt 100 ]]; then
      echo "⚠️  FINDING: Gitignore checking adds significant overhead!"
      echo "   Each deepShiftIsPathIgnored call is expensive."
      return 0
    else
      echo "✅ Gitignore overhead is minimal"
      return 0
    fi
  }