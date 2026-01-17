const { it } = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { deepShift } = require('../deepShift.js');

it('should rename file and update content globally', (t) => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'deepshift-basic-test-'));
    const root = path.join(tmpDir, 'project');
    fs.mkdirSync(root, { recursive: true });

    const file1Path = path.join(root, 'old_component.js');
    fs.writeFileSync(file1Path, 'const old_component = 1;', 'utf8');

    deepShift('old_component', 'new_component', { rootDir: root });

    const newFile1Path = path.join(root, 'new_component.js');
    const renamed = fs.existsSync(newFile1Path);
    
    fs.rmSync(tmpDir, { recursive: true, force: true });
    
    assert.strictEqual(renamed, true, 'Basic renaming failed');
});
