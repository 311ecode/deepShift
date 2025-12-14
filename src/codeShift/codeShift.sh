#!/usr/bin/env bash

# @file codeShift.sh
# @brief Batch rename files and directories with filename pattern matching

codeShift() {
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
  
  # Support both: `codeShift old new` AND `codeShift target_dir old new`
  if [[ ${#args[@]} -eq 3 ]]; then
    target_dir="${args[0]}"
    old_string="${args[1]}"
    new_string="${args[2]}"
  elif [[ ${#args[@]} -eq 2 ]]; then
    old_string="${args[0]}"
    new_string="${args[1]}"
  else
    echo "Usage: codeShift [directory] <old_string> <new_string> [--nogit|-n]" >&2
    return 1
  fi
  
  if [[ -z "$old_string" || -z "$new_string" ]]; then
    echo "Error: Empty strings provided." >&2
    return 1
  fi
  
  if [[ "$old_string" == "$new_string" ]]; then
    echo "⚠️  Old and new strings are identical - no changes needed"
    return 0
  fi

  if [[ ! -d "$target_dir" ]]; then
    echo "ERROR: Directory not found: $target_dir" >&2
    return 1
  fi

  # 2. Execute in Target Directory
  (
    cd "$target_dir" || exit 1
    
    # --- REQUESTED UPDATE: Print current working directory ---
    echo "📂 Working in: $(pwd)"
    echo "🔍 Scanning for files/dirs matching pattern: *${old_string}*"
    
    local files_found=0
    local files_processed=0
    local dirs_found=0
    local dirs_processed=0
    
    # 3. Construct Find Commands safely
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

    # Find matching files
    local matching_files=()
    while IFS= read -r -d '' file; do
      matching_files+=("$file")
    done < <(find . -type f -name "*${old_string}*" "${find_opts[@]}" -print0 2>/dev/null)
    
    # Find matching directories
    local matching_dirs=()
    while IFS= read -r -d '' dir; do
      [[ "$dir" != "." ]] && matching_dirs+=("$dir")
    done < <(find . -type d -name "*${old_string}*" "${find_opts[@]}" -not -path "./.git" -not -path "./.git/*" -print0 2>/dev/null)

    # Sort directories by depth (deepest first)
    if [[ ${#matching_dirs[@]} -gt 0 ]]; then
      local sorted_dirs=()
      while IFS= read -r dir; do
        sorted_dirs+=("$dir")
      done < <(
        printf '%s\n' "${matching_dirs[@]}" | \
        awk '{ print length($0)-length(gsub(/[/]/,"",$0)) " " $0 }' | \
        sort -rn | \
        cut -d' ' -f2-
      )
      matching_dirs=("${sorted_dirs[@]}")
    fi

    echo "   Found ${#matching_files[@]} files and ${#matching_dirs[@]} directories"
    echo ""

    # 4. Process FILES
    for file in "${matching_files[@]}"; do
        if [[ ! -f "$file" ]]; then continue; fi
        local filename=$(basename "$file")
        local filepath=$(dirname "$file")
        if [[ "$filename" != *"$old_string"* ]]; then continue; fi
        
        ((files_found++))
        
        local name_without_ext="${filename%.*}"
        local extension="${filename##*.}"
        if [[ "$name_without_ext" == "$filename" ]]; then
          extension=""
          name_without_ext="$filename"
        fi
        
        local new_name_without_ext="${name_without_ext//$old_string/$new_string}"
        local new_filename
        if [[ -n "$extension" && "$name_without_ext" != "$filename" ]]; then
          new_filename="${new_name_without_ext}.${extension}"
        else
          new_filename="$new_name_without_ext"
        fi
        
        local new_filepath="${filepath}/${new_filename}"
        
        echo "📄 File: $file"
        echo "   → Renaming to: $new_filename"
        
        if mv "$file" "$new_filepath" 2>/dev/null; then
          ((files_processed++))
          echo "   ✅ Renamed"
          replaceAndReadme "$name_without_ext" "$new_name_without_ext" 2>/dev/null
        else
          echo "   ❌ Failed to rename"
        fi
        echo ""
    done

    # 5. Process DIRECTORIES
    for dir in "${matching_dirs[@]}"; do
        [[ ! -d "$dir" ]] && continue
        local dirname=$(basename "$dir")
        local parent_dir=$(dirname "$dir")
        if [[ "$dirname" != *"$old_string"* ]]; then continue; fi
        
        local new_dirname="${dirname//$old_string/$new_string}"
        local new_dir_path="${parent_dir}/${new_dirname}"
        
        ((dirs_found++))
        
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
    
    # 6. Global Content Update (Content ONLY)
    if [[ $files_processed -gt 0 || $dirs_processed -gt 0 ]]; then
        echo "🔄 Updating content references (content only)..."
        deepShift "$old_string" "$new_string" "${replace_flags[@]}" -c 2>/dev/null && echo "✅ References updated"
        echo ""
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Batch rename complete!"
    echo "   Files found: $files_found | Processed: $files_processed"
    echo "   Dirs found:  $dirs_found | Processed: $dirs_processed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $files_found -eq 0 && $dirs_found -eq 0 ]]; then
      echo "⚠️  No files or directories found matching pattern: *${old_string}*"
      return 1
    fi
    
    return 0
  )
}

# find and replace
# just a wrapper for deepShift 
fnr() {
  local old="$1"
  local new="$2"
  shift 2
  deepShift "$old" "$new" "$@"
}