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

test('security administration uses an ephemeral session and supports managed assignments', () => {
  for (const route of ['/security/users', '/security/roles', '/security/permissions', '/security/resources']) {
    assert.match(apiService, new RegExp(route.replaceAll('/', '\\/')));
  }
  assert.match(apiService, /post<ApiResponse<SecurityUser>>\(`\$\{environment\.apiBasePath\}\/security\/users`/);
  assert.match(apiService, /post<ApiResponse<SecurityRole>>\(`\$\{environment\.apiBasePath\}\/security\/roles`/);
  assert.match(apiService, /post<ApiResponse<SecurityResource>>\(`\$\{environment\.apiBasePath\}\/security\/resources`/);
  assert.match(apiService, /post<ApiResponse<SecurityPermission>>\(`\$\{environment\.apiBasePath\}\/security\/permissions`/);
  assert.match(apiService, /\/security\/users\/\$\{encodeURIComponent\(userId\)\}\/roles/);
  assert.match(apiService, /\/security\/roles\/\$\{encodeURIComponent\(roleId\)\}\/permissions/);
  assert.match(apiService, /\/security\/check-permission/);
  assert.match(component, /async createSecurityUser\(\)/);
  assert.match(component, /async assignSecurityRoleToUser\(\)/);
  assert.match(component, /async assignSecurityPermissionToRole\(\)/);
  assert.match(component, /async loadSecurityUserPermissions\(\)/);
  assert.match(component, /async checkSecurityPermission\(\)/);
  assert.match(component, /portalApi\.setAccessToken\(token\)/);
  for (const tab of ['users', 'roles', 'permissions', 'resources']) {
    assert.match(template, new RegExp(`selectSecurityTab\\('${tab}'\\)`));
  }
  assert.match(template, /Crear usuario/);
  assert.match(template, /Asignar rol/);
  assert.match(template, /Asignar permiso/);
  assert.match(template, /Evaluar permiso/);
  assert.match(template, /JWT local efímero/);
  assert.match(template, /El token permanece sólo en memoria/);
  assert.doesNotMatch(apiService, /localStorage|sessionStorage/);
});

test('menu administration supports managed definitions items reorder and activation', () => {
  assert.match(apiService, /\/menu\/modules\/\$\{encodeURIComponent\(moduleCode\)\}/);
  assert.match(apiService, /post<ApiResponse<string>>\(`\$\{environment\.apiBasePath\}\/menu\//);
  assert.match(apiService, /post<ApiResponse<MenuItem>>\(`\$\{environment\.apiBasePath\}\/menu\/items`/);
  assert.match(apiService, /put<ApiResponse<MenuItem>>\(`\$\{environment\.apiBasePath\}\/menu\/items\/\$\{encodeURIComponent\(id\)\}`/);
  assert.match(apiService, /\/menu\/items\/\$\{encodeURIComponent\(id\)\}\/\$\{action\}/);
  assert.match(apiService, /\/menu\/reorder/);
  assert.match(component, /async createMenuDefinition\(\)/);
  assert.match(component, /async saveMenuItem\(\)/);
  assert.match(component, /async toggleMenuItem\(item:\s*MenuItem\)/);
  assert.match(component, /JSON\.parse\(metadataJson\)/);
  assert.match(template, /menu\.manage/);
  assert.match(template, /Crear definición/);
  assert.match(template, /Crear elemento/);
  assert.match(template, /Guardar cambios/);
  assert.match(template, /Desactivar/);
  assert.match(template, /@for \(item of menuItems; track item\.id\)/);
  assert.doesNotMatch(template, /<strong>Inicio<\/strong>/);
});

test('configuration administration supports versioned CRUD with backend authorization', () => {
  assert.match(apiService, /post<ApiResponse<ConfigurationItem>>\(`\$\{environment\.apiBasePath\}\/configuration\/items`/);
  assert.match(apiService, /put<ApiResponse<ConfigurationItem>>\(`\$\{environment\.apiBasePath\}\/configuration\/items\/\$\{encodeURIComponent\(id\)\}`/);
  assert.match(apiService, /\/configuration\/items\/\$\{encodeURIComponent\(id\)\}\/\$\{action\}/);
  assert.match(component, /async loadConfigurationData\(\)/);
  assert.match(component, /async saveConfigurationItem\(\)/);
  assert.match(component, /async toggleConfigurationItem\(item:\s*ConfigurationItem\)/);
  assert.match(component, /beginEditConfigurationItem\(item:\s*ConfigurationItem\)/);
  assert.match(component, /JSON\.parse\(valueJson\)/);
  assert.match(template, /configuration\.manage/);
  assert.match(template, /Nuevo parámetro/);
  assert.match(template, /Guardar cambios/);
  assert.match(template, /Desactivar/);
  assert.match(template, /@for \(item of configurationItems; track item\.id\)/);
});

test('catalog administration supports managed CRUD with backend authorization', () => {
  assert.match(apiService, /post<CatalogEntry>\(`\$\{environment\.apiBasePath\}\/catalog\/entries`/);
  assert.match(apiService, /put<CatalogEntry>\(`\$\{environment\.apiBasePath\}\/catalog\/entries\/\$\{encodeURIComponent\(id\)\}`/);
  assert.match(component, /async loadCatalogData\(\)/);
  assert.match(component, /async saveCatalogEntry\(\)/);
  assert.match(component, /async toggleCatalogEntry\(entry:\s*CatalogEntry\)/);
  assert.match(component, /beginEditCatalogEntry\(entry:\s*CatalogEntry\)/);
  assert.match(template, /catalog\.manage/);
  assert.match(template, /Nuevo valor/);
  assert.match(template, /Guardar cambios/);
  assert.match(template, /Desactivar/);
  assert.match(template, /@for \(entry of catalogEntries; track entry\.id\)/);
});

test('content administration supports upload metadata lifecycle and protected download', () => {
  assert.match(apiService, /post<ContentDocument>\(`\$\{environment\.apiBasePath\}\/content\/documents`/);
  assert.match(apiService, /put<ContentDocument>\(`\$\{environment\.apiBasePath\}\/content\/documents\/\$\{encodeURIComponent\(id\)\}\/metadata`/);
  assert.match(apiService, /\/content\/documents\/\$\{encodeURIComponent\(id\)\}\/\$\{action\}/);
  assert.match(apiService, /\/content\/documents\/\$\{encodeURIComponent\(id\)\}\/download/);
  assert.match(component, /async saveContentDocument\(\)/);
  assert.match(component, /async toggleContentDocument\(document:\s*ContentDocument\)/);
  assert.match(component, /selectContentFile\(event:\s*Event\)/);
  assert.match(component, /file\.size > 10 \* 1024 \* 1024/);
  assert.match(component, /btoa\(binary\)/);
  assert.match(template, /content\.manage/);
  assert.match(template, /Nuevo documento/);
  assert.match(template, /Guardar metadatos/);
  assert.match(template, /SHA-256/);
  assert.match(template, /@for \(document of contentDocuments; track document\.id\)/);
});

test('audit administration loads paged events and 24h summary through Audit API', () => {
  assert.match(apiService, /\/audit\/events\/\?\$\{params\.toString\(\)\}/);
  assert.match(apiService, /\/audit\/events\/summary\?hours=/);
  assert.match(component, /async loadAuditData\(page = 1\)/);
  assert.match(component, /auditSeverityLabel\(severity:\s*number\)/);
  assert.match(component, /auditLastPage\(\)/);
  assert.match(template, /@for \(event of auditEvents; track event\.id\)/);
  assert.match(template, /Eventos · últimas 24h/);
  assert.match(template, /Página {{ auditPage }} de {{ auditLastPage\(\) }}/);
  assert.doesNotMatch(template, />Exportar<\/button>/);
});

test('reporting administration loads definitions and executes reports through Reporting API', () => {
  assert.match(apiService, /\/reporting\/reports`/);
  assert.match(apiService, /\/reporting\/reports\/\$\{encodeURIComponent\(key\)\}\/execute/);
  assert.match(component, /async loadReportingData\(\)/);
  assert.match(component, /async executeSelectedReport\(\)/);
  assert.match(component, /reportColumns\(\)/);
  assert.match(template, /@for \(report of reportDefinitions; track report\.key\)/);
  assert.match(template, /Ejecutar reporte/);
  assert.match(template, /reportExecution\.rows/);
});

test('notification administration supports template lifecycle, controlled send, schedule and message actions', () => {
  assert.match(apiService, /post<ApiResponse<NotificationTemplate>>\(`\$\{environment\.apiBasePath\}\/notifications\/templates`/);
  assert.match(apiService, /put<ApiResponse<NotificationTemplate>>\(`\$\{environment\.apiBasePath\}\/notifications\/templates\/\$\{encodeURIComponent\(id\)\}`/);
  assert.match(apiService, /\/notifications\/templates\/\$\{encodeURIComponent\(id\)\}\/\$\{action\}/);
  assert.match(apiService, /\/notifications\/send/);
  assert.match(apiService, /\/notifications\/schedule/);
  assert.match(apiService, /\/notifications\/\$\{encodeURIComponent\(id\)\}\/retry/);
  assert.match(apiService, /\/notifications\/\$\{encodeURIComponent\(id\)\}\/cancel/);
  assert.match(component, /async saveNotificationTemplate\(\)/);
  assert.match(component, /async toggleNotificationTemplate\(template:\s*NotificationTemplate\)/);
  assert.match(component, /async submitNotification\(schedule:\s*boolean\)/);
  assert.match(component, /notificationStatusLabel\(status:\s*number\)/);
  assert.match(template, /notification\.manage/);
  assert.match(template, /notification\.send/);
  assert.match(template, /Nueva plantilla/);
  assert.match(template, /Enviar ahora/);
  assert.match(template, /Programar/);
  assert.match(template, /Reintentar/);
  assert.match(template, /Cancelar/);
});

test('integration administration queries outbox and inbox status without enqueue actions', () => {
  assert.match(apiService, /\/integration\/outbox\/\$\{encodeURIComponent\(messageId\)\}/);
  assert.match(apiService, /\/integration\/outbox\/status\?\$\{params\.toString\(\)\}/);
  assert.match(apiService, /\/integration\/inbox\/processed\?\$\{params\.toString\(\)\}/);
  assert.match(component, /async lookupOutboxByMessageId\(\)/);
  assert.match(component, /async lookupOutboxByIdempotencyKey\(\)/);
  assert.match(component, /async lookupInboxProcessed\(\)/);
  assert.match(template, /Consultar Outbox por clave/);
  assert.match(template, /Verificar procesamiento/);
  assert.doesNotMatch(template, /Encolar evento/);
});

test('administrative shell exposes the central management sections', () => {
  for (const section of ['applications', 'security', 'menus', 'configuration', 'catalogs', 'content', 'audit', 'reporting', 'notifications', 'integration', 'operations']) {
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
