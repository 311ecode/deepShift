#!/usr/bin/env bash

# @file dirShift.sh
# @brief Specialized utility for directory-only structural refactoring

dirShift() {
  local debug_mode=0
  if [[ "$DEBUG" == "1" ]]; then debug_mode=1; fi
  
  log_debug() {
    if [[ "$debug_mode" -eq 1 ]]; then
      echo "[DIRSHIFT_DEBUG] $*" >&2
    fi
  }

  log_debug "Starting dirShift with args: $*"

  # 1. Parse Arguments
  local args=()
  local skip_git=false
  local replace_flags=()
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --nogit|-n)
        skip_git=true
        replace_flags+=("-n")
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done
  
  local target_dir="."
  local old_string=""
  local new_string=""
  
  if [[ ${#args[@]} -eq 3 ]]; then
    target_dir="${args[0]}"
    old_string="${args[1]}"
    new_string="${args[2]}"
  elif [[ ${#args[@]} -eq 2 ]]; then
    old_string="${args[0]}"
    new_string="${args[1]}"
  else
    echo "Usage: dirShift [directory] <old_pattern> <new_pattern> [--nogit|-n]" >&2
    return 1
  fi
  
  if [[ -z "$old_string" || -z "$new_string" ]]; then
    echo "Error: Empty strings provided." >&2
    return 1
  fi

  if [[ ! -d "$target_dir" ]]; then
    echo "ERROR: Directory not found: $target_dir" >&2
    return 1
  fi

  log_debug "Parsed: target='$target_dir' old='$old_string' new='$new_string'"

  # 2. Strategy Selection
  local explicit_path_relative="$target_dir/$old_string"
  
  # Check existence. Note: -d checks if it exists.
  if [[ -d "$explicit_path_relative" ]] || [[ -d "$old_string" ]]; then
      echo "📂 Mode: Explicit Directory Move"
      log_debug "Delegating to deepShift..."
      
      # FIX: Pass the cleanest possible string to deepShift to ensure content matching works.
      # If target_dir is "." (default), pass old_string directly (e.g. "src/auth")
      # instead of "./src/auth".
      
      if [[ "$target_dir" == "." ]]; then
         deepShift "$old_string" "$new_string" "${replace_flags[@]}"
      else
         deepShift "$target_dir/$old_string" "$new_string" "${replace_flags[@]}"
      fi
      
      return $?
  fi

  # 3. Pattern Scan Mode
  (
    cd "$target_dir" || exit 1
    
    echo "📂 Working in: $(pwd)"
    echo "🔍 Scanning for DIRECTORIES matching pattern: *${old_string}*"
    log_debug "Scanning in $(pwd)"
    
    local find_opts=( )
    if [[ "$skip_git" != "true" ]]; then
      find_opts+=( -not -path "./.git/*" -not -path "./node_modules/*" )
      if [[ -f .gitignore ]]; then
        while IFS= read -r pattern; do
          [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
          pattern="${pattern%/}"
          find_opts+=( -not -path "./${pattern}/*" -not -path "./${pattern}" )
        done < .gitignore
      fi
    fi

    local matching_dirs=()
    while IFS= read -r -d '' dir; do
      [[ "$dir" != "." ]] && matching_dirs+=("$dir")
    done < <(find . -type d -name "*${old_string}*" "${find_opts[@]}" -print0 2>/dev/null)

    local dirs_found=${#matching_dirs[@]}
    local dirs_processed=0

    log_debug "Found $dirs_found directories matching pattern"

    if [[ $dirs_found -eq 0 ]]; then
      echo "⚠️  No directories found matching pattern: *${old_string}*"
      return 1
    fi

    echo "   Found $dirs_found directories."
    
    # Sort directories by depth (deepest first)
    local sorted_dirs=()
    while IFS= read -r dir; do
      sorted_dirs+=("$dir")
    done < <(
      printf '%s\n' "${matching_dirs[@]}" | \
      awk '{ p=$0; count=gsub(/\//, "", p); print count " " $0 }' | \
      sort -rn | \
      cut -d' ' -f2-
    )

    echo ""

    # 4. Process DIRECTORIES
    for dir in "${sorted_dirs[@]}"; do
        [[ ! -d "$dir" ]] && continue
        local dirname=$(basename "$dir")
        local parent_dir=$(dirname "$dir")
        if [[ "$dirname" != *"$old_string"* ]]; then continue; fi
        
        local new_dirname="${dirname//$old_string/$new_string}"
        local new_dir_path="${parent_dir}/${new_dirname}"
        
        echo "📁 Directory: $dir"
        echo "   → Renaming to: $new_dirname"
        log_debug "mv $dir -> $new_dir_path"
        
        if mv "$dir" "$new_dir_path" 2>/dev/null; then
          ((dirs_processed++))
          echo "   ✅ Renamed"
        else
          echo "   ❌ Failed to rename"
        fi
        echo ""
    done
    
    # 5. Global Content Update
    if [[ $dirs_processed -gt 0 ]]; then
        echo "🔄 Updating content references..."
        log_debug "Calling deepShift content-only update"
        deepShift "$old_string" "$new_string" "${replace_flags[@]}" -c
        echo "✅ References updated"
        echo ""
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Directory shift complete!"
    echo "   Dirs found:  $dirs_found | Processed: $dirs_processed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    return 0
  )
}
