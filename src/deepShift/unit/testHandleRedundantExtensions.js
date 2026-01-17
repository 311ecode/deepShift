const { it } = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { deepShift } = require('../deepShift.js');

it('should handle redundant extensions (e.g. common.sh.sh -> common.sh)', (t) => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'deepshift-ext-test-'));
    const root = path.join(tmpDir, 'project');
    fs.mkdirSync(root, { recursive: true });

    const redundantFile = 'common.sh.sh';
    const targetFile = 'common.sh';
    fs.writeFileSync(path.join(root, redundantFile), 'echo "fix"', 'utf8');

    // Mimic the Entity Mode trigger
    deepShift('common.sh', 'common.sh', { 
        rootDir: root, 
        literalOld: redundantFile 
    });

    const exists = fs.existsSync(path.join(root, targetFile));
    const oldExists = fs.existsSync(path.join(root, redundantFile));

    // Cleanup
    fs.rmSync(tmpDir, { recursive: true, force: true });

    assert.strictEqual(exists, true, 'File should be renamed to common.sh');
    assert.strictEqual(oldExists, false, 'Old redundant file should be gone');
});
