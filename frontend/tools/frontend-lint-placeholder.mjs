import { readFileSync } from 'node:fs';

const source = readFileSync(new URL('../src/app/app.component.ts', import.meta.url), 'utf8');

if (!source.includes('standalone: true')) {
  console.error('Frontend shell component must remain standalone for this baseline.');
  process.exit(1);
}

console.log('Frontend shell baseline lint placeholder OK.');
