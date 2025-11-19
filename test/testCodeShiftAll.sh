#!/usr/bin/env bash
testCodeShiftAll() {
  export LC_NUMERIC=C  # 🔢 Ensures consistent numeric formatting  

  # Test function registry 📋
  local testDeepShift_functions=(
    "testDeepShift"
    "testCodeShift" 
  )

  local ignored_testDeepShifts=()  # 🚫 No testDeepShifts ignored

  # Run all testDeepShifts with bashTestRunner 🚀
  bashTestRunner testDeepShift_functions ignored_testDeepShifts
  return $?
}