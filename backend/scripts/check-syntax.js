const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const rootDir = path.resolve(__dirname, '..');
const ignoredDirs = new Set(['node_modules', '.git']);
const targets = [];

function collectJsFiles(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
        if (ignoredDirs.has(entry.name)) continue;

        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            collectJsFiles(fullPath);
            continue;
        }

        if (entry.isFile() && entry.name.endsWith('.js')) {
            targets.push(fullPath);
        }
    }
}

collectJsFiles(rootDir);

let hasFailure = false;
for (const filePath of targets) {
    const result = spawnSync(process.execPath, ['--check', filePath], {
        stdio: 'inherit'
    });

    if (result.status !== 0) {
        hasFailure = true;
    }
}

if (hasFailure) {
    process.exit(1);
}

console.log(`Syntax check passed for ${targets.length} JavaScript files.`);
