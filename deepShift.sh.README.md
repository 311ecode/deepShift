# deepShift
A comprehensive Bash utility for project-wide string replacement and file/directory renaming with intelligent gitignore handling and infinite loop prevention.

## Overview
`deepShift` is a **three-level replacement engine** that operates simultaneously on:
1. **Content Level**: String replacement in file contents
2. **File Level**: File renaming based on pattern matching
3. **Directory Level**: Directory renaming based on pattern matching

All three levels are updated in a single coordinated operation, ensuring your entire project stays consistent.

## Parameters

### Required Parameters
- **old_string** (string): The exact string pattern to search for and replace
- **new_string** (string): The exact replacement string

### Optional Flags
- **--nogit** or **-n**: Skip `.gitignore` checks and process all files (including ignored files)
- **--files-only** or **-f**: Only rename files and directories; do not modify file content
- **--content-only** or **-c**: Only replace string in file content; do not rename files or directories

## Usage Examples

### Basic Content Replacement
```bash
# Replace all occurrences of "old_project" with "new_project" in all files
deepShift "old_project" "new_project"
```

### Scope Control (New!)
```bash
# Rename files/dirs matching "test" to "spec", but KEEP "test" inside the file content
deepShift "test" "spec" --files-only

# Replace "TODO" with "DONE" in content, but don't rename "TODO.md" file
deepShift "TODO" "DONE" --content-only
```

### Filename Renaming
```bash
# Rename all files containing "legacy" to "modern"
deepShift "legacy" "modern"
```

### Directory Renaming (Intentional Operation)
```bash
# Rename directories AND update all internal references
# This renames "src_old" directory to "src_new" and updates all references
deepShift "src_old" "src_new"
```

### Skip Gitignore Rules
```bash
# Process even files that are in .gitignore (e.g., build artifacts, vendor code)
deepShift "old_string" "new_string" --nogit
# Short form:
deepShift "old_string" "new_string" -n
```

### Project-Wide Refactoring
```bash
# Complete namespace migration across entire project
deepShift "com.oldcompany" "com.newcompany"

# Update deprecated API calls everywhere
deepShift "oldAPI.call()" "newAPI.execute()"

# Rename internal modules project-wide
deepShift "internal_utils" "shared_utilities"
```

## How It Works

### Three-Phase Operation

**Phase 1: File Content Replacement**
- Scans all files for the old_string pattern
- Replaces every occurrence with new_string
- Uses `sed` for efficient bulk replacement
- Maintains file structure and formatting
- *Skipped if `--files-only` is used*

**Phase 2: File Renaming**
- Identifies all files containing old_string in their names
- Preserves file extensions
- Renames files from old pattern to new pattern
- Updates all references to those filenames in content
- *Skipped if `--content-only` is used*

**Phase 3: Directory Renaming**
- Identifies all directories containing old_string in their names
- Renames from deepest level first (prevents path conflicts)
- Prevents infinite loops through iteration tracking
- All files within renamed directories maintain correct paths
- *Skipped if `--content-only` is used*

### Example: Complete Refactoring

**Before:**
```
project/
├── src_old/
│   ├── old_module.js
│   └── handler.js (contains: "const mod = require('./old_module')")
├── tests/
│   └── test_old_module.js (contains: "src_old/old_module")
└── README.md (mentions: "See src_old for details")
```

**Command:**
```bash
deepShift "src_old" "src_new"
```

**After:**
```
project/
├── src_new/                          ✓ Directory renamed
│   ├── old_module.js
│   └── handler.js (updated: "const mod = require('./old_module')")
├── tests/
│   └── test_old_module.js (updated: "src_new/old_module")
└── README.md (updated: "See src_new for details")
```

## Key Features

### 🔄 Unified Replacement
- All three levels (content, files, directories) updated in single operation
- No partial updates or missed references
- Consistent project state throughout

### 🎯 Precise Pattern Matching
- Exact string matching (not regex)
- Case-sensitive by default
- Matches anywhere in the string (beginning, middle, end)

### 🛡️ Intelligent Safety Features

#### Infinite Loop Prevention
- Detects when new_string contains old_string
- Example: `deepShift "example" "_example"` won't create `__example`, `___example`, etc.
- Tracks renamed paths to avoid processing the same path twice
- Uses iteration tracking to terminate safely

