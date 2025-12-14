#!/usr/bin/env bash

deepShift() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local deepshift_js="${script_dir}/deepShift.js"

    if [[ ! -f "$deepshift_js" ]]; then
        echo "Error: deepShift.js not found at $deepshift_js" >&2
        return 1
    fi

    if ! command -v node &> /dev/null; then
        echo "Error: node is not installed" >&2
        return 1
    fi

    node "$deepshift_js" "$@"
}

