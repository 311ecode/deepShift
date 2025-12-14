# codeShift
A specialized Bash utility for **recursive structural refactoring**. It handles batch file and directory renaming with intelligent pattern matching and automatic documentation updates.

## 📚 Navigation
*   **[🏠 EXAMPLES](./EXAMPLES.md)**  
*   **[🏠 Back to Main README](./README.md)**
*   **[🦁 codeShift Documentation (Current)](./codeShift.sh.README.md)**
*   **[🚀 See deepShift (The Engine)](./deepShift.sh.README.md)**
*   **[🏠 README](./README.md)**


---

## Purpose
`codeShift` is designed for **Massive Recursive Discovery**.
It scans your project tree to find **files and directories** matching a pattern, then orchestrates comprehensive updates:
1. **Renames structures**: Files and directories (supporting partial string matches)
2. **Updates references**: Calls `deepShift` to update all content substrings
3. **Syncs docs**: Calls `replaceAndReadme` to update documentation

## Parameters
`codeShift` is flexible. You can call it with or without a specific target directory.

### Syntax 1: Implicit Current Directory (2 arguments)
Use this when you are already in the root of the area you want to refactor.
```bash
codeShift <old_string> <new_string> [--nogit|-n]
```

### Syntax 2: Explicit Target Directory (3 arguments)
Use this when you want to target a specific subdirectory.
```bash
codeShift <target_directory> <old_string> <new_string> [--nogit|-n]
```

## Usage Examples

### Standard Refactor (2 Args)
**Scenario**: You want to rename "userAuth" to "userSecurity" everywhere in the current project.
```bash
# Automatically scans recursively from current directory
codeShift "userAuth" "userSecurity"
```

**Result:**
*   **Filesystem**:
    *   Renames directory `src/features/userAuth/` → `src/features/userSecurity/`
    *   Renames file `tests/userAuthTest.ts` → `tests/userSecurityTest.ts`
*   **Content Substrings (Deep Update)**:
    *   **Imports**: `import { userAuth } ...` → `import { userSecurity } ...`
    *   **Class Names**: `class UserAuthService` → `class UserSecurityService`
    *   **Variables**: `const userAuthConfig` → `const userSecurityConfig`
    *   **CSS/HTML**: `<div class="userAuth-panel">` → `<div class="userSecurity-panel">`

### Targeted Refactor (3 Args)
**Scenario**: You only want to refactor files inside the `tests` folder.
```bash
codeShift "tests" "basicSpec" "advancedSpec"
```

### Partial Directory Renaming
`codeShift` explicitly looks for directory names containing your pattern.
```bash
# Given: src/domains/paymentGateway/
codeShift "Gateway" "Processor"

# Result: src/domains/paymentProcessor/
```

## Which tool should I use?

### 🏗️ codeShift
**The Structural Refactorer.**
Use this when you are organizing the project structure.
- **Scope**: Massive recursive discovery of files and folders.
- **Use Case**: "I need to rename the `User` component to `AccountHolder`."
- **Why**: It treats the **filename/dirname** as the source of truth. It finds the structural items matching the pattern and updates them, then updates all substrings inside files that reference them.

### 🔍 deepShift
**The Disambiguator.**
Use this for raw global string replacement, often needed to fix naming collisions (common with AI-generated code).
- **Scope**: Global content and path string replacement.
- **Use Case**: "The AI generated 50 tests all named `test_01`. I need to rename the ones in the 'login' folder to `login_test_01` to avoid collisions."
- **Why**: It doesn't look for specific file structures first; it finds *strings* everywhere. It is the engine for disambiguation and content updates.

## How It Works

### Discovery Phase
- Scans target directory recursively for **files AND directories** matching the `old_string` pattern.
- Pattern matching is **case-sensitive**.
- Matches substrings (e.g., matching `Auth` inside `userAuth`).

### Three-Phase Orchestration

**Phase 1: Renaming (Files & Directories)**
- Renames files: `MyOldFile.ts` → `MyNewFile.ts`
- Renames directories: `src/old_module/` → `src/new_module/`
- Preserves file extensions and directory depth.

**Phase 2: Content Replacement**
- Calls `deepShift` to update the *contents* of files project-wide.
- **Smart Substring Matching**: It doesn't just replace imports; it replaces *every* instance of the string.
    - `OldClass` becomes `NewClass`
    - `oldVariable` becomes `newVariable`
- Auto-excludes `.git` and `node_modules` by default.

**Phase 3: Documentation Updates**
- Calls `replaceAndReadme`.
- **Helper Logic**: matches the exact filename pattern used in the rename and applies it to your `README.md`.
- Ensures that if you renamed `UserTest.ts` to `UserSpec.ts`, your documentation mentioning `UserTest` is also updated.

## Safety & Exclusions
- **Git Awareness**: Respects `.gitignore` by default.
- **Safety**: Excludes `.git` and `node_modules` to prevent corruption.
- **--nogit**: Use this flag to force processing of ignored files (use with caution).

## Real-World Workflow

### Before: Renaming a Feature Module
```
Project structure:
├── src/
│   └── userAuth/              ← Directory to rename
│       ├── authHelper.ts      (Contains: class AuthHelper)
│       └── authService.ts     (Contains: const AUTH_HELPER = 'AuthHelper')
└── app.ts                     (Imports: from "src/userAuth/authHelper")
```

### Running codeShift
```bash
# 2-argument syntax (runs in current dir)
codeShift "Auth" "Security"
```

### After: Complete Project Update
```
├── src/
│   └── userSecurity/          ✓ Directory renamed
│       ├── securityHelper.ts  ✓ File renamed
│       │                      (Content: class SecurityHelper) ✓ Class renamed
│       └── securityService.ts ✓ File renamed
│                              (Content: const SECURITY_HELPER = 'SecurityHelper') ✓ String renamed
└── app.ts                     ✓ Import paths updated
```

## Output

`codeShift` provides detailed progress output:
```
📂 Working in: /path/to/project
🔍 Scanning for files/dirs matching pattern: *test*
   Found 3 files and 1 directories

📄 File: testExample.sh
   → Renaming to: improvedExample.sh
   ✅ Renamed

📁 Directory: src/testUtils
   → Renaming to: src/improvedUtils
   ✅ Renamed

🔄 Updating content references (content only)...
✅ References updated
```
