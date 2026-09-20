import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const root = new URL('../src/', import.meta.url);
const rootPath = root.pathname.replace(/^\/(.:)/, '$1');
const issues = [];

function visit(dir) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) { visit(full); continue; }
    if (!/\.(ts|html)$/.test(name)) continue;
    const source = readFileSync(full, 'utf8');
    const rel = relative(rootPath, full);
    if (/localStorage|sessionStorage/.test(source)) issues.push(`${rel}: browser token/session persistence is forbidden`);
    if (/TODO|FIXME/.test(source)) issues.push(`${rel}: unresolved TODO/FIXME`);
  }
}

visit(rootPath);

const app = readFileSync(new URL('../src/app/app.component.ts', import.meta.url), 'utf8');
if (!/standalone:\s*true/.test(app)) issues.push('app.component.ts: root component must remain standalone');

if (issues.length) {
  for (const issue of issues) console.error(`LINT ${issue}`);
  process.exit(1);
}

console.log('Frontend policy lint OK.');
