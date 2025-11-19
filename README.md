# DeepSeek

### Refactor at the speed of thought.

**DeepSeek** is a robust bash utility suite designed to take the fear out of project-wide refactoring. It is powered by **deepShift**, the global engine, and tamed by **codeShift**, the targeted architect.

---

## The Suite

### 🚀 deepShift: The Showrunner
**Trigger: Global String Existence**

`deepShift` is the engine. It is the brute force behind the operation. It recursively scans everything. It does not care about structure; it cares about **data consistency**.

1.  **Replaces** strings in **file content** (variables, imports, comments).
2.  **Renames** any **files** containing the string.
3.  **Renames** any **directories** containing the string.
4.  **Safety:** Built-in infinite loop prevention and gitignore awareness.

*Use this for renaming variables, fixing typos, or disambiguating names globally.*

### 🦁 codeShift: The Tamer
**Trigger: Filesystem Match**

`codeShift` is the tamer. It is the "allatidomar" (all-around tamer) of the suite. It controls the raw power of `deepShift` by restricting operations to specific structures.

1.  **Scans** your project tree for specific filename/dirname patterns.
2.  **Renames** only those specific structural items.
3.  **Updates** documentation automatically.
4.  **Calls** `deepShift` internally to fix references *after* the structural change.

*Use this when you need to move or rename specific components without affecting the whole world.*

---

## The Decision Matrix

| Goal | Tool | Logic |
|------|------|-------|
| **Rename `const userId` → `const accId`** | `deepShift` | **Crucial:** This is a pure data/content operation. `codeShift` would fail here. |
| **Fix typo `recieve` → `receive`** | `deepShift` | This is a text/string operation, not a file operation. |
| **Rename `User.ts` → `Account.ts`** | `codeShift` | You are targeting a specific file structure. |
| **Rename `src/utils` → `src/helpers`** | `codeShift` | You are targeting a specific directory structure. |

---

## Architecture

```mermaid
graph TD
    User((User))
    
    subgraph "The Engine"
        DS[deepShift]
    end
    
    subgraph "The Tamer"
        CS[codeShift]
        Condition{Files Found?}
    end

    subgraph Project
        FS[Filesystem Names]
        Txt[File Content]
    end

    %% deepShift Path (Direct)
    User -->|Global String/Var| DS
    DS -- "Find & Replace All" --> Txt
    DS -- "Find & Rename All" --> FS

    %% codeShift Path (Targeted)
    User -->|Rename Component| CS
    CS --> Condition
    Condition -- Yes --> FS
    Condition -- Then calls --> DS
    Condition -- No --> Stop((Stop))
```

## Installation

Source the scripts in your shell profile (`.bashrc` or `.zshrc`) to make them available globally:

```bash
# In your .bashrc or profile
source /path/to/DeepSeek/deepShift.sh
source /path/to/DeepSeek/codeShift.sh

# Optional: Add utility helpers
source /path/to/DeepSeek/utils/deepShiftIsPathIgnored.sh
```

## Safety First

Both tools are built with safety rails:
1. **Git Awareness:** Automatically respects `.gitignore` (unless you use `-n`).
2. **Loop Prevention:** Prevents infinite renaming loops (e.g., `test` -> `test_old` -> `test_old_old`).
3. **Identity Check:** Skips operations if `old_string` equals `new_string`.
4. **Structure Preservation:** Keeps file extensions intact during renaming.

> ⚠️ **Always commit your changes** before running a shift operation. Refactoring is a destructive operation.

---

*DeepSeek: Shift happens. Handle it intelligently.*
