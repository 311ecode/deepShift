#!/usr/bin/env bash

deepShiftIsPathIgnored() {
  local path="$1"

  # 1. Check for missing argument
  if [[ -z "$path" ]]; then
    return 1
  fi

  # 2. Check git ignore status
  # git check-ignore returns:
  # 0: path is ignored
  # 1: path is NOT ignored
  # 128: fatal error (e.g. not a git repo)
  
  # We run in a subshell or just capture exit code to avoid exiting the script
  git check-ignore -q "$path"
  local rc=$?

  if [[ $rc -eq 0 ]]; then
    # Path IS ignored
    echo 1
    return 0
  elif [[ $rc -eq 1 ]]; then
    # Path is NOT ignored
    echo 0
    return 0
  else
    # Fatal error (not in git repo, etc.)
    # Pass the error code up so caller knows something went wrong
    return $rc
  fi
}
