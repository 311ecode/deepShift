#!/usr/bin/env bash
testPythonProject() {
    echo ""
    echo "🐍 Test 2: Python/Django Project"
    echo "─────────────────────────────────"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir" || return 1
    
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    cat > .gitignore <<EOF
__pycache__/
*.pyc
.pytest_cache/
venv/
dist/
*.egg-info/
EOF
    
    mkdir -p {app/models,app/views,app/migrations,__pycache__,.pytest_cache,venv}
    
    # Tracked files
    for i in {1..40}; do
      echo "class OldModel_$i:" > "app/models/old_model_$i.py"
      echo "    pass" >> "app/models/old_model_$i.py"
    done
    
    # Ignored files
    for i in {1..200}; do
      echo "OldModel" > "__pycache__/cache_$i.pyc"
    done
    for i in {1..50}; do
      echo "OldModel" > ".pytest_cache/test_$i.tmp"
    done
    
    echo "Project structure:"
    echo "  • Python files: 40 (tracked)"
    echo "  • Cache/pycache: 250 (ignored)"
    echo ""
    
    # WITH gitignore
    local start=$(date +%s%N)
    deepShift "OldModel" "NewModel" 2>/dev/null
    local end=$(date +%s%N)
    local with_time=$(( (end - start) / 1000000 ))
    
    local replaced=$(grep -r "NewModel" app/ 2>/dev/null | wc -l)
    
    # Reset
    cd "$test_dir" && rm -rf *
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    cat > .gitignore <<EOF
__pycache__/
*.pyc
.pytest_cache/
venv/
dist/
*.egg-info/
EOF
    mkdir -p {app/models,app/views,app/migrations,__pycache__,.pytest_cache,venv}
    for i in {1..40}; do
      echo "class OldModel_$i:" > "app/models/old_model_$i.py"
      echo "    pass" >> "app/models/old_model_$i.py"
    done
    for i in {1..200}; do
      echo "OldModel" > "__pycache__/cache_$i.pyc"
    done
    for i in {1..50}; do
      echo "OldModel" > ".pytest_cache/test_$i.tmp"
    done
    
    # WITHOUT gitignore
    local start=$(date +%s%N)
    deepShift "OldModel" "NewModel" --nogit 2>/dev/null
    local end=$(date +%s%N)
    local nogit_time=$(( (end - start) / 1000000 ))
    
    cd - >/dev/null
    rm -rf "$test_dir"
    
    printf "WITH gitignore:    %6d ms | Updated: %2d files\n" "$with_time" "$replaced"
    printf "WITHOUT gitignore: %6d ms\n" "$nogit_time"
    
    local percent_slower=$(( (with_time - nogit_time) * 100 / nogit_time ))
    if [[ $percent_slower -gt 0 ]]; then
      echo "⚠️  WITH gitignore is ${percent_slower}% SLOWER"
    fi
    echo "   → Use --nogit for consistency and speed"
    
    return 0
  }