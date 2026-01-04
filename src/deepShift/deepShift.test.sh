#!/usr/bin/env bash

deepShift.test() {
    command -v markdown-show-help-registration &>/dev/null && eval "$(markdown-show-help-registration)"
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local src_path="${script_dir}/deepShift.test.js"

    if [[ ! -f "$src_path" ]]; then
        echo "Error: deepShift.test.js not found at $src_path" >&2
        return 1
    fi

    if ! command -v node &> /dev/null; then
        echo "Error: node is not installed" >&2
        return 1
    fi

    node "$src_path" "$@"
}
## created by util/make_bash_wrapper.sh 
