#!/usr/bin/env bash
testTypicalNodeProject() {
    echo ""
    echo "📦 Test 1: Typical Node.js/React Project"
    echo "─────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    cat > .gitignore <<EOF
node_modules/
dist/
build/
.cache/
*.log
.env.local
EOF
    
    # Create realistic structure
    mkdir -p {src,public,tests,node_modules/lodash,dist}
    
    # Tracked files
    for i in {1..30}; do
      echo "import { oldUtility } from './old_util';" > "src/component_$i.jsx"
    done
    for i in {1..20}; do
      echo "export function oldUtility() {}" > "src/old_util_$i.js"
    done
    
    # Ignored files (simulating node_modules)
    for i in {1..100}; do
      echo "oldUtility" > "node_modules/lodash/old_$i.js"
    done
    
    echo "Project structure:"
    echo "  • Source files: 50 (tracked)"
    echo "  • node_modules: 100 (ignored)"
    echo ""
    
    # WITH gitignore
    local start=$(date +%s%N)
    deepShift "oldUtility" "newUtility" 2>/dev/null
    local end=$(date +%s%N)
    local with_time=$(( (end - start) / 1000000 ))
    
    local replaced=$(grep -r "newUtility" src/ 2>/dev/null | wc -l)
    local untouched=$(grep -r "oldUtility" node_modules/ 2>/dev/null | wc -l)
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    cat > .gitignore <<EOF
node_modules/
dist/
build/
.cache/
*.log
.env.local
EOF
    mkdir -p {src,public,tests,node_modules/lodash,dist}
    for i in {1..30}; do
      echo "import { oldUtility } from './old_util';" > "src/component_$i.jsx"
    done
    for i in {1..20}; do
      echo "export function oldUtility() {}" > "src/old_util_$i.js"
    done
    for i in {1..100}; do
      echo "oldUtility" > "node_modules/lodash/old_$i.js"
    done
    
    # WITHOUT gitignore
    local start=$(date +%s%N)
    deepShift "oldUtility" "newUtility" --nogit 2>/dev/null
    local end=$(date +%s%N)
    local nogit_time=$(( (end - start) / 1000000 ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms | Replaced: %2d | Untouched: %3d\n" "$with_time" "$replaced" "$untouched"
    printf "WITHOUT gitignore: %6d ms (processes all files)\n" "$nogit_time"
    
    local percent_slower=$(( (with_time - nogit_time) * 100 / nogit_time ))
    if [[ $percent_slower -gt 0 ]]; then
      echo "⚠️  WITH gitignore is ${percent_slower}% SLOWER"
      echo "   → Use --nogit for Node projects if speed is critical"
    else
      echo "✅ Performance is comparable"
    fi
    echo "   → DEFAULT recommendation: Use --nogit (safer + faster)"
    
    return 0
  }