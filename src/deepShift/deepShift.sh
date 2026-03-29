#!/usr/bin/env bash

# deepShift wrapper: Works in Bash and Zsh
deepShift() {
    # 🔍 1. Identify the script location (Bash/Zsh compatible)
    local current_script="${BASH_SOURCE[0]:-${(%):-%x}}"
    local script_dir="$(cd "$(dirname "$current_script")" && pwd)"

    # 🚀 2. Identify the JS Engine
    # Prioritize the global ROOT_DIR if set by the loader, fallback to local dir
    local engine_path="${DEEPSHIFT_ROOT_DIR:-$script_dir}/src/deepShift/deepShift.js"
    
    # Fallback check if the above structure is flattened
    if [[ ! -f "$engine_path" ]]; then
        engine_path="${script_dir}/deepShift.js"
    fi

    if [[ ! -f "$engine_path" ]]; then
        echo "Error: deepShift.js not found at $engine_path" >&2
        return 1
    fi

    if ! command -v node &> /dev/null; then
        echo "Error: node is not installed" >&2
        return 1
    fi

    node "$engine_path" "$@"
}

alias dsh=deepShift
