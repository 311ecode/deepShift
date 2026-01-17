/**
 * deepShift.js
 * Node 14+ compatible implementation.
 * Architecture: Discovery -> Planning -> Execution
 */
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Polyfill replaceAll for Node 14
if (!String.prototype.replaceAll) {
    String.prototype.replaceAll = function(str, newStr) {
        if (Object.prototype.toString.call(str).toLowerCase() === '[object regexp]') {
            return this.replace(str, newStr);
        }
        return this.replace(new RegExp(str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), newStr);
    };
}

const EXCLUSION_DIRS = ['.git', 'node_modules'];
const DEBUG = process.env.DEBUG === '1';

function log(msg) {
    if (DEBUG) console.error(`[DS_DEBUG] ${msg}`);
}

function replaceFileContent(filePath, oldString, newString) {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        if (content.includes(oldString)) {
            const newContent = content.replaceAll(oldString, newString);
            fs.writeFileSync(filePath, newContent, 'utf8');
            log(`Content Updated: ${filePath}`);
            return true;
        } else {
            // log(`Content Skip: ${oldString} not found in ${filePath}`);
        }
    } catch (error) {
        log(`Content replace error on ${filePath}: ${error.message}`);
    }
    return false;
}

function isIgnoredByGit(filePath, useGitignore = true) {
    if (!useGitignore) return false;
    const segments = filePath.split(path.sep);
    if (segments.some(segment => EXCLUSION_DIRS.includes(segment))) return true;
    try {
        if (fs.existsSync('.git')) {
            execSync(`git check-ignore -q "${filePath}"`, { stdio: 'pipe' });
            return true;
        }
    } catch (e) { return false; }
    return false;
}

