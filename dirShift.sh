#!/usr/bin/env bash

# @file dirShift.sh
# @brief Specialized utility for directory-only structural refactoring
# @description Finds directories matching a pattern, renames them, and updates references.

dirShift() {
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

  # 2. Strategy Selection
  # If the user provided an Explicit Path (e.g., "src/auth") that exists, 
  # we treat it as a specific Move/Rename rather than a pattern search.
  if [[ -d "$target_dir/$old_string" ]] || [[ -d "$old_string" ]]; then
      echo "📂 Mode: Explicit Directory Move"
      # Let deepShift handle the specific path segment move logic
      deepShift "$old_string" "$new_string" "${replace_flags[@]}"
      return $?
  fi

  # 3. Pattern Scan Mode
  (
    cd "$target_dir" || exit 1
    
    echo "📂 Working in: $(pwd)"
    echo "🔍 Scanning for DIRECTORIES matching pattern: *${old_string}*"
    
    # Construct Find Commands safely
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

    # Find matching directories
    local matching_dirs=()
    while IFS= read -r -d '' dir; do
      [[ "$dir" != "." ]] && matching_dirs+=("$dir")
    done < <(find . -type d -name "*${old_string}*" "${find_opts[@]}" -print0 2>/dev/null)

    local dirs_found=${#matching_dirs[@]}
    local dirs_processed=0

    if [[ $dirs_found -eq 0 ]]; then
      echo "⚠️  No directories found matching pattern: *${old_string}*"
      return 1
    fi

    echo "   Found $dirs_found directories."
    
    # Sort directories by depth (deepest first)
    # FIX: Use a temp variable 'p' for gsub calculation to preserve '$0' (the path)
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
        
        if mv "$dir" "$new_dir_path" 2>/dev/null; then
          ((dirs_processed++))
          echo "   ✅ Renamed"
        else
          echo "   ❌ Failed to rename"
        fi
        echo ""
    done
    
    # 5. Global Content Update
    # We update content to match the new directory names (imports, paths, etc.)
    if [[ $dirs_processed -gt 0 ]]; then
        echo "🔄 Updating content references (content only)..."
        deepShift "$old_string" "$new_string" "${replace_flags[@]}" -c 2>/dev/null && echo "✅ References updated"
        echo ""
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Directory shift complete!"
    echo "   Dirs found:  $dirs_found | Processed: $dirs_processed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    return 0
  )
}
