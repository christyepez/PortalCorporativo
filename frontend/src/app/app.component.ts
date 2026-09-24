import { Component } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { environment } from '../environments/environment';

interface ShellModule {
  readonly label: string;
  readonly status: string;
  readonly enabled: boolean;
  readonly gatewayPath: string;
  readonly probePath: string;
}

type ModuleProbeState = 'idle' | 'checking' | 'available' | 'protected' | 'unavailable';

interface ModuleProbeResult {
  readonly state: ModuleProbeState;
  readonly status?: number;
  readonly checkedAt?: Date;
}
type AdminSection = 'dashboard' | 'applications' | 'security' | 'menus' | 'configuration' | 'catalogs' | 'audit' | 'operations';

interface NavigationItem {
  readonly id: AdminSection;
  readonly label: string;
  readonly description: string;
  readonly icon: string;
}

interface ApplicationCard {
  readonly name: string;
  readonly code: string;
  readonly description: string;
  readonly port?: number;
  readonly path?: string;
  readonly status: string;
}
@Component({
  selector: 'portal-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  constructor(private readonly sanitizer: DomSanitizer) {}

  protected readonly title = 'Portal Corporativo';
  protected readonly readiness = environment.shellReadiness;
  protected readonly apiBasePath = environment.apiBasePath;

  protected readonly navigation: NavigationItem[] = [
    { id: 'dashboard', label: 'Inicio', description: 'Resumen del ecosistema', icon: '⌂' },
    { id: 'applications', label: 'Aplicaciones', description: 'Contenedor y accesos', icon: '▦' },
    { id: 'security', label: 'Seguridad', description: 'Usuarios, roles y permisos', icon: '◉' },
    { id: 'menus', label: 'Menús', description: 'Navegación por aplicación', icon: '☰' },
    { id: 'configuration', label: 'Parámetros', description: 'Configuración funcional', icon: '⚙' },
    { id: 'catalogs', label: 'Catálogos', description: 'Valores parametrizables', icon: '≡' },
    { id: 'audit', label: 'Auditoría', description: 'Trazabilidad y eventos', icon: '◎' },
    { id: 'operations', label: 'Operaciones', description: 'Salud de servicios', icon: '◌' }
  ];

  protected readonly applications: ApplicationCard[] = [
    { name: 'Conjunto al Día', code: 'APP_CONDOMINIO', description: 'Administración de propiedades y condominios.', port: 4210, status: 'Local' },
    { name: 'CRM', code: 'CRM', description: 'Gestión comercial y clientes.', path: '/api/crm', status: 'Integrado' },
    { name: 'Financiero', code: 'FINANCIAL', description: 'Operación financiera y presupuestaria.', path: '/api/financial', status: 'Integrado' },
    { name: 'Talento Humano', code: 'HR', description: 'Gestión de personas y colaboradores.', path: '/api/hr', status: 'Integrado' },
    { name: 'HistoriasPaolin', code: 'HISTORIAS', description: 'Aplicación integrada mediante Gateway.', path: '/api/historiaspaolin', status: 'Integrado' }
  ];  protected readonly modules: ShellModule[] = [
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

  protected activeSection: AdminSection = 'dashboard';
  protected workspaceApplication?: ApplicationCard;
  protected workspaceUrl?: SafeResourceUrl;
  protected selectedModule: ShellModule = this.modules[0];
  protected moduleProbeState: ModuleProbeState = 'idle';
  protected moduleProbeStatus?: number;
  protected readonly moduleProbeResults = new Map<string, ModuleProbeResult>();
  protected operationsRefreshing = false;
  protected readonly currentTenant = 'default';

  protected selectSection(section: AdminSection): void {
    this.activeSection = section;
    if (section === 'operations') void this.refreshModuleHealth();
  }

  protected probeResult(module: ShellModule): ModuleProbeResult {
    return this.moduleProbeResults.get(module.label) ?? { state: 'idle' };
  }

  protected probeCount(state: ModuleProbeState): number {
    return this.modules.filter((module) => this.probeResult(module).state === state).length;
  }

  protected openApplication(application: ApplicationCard): void {
    if (!application.port) return;

    const target = `${window.location.protocol}//${window.location.hostname}:${application.port}/`;
    this.workspaceApplication = application;
    this.workspaceUrl = this.sanitizer.bypassSecurityTrustResourceUrl(target);
    this.activeSection = 'applications';
  }

  protected closeWorkspace(): void {
    this.workspaceApplication = undefined;
    this.workspaceUrl = undefined;
  }

  protected async selectModule(module: ShellModule): Promise<void> {
    if (!module.enabled) return;
    this.selectedModule = module;
    const result = await this.probeModule(module);
    this.moduleProbeState = result.state;
    this.moduleProbeStatus = result.status;
  }

  protected async refreshModuleHealth(): Promise<void> {
    if (this.operationsRefreshing) return;
    this.operationsRefreshing = true;

    try {
      await Promise.all(this.modules.filter((module) => module.enabled).map((module) => this.probeModule(module)));
      const selected = this.probeResult(this.selectedModule);
      this.moduleProbeState = selected.state;
      this.moduleProbeStatus = selected.status;
    } finally {
      this.operationsRefreshing = false;
    }
  }

  private async probeModule(module: ShellModule): Promise<ModuleProbeResult> {
    this.moduleProbeResults.set(module.label, { state: 'checking' });

    try {
      const response = await fetch(module.probePath, {
        method: 'GET',
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'X-Correlation-ID': `portal-shell-${crypto.randomUUID()}` }
      });
      const result: ModuleProbeResult = {
        state: response.ok ? 'available' : response.status === 401 || response.status === 403 ? 'protected' : 'unavailable',
        status: response.status,
        checkedAt: new Date()
      };
      this.moduleProbeResults.set(module.label, result);
      return result;
    } catch {
      const result: ModuleProbeResult = { state: 'unavailable', checkedAt: new Date() };
      this.moduleProbeResults.set(module.label, result);
      return result;
    }
  }
}