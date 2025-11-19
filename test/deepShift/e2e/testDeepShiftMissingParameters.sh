#!/usr/bin/env bash

testDeepShiftMissingParameters() {
   if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: [testMissingParametersHandling] Starting test..." >&2
    fi

    echo "⚠️ Testing missing parameters handling"
    
    # 1. Test with NO parameters
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: [testMissingParametersHandling] calling 'codeShift' (no args)..." >&2
    fi
    
    local output1
    output1=$(codeShift 2>&1)
    local exit_code1=$?
    
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: [testMissingParametersHandling] No args -> Exit Code: $exit_code1" >&2
        echo "DEBUG: [testMissingParametersHandling] Output start ---" >&2
        echo "$output1" >&2
        echo "DEBUG: [testMissingParametersHandling] Output end ---" >&2
    fi
    
    # 2. Test with ONLY DIRECTORY parameter (missing old/new)
    local test_dir=$(mktemp -d)
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: [testMissingParametersHandling] Created temp dir: $test_dir" >&2
        echo "DEBUG: [testMissingParametersHandling] calling 'codeShift \"$test_dir\"' (missing pattern args)..." >&2
    fi
    
    local output2
    output2=$(codeShift "$test_dir" 2>&1)
    local exit_code2=$?
    
    rm -rf "$test_dir"
    
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: [testMissingParametersHandling] Dir only -> Exit Code: $exit_code2" >&2
        echo "DEBUG: [testMissingParametersHandling] Output start ---" >&2
        echo "$output2" >&2
        echo "DEBUG: [testMissingParametersHandling] Output end ---" >&2
    fi
    
    # 3. Verify results
    # We expect NON-ZERO exit codes for both cases
    if [[ $exit_code1 -ne 0 ]] && [[ $exit_code2 -ne 0 ]]; then
      echo "✅ SUCCESS: Missing parameters properly rejected"
      return 0
    else
      echo "❌ ERROR: Should have failed with missing parameters"
      if [[ -n "$DEBUG" ]]; then
          echo "DEBUG: [Failure Detail] Expected exit codes != 0. Got: Code1=$exit_code1, Code2=$exit_code2" >&2
      fi
      return 1
    fi
}
