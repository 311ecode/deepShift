#!/usr/bin/env bash
testDeepShiftInfiniteLoopPrevention() {
    echo "🔁 Testing infinite loop prevention"
    
    local testDeepShift_dir=$(mktemp -d)
    cd "$testDeepShift_dir" || return 1
    
    # Create file where new name will still contain old pattern
    echo "example content" > example.txt
    
    # This would cause infinite loop: example -> _example -> __example ...
    deepShift "example" "_example"
    
    # Verify: file renamed once, content replaced, no infinite loop
    if [[ -f "_example.txt" ]] && \
       grep -q "_example content" "_example.txt" && \
       ! [[ -f "__example.txt" ]]; then
      echo "✅ SUCCESS: Infinite loop prevented"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 0
    else
      echo "❌ ERROR: Infinite loop not prevented"
      cd - >/dev/null
      rm -rf "$testDeepShift_dir"
      return 1
    fi
  }
