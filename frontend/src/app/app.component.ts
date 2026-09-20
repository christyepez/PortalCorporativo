import { Component } from '@angular/core';
import { environment } from '../environments/environment';

interface ShellModule {
  readonly label: string;
  readonly status: string;
  readonly enabled: boolean;
  readonly gatewayPath: string;
  readonly probePath: string;
}

type ModuleProbeState = 'idle' | 'checking' | 'available' | 'protected' | 'unavailable';

@Component({
  selector: 'portal-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  protected readonly title = 'Portal Corporativo';
  protected readonly readiness = environment.shellReadiness;
  protected readonly apiBasePath = environment.apiBasePath;
  protected readonly modules: ShellModule[] = [
    { label: 'Security', status: 'Portal Core', enabled: true, gatewayPath: '/api/security', probePath: '/api/security/users/00000000-0000-0000-0000-000000000000' },
    { label: 'Configuration', status: 'Portal Core', enabled: true, gatewayPath: '/api/configuration', probePath: '/api/configuration/scopes/0' },
    { label: 'Menu', status: 'Portal Core', enabled: true, gatewayPath: '/api/menu', probePath: '/api/menu/modules/portal' },
    { label: 'Audit', status: 'Portal Core', enabled: true, gatewayPath: '/api/audit', probePath: '/api/audit/events/?page=1&pageSize=1' },
    { label: 'Notification', status: 'Portal Core', enabled: true, gatewayPath: '/api/notifications', probePath: '/api/notifications/templates' },
    { label: 'Catalog', status: 'Portal Core', enabled: true, gatewayPath: '/api/catalog', probePath: '/api/catalog/entries' },
    { label: 'Content / File', status: 'Portal Core', enabled: true, gatewayPath: '/api/content', probePath: '/api/content/documents' },
    { label: 'Reporting', status: 'Portal Core', enabled: true, gatewayPath: '/api/reporting', probePath: '/api/reporting/reports' },
    { label: 'Integration', status: 'Portal Core', enabled: true, gatewayPath: '/api/integration', probePath: '/api/integration/inbox/processed?tenantId=default&source=shell&idempotencyKey=probe' },
    { label: 'CRM', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/crm', probePath: '/api/crm/health/ready' },
    { label: 'Financiero', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/financial', probePath: '/api/financial/health/ready' },
    { label: 'HistoriasPaolin', status: 'Integrado por Gateway', enabled: true, gatewayPath: '/api/historiaspaolin', probePath: '/api/historiaspaolin/health/ready' },
    { label: 'Talento Humano', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/hr', probePath: '/api/hr/health/ready' }
  ];

  protected selectedModule: ShellModule = this.modules[0];
  protected moduleProbeState: ModuleProbeState = 'idle';
  protected moduleProbeStatus?: number;

  protected async selectModule(module: ShellModule): Promise<void> {
    if (!module.enabled) return;
    this.selectedModule = module;
    this.moduleProbeState = 'checking';
    this.moduleProbeStatus = undefined;

    try {
      const response = await fetch(module.probePath, {
        method: 'GET',
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'X-Correlation-ID': `portal-shell-${crypto.randomUUID()}` }
      });
      this.moduleProbeStatus = response.status;
      this.moduleProbeState = response.ok
        ? 'available'
        : response.status === 401 || response.status === 403
          ? 'protected'
          : 'unavailable';
    } catch {
      this.moduleProbeState = 'unavailable';
    }
  }
}
