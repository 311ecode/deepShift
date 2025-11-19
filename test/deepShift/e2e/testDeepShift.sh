#!/usr/bin/env bash

# @file testDeepShift.sh
# @brief Test suite for deepShift utility function
# @description Comprehensive testDeepShifts for batch string replacement and file/directory renaming operations

testDeepShift() {
  export LC_NUMERIC=C  # 🔢 Ensures consistent numeric formatting  

  # Test function registry 📋
  local testDeepShift_functions=(
    "testDeepShiftBasicContentReplacement"
    "testDeepShiftFileAndDirectoryRenaming" 
    "testDeepShiftGitDirectoryExclusion"
    "testDeepShiftMissingParameters"
    "testDeepShiftCaseSensitivity"
    "testDeepShiftNoChangesForIdenticalStrings"
    "testDeepShiftNestedStructureHandling"
    "testDeepShiftInfiniteLoopPrevention"
    "testDeepShiftIsPathIgnored"
    "testDeepShiftAutoExcludeGitAndNodeModules"
    "testDeepShiftNogitFlag"
    "testDeepShiftFileAsFirstArgument"
    "testDeepShiftAbsoluteFilePathArgument"
    "testDeepShiftDirectoryPathArgument"
    "testDeepShiftScopeFlags"
  )

  local ignored_testDeepShifts=()  # 🚫 No testDeepShifts ignored

  # Run all testDeepShifts with bashTestRunner 🚀
  bashTestRunner testDeepShift_functions ignored_testDeepShifts
  return $?
}
