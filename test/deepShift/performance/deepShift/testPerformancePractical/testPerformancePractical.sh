#!/usr/bin/env bash

# @file testPerformancePractical.sh
# @brief Practical performance test - real-world usage patterns
# @description Measures actual performance in typical workflows

testPerformancePractical() {
  echo "🎯 Practical Performance Test: Real-World Usage Patterns"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Test 1: Typical React/Node.js Project
  

  # Test 2: Python/Django Project
  

  # Test 3: Static Site / Documentation
  

  # Run all tests
  echo ""
  testTypicalNodeProject
  testPythonProject
  testStaticSiteProject
  
  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 PRACTICAL RECOMMENDATIONS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🎯 When to use DEFAULT (with gitignore):"
  echo "   • You have significant ignored files (node_modules, etc.)"
  echo "   • You want protection against changing artifacts"
  echo "   • One-off refactoring operations"
  echo ""
  echo "🎯 When to use --nogit flag:"
  echo "   • CI/CD pipelines (speed matters)"
  echo "   • Non-git projects"
  echo "   • When you intentionally want to update everything"
  echo "   • For projects with heavy node_modules/cache folders"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  return 0
}

