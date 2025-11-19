#!/usr/bin/env bash

deepShift() {
  local old="$1"
  local new="$2"
  local use_gitignore=1
  local content_only=0
  local files_only=0
  
  # Feature: Allow file OR directory path as first argument (VS Code Drag & Drop support)
  if [[ -e "$old" ]]; then
    local extracted_name=$(basename -- "$old")
    # If it looks like a file with extension, strip it.
    old="${extracted_name%.*}"
    [[ -n "$DEBUG" ]] && echo "DEBUG: Input was a path. Extracted old string: '$old'" >&2
  fi

  # Parse flags
  local args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --nogit|-n)
        use_gitignore=0
        shift
        ;;
      --content-only|-c)
        content_only=1
        shift
        ;;
      --files-only|-f)
        files_only=1
        shift
        ;;
      *)
        # If it's one of the first two args (old/new), keep them, otherwise shift
        if [[ -z "$old" ]]; then old="$1"; shift; continue; fi
        if [[ -z "$new" ]]; then new="$1"; shift; continue; fi
        shift 
        ;;
    esac
  done

  if [[ -z "$old" || -z "$new" ]]; then
    echo "Usage: deepShift <old_string|path> <new_string> [--nogit|-n] [--content-only|-c] [--files-only|-f]"
    return 1
  fi

  if [[ $content_only -eq 1 && $files_only -eq 1 ]]; then
    echo "Error: --content-only and --files-only are mutually exclusive." >&2
    return 1
  fi

  [[ -n "$DEBUG" ]] && echo "DEBUG: old='$old', new='$new', use_gitignore=$use_gitignore, content_only=$content_only, files_only=$files_only" >&2
  
  # 1. Content Replacement (Skip if files_only is set)
  if [[ $files_only -eq 0 ]]; then
    grep -rIl --exclude-dir=.git --exclude-dir=node_modules "$old" . | while IFS= read -r file; do
      if [[ -f "$file" ]]; then
        local ignore_status=0
        
        if [[ $use_gitignore -eq 1 ]]; then
          # Assuming deepShiftIsPathIgnored is globally available or aliased
          ignore_status=$(deepShiftIsPathIgnored "$file" 2>/dev/null || echo 0)
        fi
        
        if [[ "$ignore_status" -eq 1 ]]; then
          [[ -n "$DEBUG" ]] && echo "DEBUG: Skipping ignored file: $file" >&2
          continue
        fi
        
        [[ -n "$DEBUG" ]] && echo "DEBUG: Replacing in $file" >&2
        sed -i "s/$old/$new/g" "$file"
      fi
    done
  fi

  if [[ $content_only -eq 1 ]]; then
    [[ -n "$DEBUG" ]] && echo "DEBUG: Content-only mode active. Skipping rename." >&2
    return 0
  fi

  [[ -n "$DEBUG" ]] && echo "DEBUG: Starting file/directory renaming" >&2

  # 2. Renaming
  declare -A renamed_paths
  local changed=1
  
  while [[ $changed -eq 1 ]]; do
    changed=0
    
    while IFS= read -r path; do
      [[ ! -e "$path" ]] && continue
      
      if [[ "$path" == *"/.git"* ]] || [[ "$path" == *"/node_modules"* ]]; then
        continue
      fi
      
      local ignore_status=0
      if [[ $use_gitignore -eq 1 ]] && git rev-parse --git-dir >/dev/null 2>&1; then
         # Assuming deepShiftIsPathIgnored is globally available
        ignore_status=$(deepShiftIsPathIgnored "$path" 2>/dev/null || echo 0)
      fi
      
      if [[ "$ignore_status" -eq 1 ]]; then
        continue
      fi
      
      if [[ -n "${renamed_paths[$path]}" ]]; then
        continue
      fi
      
      local base=$(basename "$path")
      
      if [[ "$base" == *"$old"* ]]; then
        local dir=$(dirname "$path")
        local newbase
        
        if [[ -f "$path" && "$base" == *.* ]]; then
          local name="${base%.*}"
          local ext="${base##*.}"
          newbase="${name//$old/$new}.$ext"
        else
          newbase="${base//$old/$new}"
        fi
        
        local newpath="$dir/$newbase"
        
        if [[ "$path" != "$newpath" ]]; then
          [[ -n "$DEBUG" ]] && echo "DEBUG: Renaming $path -> $newpath" >&2
          mv -- "$path" "$newpath"
          renamed_paths[$path]=1
          renamed_paths[$newpath]=1
          changed=1
          break
        fi
      fi
    done < <(find . -depth -not -path "*/.git*" -not -path "*/node_modules*")
  done
  
  [[ -n "$DEBUG" ]] && echo "DEBUG: Renaming complete" >&2
}

rnr() {
  local old="$1"
  local new="$2"
  shift 2
  deepShift "$old" "$new" "$@" -n
}
