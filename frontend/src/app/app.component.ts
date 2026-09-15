import { Component } from '@angular/core';
import { environment } from '../environments/environment';

interface ShellModule {
  readonly label: string;
  readonly status: string;
  readonly enabled: boolean;
}

@Component({
  selector: 'portal-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  protected readonly title = 'Portal Corporativo';
  protected readonly readiness = 'IntegratedNonProductionShell';
  protected readonly apiBasePath = environment.apiBasePath;
  protected readonly modules: ShellModule[] = [
    { label: 'Security', status: 'Integrado vía Gateway', enabled: true },
    { label: 'Configuration', status: 'Integrado vía Gateway', enabled: true },
    { label: 'Menu', status: 'Integrado vía Gateway', enabled: true },
    { label: 'Audit', status: 'Foundation disponible', enabled: true },
    { label: 'Notification', status: 'Foundation disponible', enabled: true },
    { label: 'Catalog', status: 'Foundation funcional', enabled: true },
    { label: 'Content / File', status: 'Foundation funcional', enabled: true },
    { label: 'Reporting', status: 'Foundation funcional', enabled: true },
    { label: 'Integration', status: 'Outbox / Inbox controlado', enabled: true },
    { label: 'External modules', status: 'Gate independiente', enabled: false }
  ];
}
