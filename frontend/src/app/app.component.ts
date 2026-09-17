import { Component } from '@angular/core';
import { environment } from '../environments/environment';

interface ShellModule {
  readonly label: string;
  readonly status: string;
  readonly enabled: boolean;
  readonly gatewayPath?: string;
}

@Component({
  selector: 'portal-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  protected readonly title = 'Portal Corporativo';
  protected readonly readiness = 'LocalProductionIntegratedShell';
  protected readonly apiBasePath = environment.apiBasePath;
  protected readonly modules: ShellModule[] = [
    { label: 'Security', status: 'Portal Core', enabled: true, gatewayPath: '/api/security' },
    { label: 'Configuration', status: 'Portal Core', enabled: true, gatewayPath: '/api/configuration' },
    { label: 'Menu', status: 'Portal Core', enabled: true, gatewayPath: '/api/menu' },
    { label: 'Audit', status: 'Portal Core', enabled: true, gatewayPath: '/api/audit' },
    { label: 'Notification', status: 'Portal Core', enabled: true, gatewayPath: '/api/notifications' },
    { label: 'Catalog', status: 'Portal Core', enabled: true, gatewayPath: '/api/catalog' },
    { label: 'Content / File', status: 'Portal Core', enabled: true, gatewayPath: '/api/content' },
    { label: 'Reporting', status: 'Portal Core', enabled: true, gatewayPath: '/api/reporting' },
    { label: 'Integration', status: 'Portal Core', enabled: true, gatewayPath: '/api/integration' },
    { label: 'CRM', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/crm' },
    { label: 'Financiero', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/financial' },
    { label: 'HistoriasPaolin', status: 'Integrado por Gateway', enabled: true, gatewayPath: '/api/historiaspaolin' },
    { label: 'Talento Humano', status: 'Integrado PROD local', enabled: true, gatewayPath: '/api/hr' }
  ];
}
