/**
 * deepShift.js
 * A single-file, dependency-free implementation of deepShift logic in Node.js.
 * Implements content replacement and file/directory renaming.
 *
 * Usage:
 * node deepShift.js <old_string|path> <new_string> [--content-only|-c] [--files-only|-f]
 */
const fs = require('fs');
const path = require('path');

const EXCLUSION_DIRS = ['.git', 'node_modules'];

function replaceFileContent(filePath, oldString, newString) {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        if (content.includes(oldString)) {
            const newContent = content.replaceAll(oldString, newString);
            fs.writeFileSync(filePath, newContent, 'utf8');
            return true;
        }
    } catch (error) {}
    return false;
}

function isIgnored(filePath) {
    const segments = filePath.split(path.sep);
    return segments.some(segment => EXCLUSION_DIRS.includes(segment));
}

function deepShift(oldString, newString, options = {}) {
    let { contentOnly = false, filesOnly = false, rootDir = process.cwd(), cliMode = false } = options;

    if (oldString === newString) {
        if (cliMode) console.log("⚠️ Old and new strings are identical - no changes needed.");
        return;
    }

    let processedFileCount = 0;
    let processedDirCount = 0;

    if (cliMode) {
        console.log(`🚀 deepShift starting: "${oldString}" -> "${newString}"`);
        console.log(` Mode: ${contentOnly ? 'Content Only' : filesOnly ? 'Files Only' : 'Full'}`);
    }

    const renamedPaths = new Map();

    // --- Phase 1: Structural Renaming (MUST COME FIRST) ---
    if (!contentOnly) {
        const entities = [];
        function collectEntities(currentPath) {
            try {
                const entries = fs.readdirSync(currentPath, { withFileTypes: true });
                for (const entry of entries) {
                    const fullPath = path.join(currentPath, entry.name);
                    if (isIgnored(fullPath)) continue;
                    if (entry.isDirectory()) {
                        collectEntities(fullPath);
                        entities.push({ path: fullPath, isDir: true });
                    } else if (entry.isFile()) {
                        entities.push({ path: fullPath, isDir: false });
                    }
                }
            } catch (e) {}
        }
        collectEntities(rootDir);

        // Sort deepest first to avoid path invalidation
        entities.sort((a, b) => b.path.length - a.path.length);

        for (const entity of entities) {
            let currentPath = entity.path;
            const baseName = path.basename(currentPath);
            const parentDir = path.dirname(currentPath);

            if (renamedPaths.has(currentPath)) continue;

            // Path Segment Mode
            if (oldString.includes(path.sep)) {
                if (currentPath.includes(oldString)) {
                    const segmentCheck = (currentPath === oldString) ||
                                         currentPath.endsWith(path.sep + oldString) ||
                                         (entity.isDir && currentPath.endsWith(oldString));

                    if (segmentCheck) {
                        const newPath = currentPath.replaceAll(oldString, newString);
                        if (newPath !== currentPath) {
                            try {
                                fs.renameSync(currentPath, newPath);
                                renamedPaths.set(currentPath, newPath);
                                if (cliMode) console.log(`\n📂 Moved: ${currentPath.replace(rootDir + path.sep, '')} → ${newPath.replace(rootDir + path.sep, '')}`);
                                entity.isDir ? processedDirCount++ : processedFileCount++;
                            } catch (e) {
                                if (cliMode) console.log(`Error moving ${currentPath}: ${e.message}`);
                            }
                        }
                    }
                }
            }
            // Basename Mode
            else if (baseName.includes(oldString)) {
                let newBaseName;
                if (!entity.isDir) {
                    const ext = path.extname(baseName);
                    const nameWithoutExt = baseName.slice(0, -ext.length || undefined);
                    const newNameWithoutExt = nameWithoutExt.replaceAll(oldString, newString);
                    newBaseName = ext ? `${newNameWithoutExt}${ext}` : newNameWithoutExt;
                } else {
                    newBaseName = baseName.replaceAll(oldString, newString);
                }

                if (newBaseName !== baseName) {
                    const newPath = path.join(parentDir, newBaseName);
                    try {
                        fs.renameSync(currentPath, newPath);
                        renamedPaths.set(currentPath, newPath);
                        if (cliMode) console.log(`\n📄 Renamed: ${baseName} → ${newBaseName}`);
                        entity.isDir ? processedDirCount++ : processedFileCount++;
                    } catch (e) {
                        if (cliMode) console.log(`Error renaming ${currentPath}: ${e.message}`);
                    }
                }
            }
        }
    }

    // --- Phase 2: Content Replacement (AFTER renaming) ---
    if (!filesOnly) {
        const filesToProcess = [];
        function findFiles(currentPath) {
            try {
                const entries = fs.readdirSync(currentPath, { withFileTypes: true });
                for (const entry of entries) {
                    const fullPath = path.join(currentPath, entry.name);
                    if (isIgnored(fullPath)) continue;
                    if (entry.isDirectory()) {
                        findFiles(fullPath);
                    } else if (entry.isFile()) {
                        try {
                            const content = fs.readFileSync(fullPath, 'utf8');
                            if (content.includes(oldString)) {
                                filesToProcess.push(fullPath);
                            }
                        } catch (e) {}
                    }
                }
            } catch (e) {}
        }
        findFiles(rootDir);

        if (cliMode) console.log(`\n🔍 Found ${filesToProcess.length} files with matching content...`);

        filesToProcess.forEach(filePath => {
            if (replaceFileContent(filePath, oldString, newString)) {
                processedFileCount++;
            }
        });
    }

    if (cliMode) {
        console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
        console.log(`✅ deepShift Complete!`);
        console.log(` Content Replacements: ${filesOnly ? 'Skipped' : processedFileCount}`);
        console.log(` Structural Renames: ${contentOnly ? 'Skipped' : processedFileCount + processedDirCount}`);
        console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    }
}

function parseArgs() {
    const args = process.argv.slice(2);
    const options = {
        contentOnly: args.includes('--content-only') || args.includes('-c'),
        filesOnly: args.includes('--files-only') || args.includes('-f'),
        cliMode: true,
        rootDir: process.cwd()
    };

    const positionalArgs = args.filter(arg => !arg.startsWith('-'));

    if (positionalArgs.length < 2) {
        throw new Error("Missing required arguments. Usage: node deepShift.js <old_string|path> <new_string>");
    }

    let oldString = positionalArgs[0];
    let newString = positionalArgs[1];

    if (fs.existsSync(oldString) && !newString.includes(path.sep)) {
        const basename = path.basename(oldString);
        oldString = fs.statSync(oldString).isFile()
            ? basename.replace(path.extname(basename), '')
            : basename;
    }

    return { oldString, newString, options };
}

// CLI entry point only
if (require.main === module && !process.argv.includes('--test')) {
    try {
        const { oldString, newString, options } = parseArgs();
        deepShift(oldString, newString, options);
    } catch (e) {
        console.error(`\nFatal Error: ${e.message}`);
        console.error("Example: node deepShift.js oldName newName");
        process.exit(1);
    }
}

module.exports = { deepShift };
