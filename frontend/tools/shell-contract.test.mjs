import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const component = readFileSync(new URL('../src/app/app.component.ts', import.meta.url), 'utf8');
const template = readFileSync(new URL('../src/app/app.component.html', import.meta.url), 'utf8');
const environment = readFileSync(new URL('../src/environments/environment.ts', import.meta.url), 'utf8');
const angular = JSON.parse(readFileSync(new URL('../angular.json', import.meta.url), 'utf8'));

test('integrated domain routes are enabled in the shell contract', () => {
  const required = ['/api/crm', '/api/financial', '/api/historiaspaolin', '/api/hr'];
  for (const route of required) {
    assert.match(component, new RegExp(`enabled:\\s*true,\\s*gatewayPath:\\s*'${route.replaceAll('/', '\\/')}'`));
  }
});

test('gateway routes are unique and use the Portal API boundary', () => {
  const routes = [...component.matchAll(/gatewayPath:\s*'([^']+)'/g)].map((match) => match[1]);
  assert.equal(routes.length, 13);
  assert.equal(new Set(routes).size, routes.length);
  for (const route of routes) assert.match(route, /^\/api\//);
});

test('readiness and API base come from the environment contract', () => {
  assert.match(component, /readiness = environment\.shellReadiness/);
  assert.match(component, /apiBasePath = environment\.apiBasePath/);
  assert.match(environment, /shellReadiness:\s*'LocalProductionIntegratedShell'/);
  assert.match(environment, /apiBasePath:\s*'\/api'/);
});
test('environment is explicitly local-production oriented', () => {
  assert.match(environment, /production:\s*true/);
  assert.doesNotMatch(environment, /BuildableNonProductionShell/);
});

test('shell declares the integrated Gateway experience', () => {
  assert.match(template, /Portal único con módulos integrados detrás del Gateway/);
  assert.match(template, /CRM, Financiero, Talento Humano e HistoriasPaolin/);
});

test('production build keeps output hashing enabled', () => {
  const production = angular.projects['portal-corporativo-shell'].architect.build.configurations.production;
  assert.equal(production.outputHashing, 'all');
});

test('template keeps basic navigation and content accessibility invariants', () => {
  assert.match(template, /<aside[^>]+aria-label="Portal shell modules"/);
  assert.match(template, /<section[^>]+aria-label="Portal shell content"/);
  assert.match(template, /<button type="button"/);
});

test('shell source avoids direct hosts and browser token persistence', () => {
  assert.doesNotMatch(component, /https?:\/\//);
  assert.doesNotMatch(component, /localStorage|sessionStorage/);
});