#### Identical String Check
- Detects when old_string == new_string
- Skips processing to avoid unnecessary operations
- Files remain unchanged (no md5 hash updates)

#### Path Safety
- Excludes `.git` directory automatically (preserves repo history)
- Excludes `node_modules` directory automatically
- Prevents accidental corruption of version control metadata
- Respects `.gitignore` patterns by default

### 🚀 Performance Features
- Efficient recursive directory traversal
- Batch file processing with sed
- Uses find for optimal file discovery
- Minimal memory overhead for large projects

### 🔍 Git Integration
- **Default behavior**: Respects `.gitignore` patterns
- Caching mechanism for gitignore checks
- Can be bypassed with `--nogit` flag for special cases
- Preserves repository integrity

## Critical Considerations

### ⚠️ Before You Run This

This is a **destructive operation** that modifies your entire project. **Always**:

1. **Commit your changes first**
   ```bash
   git add .
   git commit -m "checkpoint before refactoring"
   ```

2. **Create a backup or test branch**
   ```bash
   git checkout -b refactor/rename-old-to-new
   ```

3. **Understand the scope**
   - What files will be affected?
   - Are there references in comments, documentation, strings?
   - Will third-party integrations break?

4. **Test the operation**
   ```bash
   # Run in a test directory first
   cp -r /path/to/project /tmp/test_project
   cd /tmp/test_project
   deepShift "old_string" "new_string"
   # Review changes
   ```

5. **Review all changes**
   ```bash
   git diff
   git status
   ```

### 🎯 Real-World Use Cases

#### Configuration Value Changes
```bash
# Update all occurrences of a configuration key
deepShift "DATABASE_HOST_OLD" "DATABASE_HOST_NEW"
```

#### API Endpoint Migration
```bash
# Update all API calls to new endpoint
deepShift "/api/v1/old_endpoint" "/api/v2/new_endpoint"
```

#### Module/Package Renaming
```bash
# Rename internal module used throughout project
deepShift "authentication_old" "auth_new"
```

#### Namespace Migration
```bash
# Update all namespace references
deepShift "MyOldCompany" "MyNewCompany"
```

#### Version Updates
```bash
# Update deprecated function names
deepShift "oldDeprecatedFunc()" "newModernFunc()"
```

## Important Caveat: Filename vs Content Collision

### The Problem
When your filename and content use the same pattern, `deepShift` updates **both**:

```bash
# File: what.sh
# Contains function: what()

deepShift "what" "that"
# Results in:
# - File renamed: what.sh → that.sh  ✓
# - Function renamed: what() → that()  ✓ (but maybe not intended!)
```

This is **by design** - the tool replaces the string everywhere. If you only want to rename the file, not the function, you have options:

### Solution 1: Use More Specific Pattern
```bash
# Rename file only, not the function
deepShift "what.sh" "that.sh"
# This only matches the filename, not the function name
```

### Solution 2: Manual Approach
```bash
# Step 1: Rename file manually
mv what.sh that.sh

# Step 2: Update internal references if needed
deepShift "function what" "function that"
# or
deepShift "what()" "that()"
```

### Solution 3: Use Separate Operations
```bash
# Rename just the file with specific pattern
deepShift "what.sh" "that.sh"

# Then if you want to rename the function too:
deepShift "function what" "function that"
```

### When This Matters Most
- Renaming files that contain functions/classes with matching names
- Renaming modules where the module name and exported function have same name
- Renaming test files that contain test functions with related names
- Any situation where filename and content accidentally collide

**Rule of thumb**: The more specific your pattern, the safer your operation.

### ⛔ Anti-Patterns (Don't Do This)

#### Too Broad Patterns
```bash
# ❌ BAD - Will match way too much
deepShift "old" "new"

# ✓ GOOD - Specific and intentional
deepShift "old_database_name" "new_database_name"
```

#### Without Version Control
```bash
# ❌ BAD - No way to rollback
deepShift "old_string" "new_string"

# ✓ GOOD - Easy to revert if needed
git commit -m "pre-refactor backup"
deepShift "old_string" "new_string"
git commit -m "refactored: old_string → new_string"
```

