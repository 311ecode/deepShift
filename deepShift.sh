#!/usr/bin/env bash

deepShift() {
  local old="$1"
  local new="$2"
  local use_gitignore=1
  local content_only=0
  local files_only=0
  
  # Feature: Intelligent Path Parsing (Goat & Cabbage Strategy)
  # 1. Does the input exist? (File OR Directory)
  if [[ -e "$old" ]]; then
    # 2. Does the 'new' string look like a simple name (no slashes)?
    if [[ "$new" != *"/"* ]]; then
       # Scenario: Drag & Drop Rename (File OR Directory)
       # e.g., deepShift src/utils/Logger.ts NewLogger -> Rename file (in place)
       # e.g., deepShift src/auth/login newLogin      -> Rename directory (in place)
       # User wants to rename the *entity*, not move the path to root.
       local extracted_name=$(basename -- "$old")
       
       # If it's a file, we likely want to strip the extension to target the "Concept"
       # (e.g. "User.ts" -> "User"). For directories, we keep the full name.
       if [[ -f "$old" ]]; then
         old="${extracted_name%.*}"
       else
         old="$extracted_name"
       fi
       
       [[ -n "$DEBUG" ]] && echo "DEBUG: Entity detected + Simple target. Extracted basename: '$old'" >&2
    else
       # Scenario: Explicit Move or Path Segment Replace
       # e.g., deepShift src/old/File.ts src/new/File.ts
       # User provided a full path target. Keep 'old' as-is to trigger Path Segment Mode.
       [[ -n "$DEBUG" ]] && echo "DEBUG: Entity detected + Path target. Keeping full path: '$old'" >&2
    fi
  elif [[ -e "$old" && "$old" == /* ]]; then
    # Fallback for absolute paths not caught above (rare, but safe)
    local extracted_name=$(basename -- "$old")
    if [[ -f "$old" ]]; then
        old="${extracted_name%.*}"
    else
        old="$extracted_name"
    fi
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

  # Determine safe sed delimiter (if paths contain slashes, use # or |)
  local sed_delim="/"
  if [[ "$old" == *"/"* || "$new" == *"/"* ]]; then
    sed_delim="#"
    if [[ "$old" == *"#"* || "$new" == *"#"* ]]; then
      sed_delim="|"
    fi
  fi

  [[ -n "$DEBUG" ]] && echo "DEBUG: old='$old', new='$new', delim='$sed_delim', gitignore=$use_gitignore" >&2
  
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
        # Use dynamic delimiter
        sed -i "s${sed_delim}${old}${sed_delim}${new}${sed_delim}g" "$file"
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
  
  # Detect if we are in Path Segment Mode (old string contains slash)
  local path_segment_mode=0
  if [[ "$old" == *"/"* ]]; then
    path_segment_mode=1
  fi
  
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
      
      local match_found=0
      local newpath=""
      
      if [[ $path_segment_mode -eq 1 ]]; then
        # --- Path Segment Mode ---
        # Check if the path *ends* with the segment pattern
        # Remove leading ./ for cleaner comparison
        local clean_path="${path#./}"
        
        if [[ "$clean_path" == *"$old" ]]; then
            # Check strict suffix or segment match
            if [[ "$clean_path" == "$old" ]] || [[ "$clean_path" == *"/$old" ]]; then
                local prefix="${clean_path%$old}"
                newpath="./${prefix}${new}"
                
                # Safety: Ensure parent directory exists for the new path
                mkdir -p "$(dirname "$newpath")"
                match_found=1
            fi
        fi
      else
        # --- Basename Mode (Legacy) ---
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
          
          newpath="$dir/$newbase"
          
          if [[ "$path" != "$newpath" ]]; then
            match_found=1
          fi
        fi
      fi

      if [[ $match_found -eq 1 ]]; then
          [[ -n "$DEBUG" ]] && echo "DEBUG: Renaming $path -> $newpath" >&2
          mv -- "$path" "$newpath"
          renamed_paths[$path]=1
          renamed_paths[$newpath]=1
          changed=1
          break
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
