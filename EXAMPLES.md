# 🎓 DeepShift Usage Examples

This guide demonstrates the hierarchy of the **DeepShift Suite**.

**The Golden Rule:**
*   Start with **`deepShift`**. It handles 90% of use cases (Content, Files, Directories).
*   Use **`codeShift`** or **`dirShift`** when you want to restrict the **Trigger** (start only if a file/dir exists), but still want the "Landslide" **Effect** (update content/refs too).

---

## 🏗️ The Baseline (Starting Point)

Our project is a user management system with a few legacy naming issues.

### File Structure
```text
project/
├── src/
│   ├── app.ts                  (Main entry)
│   └── modules/
│       └── auth/
│           └── Sessions/       (Directory)
│               └── Session.ts  (File)
└── tests/
    └── SessionTest.ts
```

### File Contents

**`src/modules/auth/Sessions/Session.ts`**
```typescript
export class Session {
  // Legacy variable name
  constructor(public usrId: string) {}
}
```

---

## 🚀 Step 1: The Landslide (`deepShift`)
**Scenario: The Total Concept Pivot.**

**Goal:** Rename "Session" to "Token" **everywhere**.

**Why `deepShift`?**
Because `deepShift` scans **everything**. It doesn't care *what* matches, only *that* it matches.
*   Does a Directory match? **Move it.**
*   Does a Filename match? **Rename it.**
*   Does Content match? **Replace it.**

### Command
```bash
deepShift "Session" "Token"
```

### Result (The Landslide)
Everything changed at once.
1.  **Directory:** `src/.../Sessions/` → `src/.../Tokens/`
2.  **File:** `Session.ts` → `Token.ts`
3.  **Content:** `class Session` → `class Token`
4.  **Imports:** `import { Session }` → `import { Token }`

---

## 🔧 Step 2: The Granular Fix (`deepShift`)
**Scenario: A Simple Variable Rename.**

**Goal:** Rename `usrId` to `userId`.

**How it works:**
You run the exact same command. `deepShift` looks for files or directories named `usrId`.
*   **Files?** None found.
*   **Directories?** None found.
*   **Content?** **Found!**

### Command
```bash
deepShift "usrId" "userId"
```

### Result
It acts as a pure "Find & Replace" tool because that's all it found.

**`src/.../Token.ts`**
```diff
- constructor(public usrId: string) {}
+ constructor(public userId: string) {}
```

---

## 🦁 Step 3: The Conditional Landslide (`codeShift`)
**Scenario: "Restricting the Trigger, not the Impact."**

**Goal:** Rename `*Test` to `*Spec` (e.g., `SessionTest.ts` → `SessionSpec.ts`).

**The Danger of `deepShift` here:**
If we ran `deepShift "Test" "Spec"`, it would rename `const isTestEnv` to `const isSpecEnv`. We don't want that. We only want to start this process **IF** a file matches the pattern.

**How `codeShift` works:**
1.  **Scan:** It looks for Files or Directories matching "Test".
2.  **Found:** It finds `SessionTest.ts`.
3.  **Action:** Now that it found a match, it performs a **Deep Shift** on that specific match.

### Command
```bash
# "If you find a FILE/DIR matching 'Test', rename it AND update its content."
codeShift "tests" "Test" "Spec"
```

### Result
It renames the file, **AND** updates the class name inside it, **AND** updates any directories with that name.

*   **Files:** `SessionTest.ts` → `TokenSpec.ts` (Renamed).
*   **Content:** `class SessionTest` → `class TokenSpec` (Updated!).
*   **Variables:** `const isTestEnv` (Ignored / Safe - because no file named `isTestEnv` exists).

> **Takeaway:** `codeShift` is a "Landslide" that only starts if it hits a File or Directory.

---

## 📂 Step 4: The Architect (`dirShift`)
**Scenario: Structure First.**

**Goal:** Move `src/modules/auth` to `src/security`.

**Why `dirShift`?**
Like `codeShift`, this restricts the **Trigger**. It only acts if the **Directory** exists.
If you had a file named `auth.ts`, `deepShift` would rename it. `dirShift` ignores the file, focusing strictly on the folder structure, but still updates imports referencing that folder.

### Command
```bash
# "If you find a DIRECTORY named 'auth', move it."
dirShift "src/modules/auth" "src/security"
```

### Result
*   **Directories:** `src/modules/auth` moved to `src/security`.
*   **Files:** `src/auth.ts` (Ignored / Safe).
*   **Content:** Imports updated to point to `src/security`.

---

## 🏁 Summary

| Tool | Logic | When to use |
| :--- | :--- | :--- |
| **🚀 deepShift** | **"If text exists..."** | **Default.** Use for 90% of tasks. Pivots concepts, variables, and structures globally. |
| **🦁 codeShift** | **"If file exists..."** | When you want a Deep Shift (Content+File) but only triggered by **Filenames** (e.g. "Test" -> "Spec"). |
| **📂 dirShift** | **"If dir exists..."** | When you are strictly organizing folders and want to ignore matching filenames. |