#### Blindly Using --nogit
```bash
# ❌ RISKY - Modifies files in .gitignore (build artifacts, dependencies)
deepShift "version" "2.0" --nogit

# ✓ SAFE - Respects .gitignore by default
deepShift "version" "2.0"
```

## Processing Details

### File Selection
- Scans all files recursively from current directory
- Uses `-type f` to select regular files only
- Pattern matching: `*old_string*` (glob expansion)
- Files must exist and be readable

### Content Replacement Mechanism
- Uses `sed` with global flag: `s/old_string/new_string/g`
- Case-sensitive matching
- Replaces all occurrences in each file
- Handles special characters (may need escaping in some cases)

### Directory Processing Order
- **Depth-first traversal**: Processes deepest directories first
- **Prevents path conflicts**: Renames subdirectories before parent directories
- **Tracks renamed paths**: Maintains state to avoid duplicate processing
- **Iterative approach**: Continues until no more matches found

### Exclusion Logic
- `.git/` → Always excluded
- `node_modules/` → Always excluded  
- Files in `.gitignore` → Excluded by default (use `--nogit` to override)
- Hidden files → Processed normally

## Error Handling

Clear error messages for:
- Missing required parameters
- Invalid string patterns
- File permission issues
- Disk space problems
- Git operation failures

Exit codes:
- `0`: Success
- `1`: Failure (parameter validation, file errors, etc.)

## Performance Characteristics

- **Small projects** (< 1000 files): < 1 second
- **Medium projects** (1000-10000 files): 1-5 seconds
- **Large projects** (10000+ files): 5-30 seconds
- Memory usage is O(n) where n = number of matched files
- Disk usage: Same as original project (no temporary files)

## Related Functions

### `codeShift`
A wrapper around `deepShift` focused on **file discovery**:
- Scans directory for files matching pattern
- Automatically calls `deepShift` for each file
- Calls `replaceAndReadme` for documentation updates
- Better for "find and update" workflows

### `replaceAndReadme`
Specialized documentation updater:
- Updates README and documentation files
- Can be called standalone
- Ensures docs stay in sync with code changes

## Safety Checklist

Before running `deepShift`, confirm:
- [ ] Changes are committed to version control
- [ ] You have a backup or are on a test branch
- [ ] You understand what strings will be replaced
- [ ] You've tested with a copy of the project
- [ ] You've reviewed the expected changes
- [ ] You know how to rollback if needed (git revert)
- [ ] All team members are aware of the change
- [ ] Build/test suite still passes after changes

## Rollback Procedure

If something goes wrong:

```bash
# Immediate rollback
git reset --hard HEAD~1

# Or revert while keeping commit history
git revert HEAD

# Or restore specific files
git checkout HEAD -- path/to/file
```

## Examples in Context

### Example 1: Package Rename
```bash
# React component library rename
deepShift "my-ui-library" "enterprise-ui-kit"
# Updates: import statements, require() calls, filenames, directory names
```

### Example 2: Feature Flag Migration
```bash
# Update old feature flags
deepShift "EXPERIMENTAL_NEW_API" "STABLE_NEW_API"
# Updates: config files, conditional logic, documentation
```

### Example 3: Database Migration
```bash
# Update all database column references
deepShift "user_id" "userId"
# Updates: SQL queries, ORM models, API responses, documentation
```

## Troubleshooting

### Nothing changed
- Check if pattern exists: `grep -r "old_string" .`
- Pattern might be case-sensitive: `grep -ri "old_string" .`
- Files might be excluded by .gitignore: Use `--nogit` flag
- Pattern might need escaping for special characters

### Wrong files were changed
- Pattern was too broad - use more specific strings
- Review with `git diff` before committing
- Use `git reset --hard` to revert

### Infinite loop or hanging
- This shouldn't happen due to infinite loop prevention
- If it does, press Ctrl+C to interrupt
- Create an issue with your usage details

## Testing

Run the comprehensive test suite to verify functionality:
```bash
# All tests
testDeepShift

# Individual test
DEBUG=1 testBasicContentReplacement
```

Tests cover:
- Basic content replacement
- File renaming
- Directory renaming
- Case sensitivity
- Nested structures
- Git exclusions
- Infinite loop prevention
- Parameter validation
- Error handling
