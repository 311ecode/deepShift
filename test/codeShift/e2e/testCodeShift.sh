#!/usr/bin/env bash

# @file testCodeShift.sh
# @brief Test suite for codeShift utility function
# @description Comprehensive testCodeShifts for batch file renaming with pattern matching

testCodeShift() {
  export LC_NUMERIC=C  # 🔢 Ensures consistent numeric formatting

  # Test function registry 📋
  local testCodeShift_functions=(
    "testCodeShiftBasicFileDiscovery"
    "testCodeShiftBasicRenaming"
    "testCodeShiftMultipleFilesMatching"
    "testCodeShiftNestedDirectoryStructure"
    "testCodeShiftPartialStringMatching"
    "testCodeShiftPreservesFileExtension"
    "testCodeShiftReturnsToOriginalDirectory"
    "testCodeShiftInvalidDirectoryHandling"
    "testCodeShiftMissingParametersHandling"
    "testCodeShiftContentReplacementViaDeepShift"
    "testCodeShiftDocumentationUpdateViaReplaceAndReadme"
    "testCodeShiftNoFilesFoundScenario"
  )

  local ignored_testCodeShifts=()  # 🚫 No testCodeShifts ignored

  # Run all testCodeShifts with bashTestRunner 🚀
  bashTestRunner testCodeShift_functions ignored_testCodeShifts
  return $?
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && testCodeShift
