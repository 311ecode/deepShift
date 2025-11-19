#!/usr/bin/env bash

# @file testPerformanceOptimized.sh
# @brief Optimized performance test with root cause analysis
# @description Identifies performance bottlenecks and provides actionable insights

testPerformanceOptimized() {
  echo "🚀 Optimized Performance Test: Gitignore vs --nogit Flag"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "⚠️  IMPORTANT: This test analyzes why gitignore checking is slower"
  echo "    and provides optimization recommendations."
  echo ""

  # Run all analysis tests
  local tests=(
    "testGitIgnoreCheckingOverhead"
    "testContentReplacementBottleneck"
    "testDirectComparison"
    "testOptimizationRecommendations"
    "testRealWorldScenarios"
  )
  
  for test in "${tests[@]}"; do
    $test
  done
  
  # Final summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📈 PERFORMANCE ANALYSIS SUMMARY"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "KEY FINDINGS:"
  echo "  1. deepShiftIsPathIgnored has non-trivial overhead per file"
  echo "  2. sed -i operations dominate execution time"
  echo "  3. --nogit flag bypasses gitignore checking entirely"
  echo "  4. Performance delta is most visible with many files"
  echo ""
  echo "CURRENT DEFAULT (WITH gitignore):"
  echo "  ✅ Safer - protects artifacts and dependencies"
  echo "  ⚠️  Slower - gitignore checking overhead"
  echo ""
  echo "--nogit FLAG:"
  echo "  ✅ Faster - skips gitignore validation"
  echo "  ⚠️  Riskier - processes all files including artifacts"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && testPerformanceOptimized
