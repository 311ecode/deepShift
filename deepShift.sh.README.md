# deepShift
A comprehensive Bash utility for project-wide string replacement, file renaming, and path segment moving. It features intelligent input detection, gitignore handling, and infinite loop prevention.

## 📚 Navigation
*   **[🏠 EXAMPLES](./EXAMPLES.md)**  
*   **[🏠 Back to Main README](./README.md)**
*   **[🦁 See codeShift (The Tamer)](./codeShift.sh.README.md)**
*   **[🚀 deepShift Documentation (Current)](./deepShift.sh.README.md)**
*   **[🏠 README](./README.md)**

---

## Overview
`deepShift` is a **Context-Aware Replacement Engine**. It intelligently adapts its behavior based on your input:

1.  **String Mode**: Replaces global strings in content and filenames.
2.  **Path Mode**: Moves directories or files and updates references (e.g., imports).
3.  **Entity Mode**: Renames specific files or directories in place (Drag & Drop support).

## Parameters

### Required Parameters
- **old_string/path** (string): The string to replace, or a path to a file/directory.
- **new_string** (string): The replacement string or new path.

### Optional Flags
- **--nogit** or **-n**: Skip `.gitignore` checks and process all files.
- **--files-only** or **-f**: Only rename files/paths; do not modify file content.
- **--content-only** or **-c**: Only replace string in file content; do not rename files.

## Usage Examples

### 1. Global String Replacement
**Scenario:** You want to rename a variable or project concept globally.
```bash
# Renames "userId" to "accId" in content and filenames
deepShift "userId" "accId"
```

### 2. Path Segment Renaming (Moving Directories)
**Scenario:** You want to move a folder and update all imports referencing it.
`deepShift` detects the `/` in your input and switches to Path Mode.
```bash
# Moves src/auth -> src/security
# Updates "import ... from 'src/auth/login'" -> 'src/security/login'
deepShift "src/auth" "src/security"
```

### 3. Smart Drag & Drop (Entity Renaming)
**Scenario:** You drag a file into the terminal to rename it quickly.
If you provide a **path** as the source, but a **simple name** as the destination, `deepShift` assumes you want to rename that specific entity in place.
```bash
# Renames src/components/OldButton.tsx -> src/components/NewButton.tsx
# Updates imports referencing OldButton
deepShift "src/components/OldButton.tsx" "NewButton"
```
*Note: It automatically strips the extension from the old path to find the "Concept", preserving the extension in the rename.*

### 4. Scope Control
```bash
# Rename files/dirs matching "test" to "spec", but KEEP "test" inside the file content
deepShift "test" "spec" --files-only

# Replace "TODO" with "DONE" in content, but don't rename "TODO.md" file
deepShift "TODO" "DONE" --content-only
```

### 5. Skip Gitignore Rules
```bash
# Process even files that are in .gitignore (e.g., build artifacts)
deepShift "old_string" "new_string" --nogit
```

## How It Works (The Logic)

`deepShift` uses a "Goat and Cabbage" strategy to determine your intent:

1.  **Is `old` an existing File or Directory?**
    *   **YES**: It checks `new`.
        *   Does `new` have slashes? (e.g., `src/new/path`) -> **Move Operation**.
        *   Is `new` a simple name? (e.g., `NewName`) -> **Rename Entity Operation** (In Place).
    *   **NO**: It treats `old` as a global pattern.

2.  **Does `old` contain slashes?**
    *   **YES**: **Path Segment Mode**. It matches file paths ending with this segment and moves them. It automatically switches `sed` delimiters to avoid syntax errors.
    *   **NO**: **String Mode**. It matches basenames and content strings.

### Example: Complex Refactoring

**Before:**
```
project/
├── src/
│   ├── auth/                  ← Directory
│   │   └── Login.ts
│   └── App.ts                 (Imports: "src/auth/Login")
```

**Command:**
```bash
deepShift "src/auth" "src/features/security"
```

**After:**
```
project/
├── src/
│   ├── features/
│   │   └── security/          ✓ Directory moved & renamed
│   │       └── Login.ts
│   └── App.ts                 (Updated: "src/features/security/Login")
```

## Key Features

### 🔄 Unified Replacement
- All levels (content, files, directories) updated in single operation.
- Handles nested path creation automatically (`mkdir -p`).

### 🧠 Smart Delimiters
- Automatically detects if your strings contain `/`.
- Switches `sed` delimiters to `#` or `|` to prevent errors.

### 🛡️ Intelligent Safety Features
- **Infinite Loop Prevention**: Tracks renamed paths to avoid processing the same path twice.
- **Git Awareness**: Excludes `.git` and `node_modules` automatically.
- **Path Safety**: Handles relative (`./`) and absolute paths gracefully.

## Critical Considerations

### ⚠️ Destructive Operation
This tool modifies files in place.
1.  **Commit your changes first.**
2.  **Review differences** after running.
3.  **Backup** if unsure.

### ⛔ Anti-Patterns
```bash
# ❌ BAD - Too broad
deepShift "src" "source" 
# This might rename every single file inside src if not careful.

# ✓ GOOD - Specific
deepShift "src/utils" "src/helpers"
```

## Troubleshooting

### "Nothing changed"
- Check case sensitivity.
- Are the files in `.gitignore`? Use `--nogit`.
- Did you provide a path that doesn't match the relative structure?

### "It moved my file to root"
- Ensure you provided the full structure if you intended a move.
- If you intended a rename, ensure the second argument doesn't contain slashes.

## Testing

Run the test suite to verify functionality:
```bash
# All tests
testDeepShift

# Specific Path Segment test
testDeepShiftPathSegmentRenaming
```
