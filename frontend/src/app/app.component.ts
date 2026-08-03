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
  protected readonly readiness = environment.shellReadiness;
  protected readonly apiBasePath = environment.apiBasePath;
  protected readonly modules: ShellModule[] = [
    { label: 'Security', status: 'Foundation disponible', enabled: true },
    { label: 'Configuration', status: 'Foundation disponible', enabled: true },
    { label: 'Menu', status: 'Foundation disponible', enabled: true },
    { label: 'Audit', status: 'Foundation disponible', enabled: true },
    { label: 'Notification', status: 'Foundation disponible', enabled: true },
    { label: 'External modules', status: 'Deshabilitado en baseline', enabled: false }
  ];
}
