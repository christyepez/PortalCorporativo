import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const component = readFileSync(new URL('../src/app/app.component.ts', import.meta.url), 'utf8');
const template = readFileSync(new URL('../src/app/app.component.html', import.meta.url), 'utf8');
const apiService = readFileSync(new URL('../src/app/portal-api.service.ts', import.meta.url), 'utf8');
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
  assert.match(template, /<button[\s\S]*type="button"/);
  assert.match(template, /\(click\)="selectModule\(module\)"/);
  assert.match(template, /aria-live="polite"/);
});

test('shell supports functional module selection and same-origin availability probes', () => {
  assert.match(component, /selectedModule:\s*ShellModule\s*=\s*this\.modules\[0\]/);
  assert.match(component, /async selectModule\(module:\s*ShellModule\)/);
  assert.match(component, /async refreshModuleHealth\(\)/);
  assert.match(component, /Promise\.all\(this\.modules\.filter/);
  assert.match(component, /fetch\(module\.probePath/);
  assert.match(component, /credentials:\s*'same-origin'/);
  assert.match(component, /response\.status === 401 \|\| response\.status === 403/);
  assert.match(template, /Actualizar estado/);
  assert.match(template, /probeCount\('available'\)/);
  assert.match(template, /data-state/);
  assert.doesNotMatch(component, /Authorization\s*:/);
});

test('security administration uses an ephemeral in-memory session and live list endpoints', () => {
  for (const route of ['/security/users', '/security/roles', '/security/permissions', '/security/resources']) {
    assert.match(apiService, new RegExp(route.replaceAll('/', '\\/')));
  }
  assert.match(component, /connectLocalSession\(\)/);
  assert.match(component, /loadSecurityData\(\)/);
  assert.match(component, /selectSecurityTab\(tab:\s*SecurityTab\)/);
  assert.match(component, /portalApi\.setAccessToken\(token\)/);
  for (const tab of ['users', 'roles', 'permissions', 'resources']) {
    assert.match(template, new RegExp(`selectSecurityTab\\('${tab}'\\)`));
  }
  assert.match(template, /JWT local efímero/);
  assert.match(template, /El token permanece sólo en memoria/);
  assert.doesNotMatch(apiService, /localStorage|sessionStorage/);
});

test('administrative shell exposes the central management sections', () => {
  for (const section of ['applications', 'security', 'menus', 'configuration', 'catalogs', 'audit', 'operations']) {
    assert.match(component, new RegExp(`id:\\s*'${section}'`));
    assert.match(template, new RegExp(`activeSection === '${section}'`));
  }
  assert.match(template, /Tenant:\s*{{ currentTenant }}/);
  assert.match(template, /Administración central/);
});

test('applications open inside the Portal workspace instead of a new browser tab', () => {
  assert.match(component, /workspaceApplication\?:\s*ApplicationCard/);
  assert.match(component, /workspaceUrl\?:\s*SafeResourceUrl/);
  assert.match(component, /bypassSecurityTrustResourceUrl\(target\)/);
  assert.match(component, /activeSection\s*=\s*'applications'/);
  assert.match(template, /<iframe/);
  assert.match(template, /\[src\]="workspaceUrl"/);
  assert.match(template, /Volver a aplicaciones/);
  assert.doesNotMatch(component, /window\.open\(/);
});

test('shell source avoids direct external hosts and browser token persistence', () => {
  assert.doesNotMatch(component, /https?:\/\//);
  assert.doesNotMatch(component, /localStorage|sessionStorage/);
});
