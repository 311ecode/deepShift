# dirShift
A specialized Bash utility for **architectural refactoring**. It focuses strictly on finding, renaming, or moving directories and updating the project references to match.

## 📚 Navigation
*   **[🏠 EXAMPLES](./EXAMPLES.md)** (You are here)
*   **[🏠 Back to Main README](./README.md)**
*   **[🦁 See codeShift (The Tamer)](./codeShift.sh.README.md)**
*   **[🚀 See deepShift (The Engine)](./deepShift.sh.README.md)**

---

## Purpose
`dirShift` is the **Architect**.
It is designed to safely restructure folders without accidentally renaming files that happen to share the same name. It operates in two modes:

1.  **Explicit Mode**: Moves a specific path (wrapper for `deepShift`).
2.  **Pattern Mode**: Finds all directories matching a name, renames them, and updates content.

## Usage

### Syntax
```bash
dirShift [target_dir] <old_pattern> <new_pattern> [--nogit|-n]
```

### Scenario 1: Explicit Move (Specific Path)
If you provide a path that exists, `dirShift` behaves like a smart `mv` command that also updates imports.
```bash
# Moves src/auth -> src/security
# Updates "import ... from 'src/auth'"
dirShift "src/auth" "src/security"
```

### Scenario 2: Recursive Pattern Rename (Architecture Update)
If you provide a name that exists as *directories* in multiple places, it renames them all.
```bash
# Renames ALL 'utils' folders to 'helpers'
# src/utils -> src/helpers
# src/api/utils -> src/api/helpers
dirShift "utils" "helpers"
```
*Note: A file named `utils.ts` would be IGNORED. This is the key difference from `codeShift`.*

## The Logic Flow

1.  **Input Check**: Is `$1` an explicit directory path?
    *   **Yes**: Pass control to `deepShift` (Path Segment Mode). Done.
2.  **Pattern Scan**: Scan for directories matching the pattern.
    *   **Found**: Rename them (deepest first) to prevent path invalidation.
    *   **Not Found**: Stop.
3.  **Reference Update**:
    *   After successful directory renaming, `dirShift` calls `deepShift` in **Content Only Mode (`-c`)**.
    *   This ensures that all imports, config strings, and documentation referencing the old directory names are updated to the new names.

## Comparison

| Tool | Scope | Example Action |
|------|-------|----------------|
| **codeShift** | Files AND Directories | Renames `User.ts` AND `User/` folder. |
| **dirShift** | **Directories ONLY** | Renames `User/` folder. Ignores `User.ts`. |
| **deepShift** | Strings / Paths | Replaces "User" text anywhere. |

Use `dirShift` when you are reorganizing the folder structure of your application.
