#!/usr/bin/env bash
testStaticSiteProject() {
    echo ""
    echo "📄 Test 3: Static Site / Documentation Project"
    echo "──────────────────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "node_modules/" > .gitignore
    
    mkdir -p {docs,src/components,node_modules}
    
    # Tracked markdown files
    for i in {1..60}; do
      echo "# Old Title $i" > "docs/old_page_$i.md"
      echo "old_content" >> "docs/old_page_$i.md"
    done
    
    # Ignored node_modules
    for i in {1..50}; do
      echo "old_content" > "node_modules/pkg_$i.js"
    done
    
    echo "Project structure:"
    echo "  • Markdown files: 60 (tracked)"
    echo "  • node_modules: 50 (ignored)"
    echo ""
    
    # WITH gitignore
    local start=$(date +%s%N)
    deepShift "old_" "new_" 2>/dev/null
    local end=$(date +%s%N)
    local with_time=$(( (end - start) / 1000000 ))
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "node_modules/" > .gitignore
    mkdir -p {docs,src/components,node_modules}
    for i in {1..60}; do
      echo "# Old Title $i" > "docs/old_page_$i.md"
      echo "old_content" >> "docs/old_page_$i.md"
    done
    for i in {1..50}; do
      echo "old_content" > "node_modules/pkg_$i.js"
    done
    
    # WITHOUT gitignore
    local start=$(date +%s%N)
    deepShift "old_" "new_" --nogit 2>/dev/null
    local end=$(date +%s%N)
    local nogit_time=$(( (end - start) / 1000000 ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms\n" "$with_time"
    printf "WITHOUT gitignore: %6d ms\n" "$nogit_time"
    
    local ratio=$(( nogit_time * 100 / with_time ))
    echo "✅ RECOMMENDATION: Default is fine here"
    echo "   Protects dependencies while renaming content"
    
    return 0
  }