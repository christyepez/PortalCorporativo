import { existsSync } from 'node:fs';

const requiredFiles = [
  'src/main.ts',
  'src/app/app.component.ts',
  'src/app/app.component.html',
  'src/app/app.component.css',
  'src/environments/environment.ts'
];

const missing = requiredFiles.filter((file) => !existsSync(new URL(`../${file}`, import.meta.url)));

if (missing.length > 0) {
  console.error(`Frontend shell baseline missing files: ${missing.join(', ')}`);
  process.exit(1);
}

console.log('Frontend shell baseline structural test OK.');
