/**
 * deepShift.test.js
 * Test suite for deepShift.js using Node.js built-in test runner.
 *
 * Run with:
 * node --test deepShift.test.js
 */
const { describe, it } = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { deepShift } = require('./deepShift.js');

function setupTempDir(context) {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), `deepshift-test-${context.name.replace(/\s/g, '_')}-`));
    return tmpDir;
}

describe('deepShift Core Functionality', () => {
    it('should rename file and update content globally', (t) => {
        const tempDir = setupTempDir(t);
        const root = path.join(tempDir, 'project');
        fs.mkdirSync(root, { recursive: true });

        const file1Path = path.join(root, 'old_component.js');
        const file2Path = path.join(root, 'old_component_utils.js');

        fs.writeFileSync(file1Path, 'const old_component = 1; import old_component from "./old_component_utils";', 'utf8');
        fs.writeFileSync(file2Path, 'export function old_component() {}', 'utf8');

        deepShift('old_component', 'new_component', { rootDir: root });

        const newFile1Path = path.join(root, 'new_component.js');
        const newFile2Path = path.join(root, 'new_component_utils.js');

        assert.strictEqual(fs.existsSync(newFile1Path), true, 'Main file should be renamed to new_component.js');
        assert.strictEqual(fs.existsSync(newFile2Path), true, 'Utility file should be renamed to new_component_utils.js');

        const renamedContent = fs.readFileSync(newFile1Path, 'utf8');
        const utilsContent = fs.readFileSync(newFile2Path, 'utf8');

        assert.ok(renamedContent.includes('new_component = 1'), 'Content in main file should be updated');
        assert.ok(utilsContent.includes('export function new_component() {}'), 'Content in utils file should be updated');

        fs.rmSync(tempDir, { recursive: true, force: true });
    });

    it('should rename nested directories correctly (Path Segment Mode)', (t) => {
        const tempDir = setupTempDir(t);
        const root = path.join(tempDir, 'project');
        fs.mkdirSync(path.join(root, 'src', 'old_feature'), { recursive: true });

        fs.writeFileSync(path.join(root, 'src', 'old_feature', 'index.js'), "import {x} from '../src/old_feature/util'", 'utf8');
        fs.writeFileSync(path.join(root, 'App.js'), "import {x} from './src/old_feature/util'", 'utf8');

        deepShift(path.join('src', 'old_feature'), path.join('src', 'new_module'), { rootDir: root });

        const newDir = path.join(root, 'src', 'new_module');
        assert.strictEqual(fs.existsSync(newDir), true, 'Directory should be renamed to new_module');
        assert.strictEqual(fs.existsSync(path.join(root, 'src', 'old_feature')), false, 'Old directory should no longer exist');

        const fileContent = fs.readFileSync(path.join(newDir, 'index.js'), 'utf8');
        const appContent = fs.readFileSync(path.join(root, 'App.js'), 'utf8');

        assert.ok(fileContent.includes("'../src/new_module/util'"), 'Internal import path should be updated');
        assert.ok(appContent.includes("'./src/new_module/util'"), 'External import path should be updated');

        fs.rmSync(tempDir, { recursive: true, force: true });
    });

    it('should correctly handle the Drag & Drop (File Path) logic', (t) => {
        const tempDir = setupTempDir(t);
        const root = path.join(tempDir, 'project');
        fs.mkdirSync(root, { recursive: true });

        fs.writeFileSync(path.join(root, 'MyComponent.tsx'), 'class MyComponent {}', 'utf8');
        fs.writeFileSync(path.join(root, 'App.tsx'), 'import MyComponent from "./MyComponent";', 'utf8');

        deepShift('MyComponent', 'NewComponent', { rootDir: root });

        assert.strictEqual(fs.existsSync(path.join(root, 'NewComponent.tsx')), true, 'File should be renamed');
        assert.strictEqual(fs.existsSync(path.join(root, 'MyComponent.tsx')), false, 'Old file should be gone');

        const appContent = fs.readFileSync(path.join(root, 'App.tsx'), 'utf8');
        assert.ok(appContent.includes('import NewComponent from "./NewComponent";'), 'Import should be updated');

        fs.rmSync(tempDir, { recursive: true, force: true });
    });

    it('should ignore excluded directories', (t) => {
        const tempDir = setupTempDir(t);
        const root = path.join(tempDir, 'project');
        fs.mkdirSync(root, { recursive: true });
        fs.mkdirSync(path.join(root, 'src'), { recursive: true });
        fs.mkdirSync(path.join(root, 'node_modules'), { recursive: true });

        fs.writeFileSync(path.join(root, 'src', 'file.js'), 'const old_value = 1;', 'utf8');
        fs.writeFileSync(path.join(root, 'node_modules', 'pkg.js'), 'const old_value = 1;', 'utf8');

        deepShift('old_value', 'new_value', { rootDir: root });

        const srcContent = fs.readFileSync(path.join(root, 'src', 'file.js'), 'utf8');
        const nmContent = fs.readFileSync(path.join(root, 'node_modules', 'pkg.js'), 'utf8');

        assert.ok(srcContent.includes('new_value'), 'Tracked file should be updated');
        assert.ok(nmContent.includes('old_value'), 'Ignored node_modules file should remain unchanged');

        fs.rmSync(tempDir, { recursive: true, force: true });
    });
});
