import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const component = readFileSync(new URL('../src/app/app.component.ts', import.meta.url), 'utf8');
const template = readFileSync(new URL('../src/app/app.component.html', import.meta.url), 'utf8');
const angular = JSON.parse(readFileSync(new URL('../angular.json', import.meta.url), 'utf8'));

test('integrated domain routes are enabled in the shell contract', () => {
  const required = ['/api/crm', '/api/financial', '/api/historiaspaolin', '/api/hr'];
  for (const route of required) {
    assert.match(component, new RegExp(`enabled:\\s*true,\\s*gatewayPath:\\s*'${route.replaceAll('/', '\\/')}'`));
  }
});

test('shell declares the local production integrated readiness state', () => {
  assert.match(component, /LocalProductionIntegratedShell/);
  assert.match(template, /Portal único con módulos integrados detrás del Gateway/);
});

test('production build keeps output hashing enabled', () => {
  const production = angular.projects['portal-corporativo-shell'].architect.build.configurations.production;
  assert.equal(production.outputHashing, 'all');
});

test('shell source does not persist access tokens in browser storage', () => {
  assert.doesNotMatch(component, /localStorage|sessionStorage/);
});