function deepShift(oldString, newString, options = {}) {
    const { contentOnly, filesOnly, useGitignore, rootDir, cliMode, literalOld } = options;

    log(`Start: old="${oldString}" new="${newString}" literal="${literalOld}"`);

    // --- PHASE 0: VALIDATION ---
    if (contentOnly && filesOnly) {
        console.error("Error: Flags --content-only and --files-only are mutually exclusive");
        return 1;
    }

    // Resolve literal path
    let literalOldPath = null;
    if (literalOld) {
        const resolved = path.resolve(rootDir, literalOld);
        if (fs.existsSync(resolved)) literalOldPath = resolved;
    }

    if (!literalOldPath && oldString === newString) {
        if (cliMode) console.log("⚠️ Old and new strings are identical.");
        return 0;
    }

    let processedFileCount = 0;
    let processedDirCount = 0;
    
    const plannedMoves = new Map(); // oldPath -> newPath

    // --- PHASE 1: PLANNING (Entity Mode) ---
    if (literalOldPath && !contentOnly) {
        const stats = fs.statSync(literalOldPath);
        const parentDir = path.dirname(literalOldPath);
        const originalName = path.basename(literalOldPath);
        
        let targetName = newString;
        
        // Strict Extension Logic
        if (stats.isFile()) {
            const ext = path.extname(originalName); 
            const targetExt = path.extname(targetName);
            if (ext && !targetExt) {
                targetName += ext;
            }
        }

        // CRITICAL FIX: Path Resolution Logic
        let newPath;
        if (targetName.includes(path.sep) || targetName.includes('/')) {
            // If target has path separators (e.g. "src/security"), resolve relative to rootDir
            // This prevents "src/src/security" duplication
            newPath = path.resolve(rootDir, targetName);
        } else {
            // If simple name (e.g. "security"), resolve relative to current parent
            newPath = path.join(parentDir, targetName);
        }

        if (literalOldPath !== newPath) {
            plannedMoves.set(literalOldPath, newPath);
        }
    }

    // --- PHASE 2: PLANNING (Global Structure) ---
    if (!contentOnly) {
        const entities = [];
        const scan = (dir) => {
            try {
                const items = fs.readdirSync(dir, { withFileTypes: true });
                for (const item of items) {
                    const full = path.join(dir, item.name);
                    if (isIgnoredByGit(full, useGitignore)) continue;
                    
                    if (plannedMoves.has(full)) continue;

                    if (item.isDirectory()) {
                        scan(full);
                        entities.push({ path: full, isDir: true });
                    } else {
                        entities.push({ path: full, isDir: false });
                    }
                }
            } catch (e) {}
        };
        scan(rootDir);

        // --- ADAPTIVE SORTING STRATEGY ---
        const isPathMode = oldString.includes('/') || oldString.includes('\\');
        
        if (isPathMode) {
            entities.sort((a, b) => a.path.length - b.path.length); // Shallowest First
        } else {
            entities.sort((a, b) => b.path.length - a.path.length); // Deepest First
        }

        for (const entity of entities) {
            const curr = entity.path;
            
            // In Path Mode, skip children of moved directories
            if (isPathMode) {
                let isOrphan = false;
                for (const [movedPath] of plannedMoves) {
                    if (curr.startsWith(movedPath + path.sep)) {
                        isOrphan = true;
                        break;
                    }
                }
                if (isOrphan) continue;
            }

            let next = null;
            if (isPathMode) {
                // Use relative path for comparison to support path segment replacement from root
                const relCurr = path.relative(rootDir, curr);
                if (relCurr.includes(oldString)) {
                    // Replace in the relative string, then join back
                    const relNext = relCurr.replaceAll(oldString, newString);
                    next = path.resolve(rootDir, relNext);
                }
            } else {
                const base = path.basename(curr);
                if (base.includes(oldString)) {
                    const newBase = base.replaceAll(oldString, newString);
                    next = path.join(path.dirname(curr), newBase);
                }
            }

            if (next && next !== curr) {
                plannedMoves.set(curr, next);
            }
        }
    }

    // --- PHASE 3: EXECUTION (Structural) ---
    for (const [oldP, newP] of plannedMoves) {
        try {
            if (!fs.existsSync(oldP)) continue; 

            const parent = path.dirname(newP);
            if (!fs.existsSync(parent)) fs.mkdirSync(parent, { recursive: true });
            
            fs.renameSync(oldP, newP);
            
            if (cliMode) console.log(`📄 Renamed: ${path.relative(rootDir, oldP)} → ${path.relative(rootDir, newP)}`);
            
            if (fs.statSync(newP).isDirectory()) processedDirCount++;
            else processedFileCount++;
        } catch (e) {
            log(`Move failed: ${e.message}`);
        }
    }

    // --- PHASE 4: EXECUTION (Content) ---
    if (!filesOnly) {
        const scanFiles = (dir) => {
            try {
                const items = fs.readdirSync(dir, { withFileTypes: true });
                for (const item of items) {
                    const full = path.join(dir, item.name);
                    if (isIgnoredByGit(full, useGitignore)) continue;
                    
                    if (item.isDirectory()) {
                        scanFiles(full);
                    } else if (item.isFile()) {
                        if (replaceFileContent(full, oldString, newString)) processedFileCount++;
                    }
                }
            } catch (e) {}
        };
        scanFiles(rootDir);
    }

    return 0;
}

function parseArgs() {
    const args = process.argv.slice(2);
    const options = {
        contentOnly: args.includes('--content-only') || args.includes('-c'),
        filesOnly: args.includes('--files-only') || args.includes('-f'),
        useGitignore: !(args.includes('--nogit') || args.includes('-n')),
        cliMode: true,
        rootDir: process.cwd()
    };

    const pos = args.filter(arg => !arg.startsWith('-'));
    if (pos.length < 2) throw new Error("Usage: node deepShift.js <old> <new>");

    let rawOld = pos[0];
    let newString = pos[1];
    let oldString = rawOld;

    // Concept Discovery Logic
    if (fs.existsSync(rawOld) && !newString.includes(path.sep)) {
        const basename = path.basename(rawOld);
        if (fs.statSync(rawOld).isFile()) {
            const ext = path.extname(basename);
            oldString = ext ? basename.slice(0, -ext.length) : basename;
        } else {
            oldString = basename;
        }
    }
    
    options.literalOld = rawOld;
    return { oldString, newString, options };
}

if (require.main === module && !process.argv.includes('--test')) {
    try {
        const { oldString, newString, options } = parseArgs();
        process.exit(deepShift(oldString, newString, options));
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
}

module.exports = { deepShift };
