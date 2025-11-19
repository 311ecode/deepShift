#!/usr/bin/env bash
testRealWorldScenarios() {
    echo ""
    echo "📊 Test 5: Real-World Scenario Recommendations"
    echo "──────────────────────────────────────────────"
    echo ""
    
    echo "Scenario A: Refactoring application source code"
    echo "────────────────────────────────────────────────"
    echo "  Files: 100 source files + node_modules (1000+ files ignored)"
    echo "  ✅ RECOMMENDATION: Use default (with gitignore)"
    echo "     WHY: Protects build artifacts and dependencies"
    echo ""
    
    echo "Scenario B: Renaming a utility function globally"
    echo "──────────────────────────────────────────────────"
    echo "  Files: 50 source files + various build artifacts"
    echo "  ✅ RECOMMENDATION: Use --nogit flag"
    echo "     WHY: Updates both source AND generated files intentionally"
    echo ""
    
    echo "Scenario C: Bulk refactoring in CI/CD pipeline"
    echo "──────────────────────────────────────────────"
    echo "  Files: 500+ source files"
    echo "  ✅ RECOMMENDATION: Use --nogit flag"
    echo "     WHY: Avoid gitignore overhead in automated systems"
    echo ""
    
    echo "Scenario D: One-off code updates"
    echo "────────────────────────────────"
    echo "  Files: Any size"
    echo "  ✅ RECOMMENDATION: Use default (with gitignore)"
    echo "     WHY: Safe by default, protects important artifacts"
    echo ""
    return 0
  }