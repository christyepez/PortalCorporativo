import { Component, OnInit } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { firstValueFrom } from 'rxjs';
import { environment } from '../environments/environment';
import consumerRegistry from '../../config/consumer-registry.json';
import { AuditEvent, AuditSummary, CatalogEntry, ConfigurationItem, ContentDocument, CreateCatalogEntry, CreateConfigurationItem, CreateContentDocument, CreateHrEmployee, CreateMenuItem, CreateNotificationTemplate, InboxProcessedStatus, LocalAdminSession, MenuItem, NotificationMessage, NotificationRequest, NotificationTemplate, OutboxMessageStatus, OutboxStatus, PortalApiService, ReportDefinition, ReportExecution, ScheduleNotificationRequest, SecurityPermission, SecurityResource, SecurityRole, SecurityUser, UpdateCatalogEntry, UpdateConfigurationItem, UpdateContentMetadata, UpdateHrEmployee, UpdateMenuItem, UpdateNotificationTemplate } from './portal-api.service';

interface ShellModule {
  readonly label: string;
  readonly status: string;
  readonly enabled: boolean;
  readonly gatewayPath: string;
  readonly probePath: string;
}

type ModuleProbeState = 'idle' | 'checking' | 'available' | 'protected' | 'unavailable';
type SecurityTab = 'users' | 'roles' | 'permissions' | 'resources';

interface ModuleProbeResult {
  readonly state: ModuleProbeState;
  readonly status?: number;
  readonly checkedAt?: Date;
}
type AdminSection = 'dashboard' | 'applications' | 'security' | 'menus' | 'configuration' | 'catalogs' | 'content' | 'audit' | 'reporting' | 'notifications' | 'integration' | 'operations';

interface NavigationItem {
  readonly id: AdminSection;
  readonly label: string;
  readonly description: string;
  readonly icon: string;
}

interface ApplicationMenuItem {
  readonly label: string;
  readonly route?: string;
  readonly dataPath?: string;
  readonly permission: string;
  readonly order: number;
}

interface ApplicationCard {
  readonly name: string;
  readonly code: string;
  readonly moduleCode: string;
  readonly description: string;
  readonly port?: number;
  readonly webPath?: string;
  readonly path: string;
  readonly probePath: string;
  readonly dataPath: string;
  readonly accessPermission: string;
  readonly uiMode: 'native' | 'iframe';
  readonly status: string;
  readonly menuItems: ApplicationMenuItem[];
}
@Component({
  selector: 'portal-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  constructor(
    private readonly sanitizer: DomSanitizer,
    private readonly portalApi: PortalApiService
  ) {}

  ngOnInit(): void {
    void this.initializeLocalPortal();
  }

  private async initializeLocalPortal(): Promise<void> {
    this.sessionInitializing = true;
    try {
      await this.refreshModuleHealth();
    } finally {
      this.sessionInitializing = false;
    }
  }

  private async openDeepLinkedApplication(): Promise<void> {
    if (typeof window === 'undefined') return;

    const params = new URL(window.location.href).searchParams;
    const requestedCode = params.get('app')?.trim().toUpperCase();
    if (!requestedCode) return;

    const application = this.applications.find(candidate => candidate.code === requestedCode);
    if (!application || !this.applicationAuthorized(application)) return;

    await this.openApplication(application);

    const requestedView = params.get('view')?.trim();
    if (!requestedView) return;

    const menuItem = this.visibleApplicationMenu(application).find(item =>
      item.route === requestedView ||
      item.label.toLowerCase() === requestedView.toLowerCase()
    );
    if (menuItem) await this.selectWorkspaceMenuItem(menuItem);
  }

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
    { id: 'content', label: 'Contenido', description: 'Archivos y documentos', icon: '▤' },
    { id: 'audit', label: 'Auditoría', description: 'Trazabilidad y eventos', icon: '◎' },
    { id: 'reporting', label: 'Reportes', description: 'Definiciones y ejecución', icon: '▥' },
    { id: 'notifications', label: 'Notificaciones', description: 'Plantillas y entregas', icon: '✉' },
    { id: 'integration', label: 'Integración', description: 'Outbox, Inbox y trazabilidad', icon: '⇄' },
    { id: 'operations', label: 'Operaciones', description: 'Salud de servicios', icon: '◌' }
  ];

  protected readonly applications: ApplicationCard[] = consumerRegistry.consumers.map((consumer) => ({
    name: consumer.name,
    code: consumer.code,
    moduleCode: consumer.moduleCode,
    description: consumer.description,
    port: consumer.webPort ?? undefined,
    webPath: consumer.webPath ?? undefined,
    path: consumer.gatewayPath,
    probePath: consumer.probePath,
    dataPath: consumer.protectedSmoke,
    accessPermission: consumer.accessPermission,
    uiMode: consumer.uiMode as 'native' | 'iframe',
    status: consumer.status,
    menuItems: [...consumer.menuItems]
      .map((item) => ({
        label: item.label,
        route: 'route' in item ? item.route : undefined,
        dataPath: 'dataPath' in item ? item.dataPath : undefined,
        permission: item.permission,
        order: item.order
      }))
      .sort((a, b) => a.order - b.order)
  }));

  private readonly governedApplicationMenus = new Map<string, ApplicationMenuItem[]>();

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
    ...consumerRegistry.consumers.map((consumer) => ({
      label: consumer.name,
      status: consumer.status,
      enabled: true,
      gatewayPath: consumer.gatewayPath,
      probePath: consumer.probePath
    }))
  ];

  protected activeSection: AdminSection = 'dashboard';
  protected sidebarCollapsed = false;
  protected workspaceApplication?: ApplicationCard;
  protected workspaceMenuItem?: ApplicationMenuItem;
  protected workspaceUrl?: SafeResourceUrl;
  protected workspaceProbeState: ModuleProbeState = 'idle';
  protected workspaceProbeStatus?: number;
  protected workspaceDataText = '';
  protected workspaceDataRows: Record<string, unknown>[] = [];
  protected workspaceDataColumns: string[] = [];
  protected workspaceDataLoading = false;
  protected workspaceDataError?: string;
  protected hrEmployeeCode = '';
  protected hrFullName = '';
  protected hrEmail = '';
  protected hrPosition = '';
  protected hrDepartment = '';
  protected hrSaving = false;
  protected hrEditingId?: string;
  protected hrSuccess?: string;
  protected selectedModule: ShellModule = this.modules[0];
  protected moduleProbeState: ModuleProbeState = 'idle';
  protected moduleProbeStatus?: number;
  protected readonly moduleProbeResults = new Map<string, ModuleProbeResult>();
  protected operationsRefreshing = false;
  protected sessionInitializing = false;
  protected loginEmail = 'superadmin@portal.local';
  protected loginPassword = '';
  protected loginError?: string;
  protected loginSubmitting = false;
  protected localAdminSession?: LocalAdminSession;
  protected securityApplication?: ApplicationCard;
  protected securityLoading = false;
  protected securityError?: string;
  protected activeSecurityTab: SecurityTab = 'users';
  protected securityUsers: SecurityUser[] = [];
  protected securityRoles: SecurityRole[] = [];
  protected securityPermissions: SecurityPermission[] = [];
  protected securityResources: SecurityResource[] = [];
  protected securitySaving = false;
  protected securitySuccess?: string;
  protected securityUserEmail = '';
  protected securityUserName = '';
  protected securityRoleName = '';
  protected securityResourceKey = '';
  protected securityResourceName = '';
  protected securityPermissionCode = '';
  protected securityPermissionResourceKey = '';
  protected securityPermissionAction = '';
  protected securityAssignUserId = '';
  protected securityAssignRoleId = '';
  protected securityAssignPermissionRoleId = '';
  protected securityAssignPermissionId = '';
  protected securityInspectUserId = '';
  protected securityUserPermissionCodes: string[] = [];
  protected securityCheckResourceKey = '';
  protected securityCheckAction = '';
  protected securityCheckAllowed?: boolean;
  protected menuModuleCode = 'portal';
  protected menuLoading = false;
  protected menuError?: string;
  protected menuItems: MenuItem[] = [];
  protected menuSaving = false;
  protected menuSuccess?: string;
  protected menuDefinitionName = '';
  protected menuDefinitionId = '';
  protected menuItemMode: 'create' | 'edit' = 'create';
  protected menuEditingItemId?: string;
  protected menuItemCode = '';
  protected menuItemLabel = '';
  protected menuItemRoute = '';
  protected menuItemIcon = '';
  protected menuItemOrder = 0;
  protected menuItemParentId = '';
  protected menuItemResourceKey = '';
  protected menuItemPermissionCode = '';
  protected menuItemMetadataJson = '';
  protected configurationScope = 0;
  protected configurationModuleCode = '';
  protected configurationUserId = '';
  protected configurationLoading = false;
  protected configurationError?: string;
  protected configurationItems: ConfigurationItem[] = [];
  protected configurationFormMode: 'create' | 'edit' = 'create';
  protected configurationEditingId?: string;
  protected configurationFormKey = '';
  protected configurationFormScope = 0;
  protected configurationFormModuleCode = '';
  protected configurationFormUserId = '';
  protected configurationFormCategory = 0;
  protected configurationFormValueJson = '{}';
  protected configurationFormIsActive = true;
  protected configurationSaving = false;
  protected configurationSuccess?: string;
  protected catalogNameFilter = '';
  protected catalogActiveFilter = 'all';
  protected catalogLoading = false;
  protected catalogError?: string;
  protected catalogEntries: CatalogEntry[] = [];
  protected catalogFormMode: 'create' | 'edit' = 'create';
  protected catalogEditingId?: string;
  protected catalogFormCatalog = '';
  protected catalogFormCode = '';
  protected catalogFormName = '';
  protected catalogFormDescription = '';
  protected catalogFormSortOrder = 0;
  protected catalogFormIsActive = true;
  protected catalogSaving = false;
  protected catalogSuccess?: string;
  protected contentModuleFilter = '';
  protected contentActiveFilter = 'all';
  protected contentLoading = false;
  protected contentError?: string;
  protected contentDocuments: ContentDocument[] = [];
  protected downloadingContentId?: string;
  protected contentFormMode: 'create' | 'edit' = 'create';
  protected contentEditingId?: string;
  protected contentFormModuleCode = '';
  protected contentFormFileName = '';
  protected contentFormContentType = 'application/octet-stream';
  protected contentSelectedFile?: File;
  protected contentSaving = false;
  protected contentSuccess?: string;
  protected auditResourceFilter = '';
  protected auditActionFilter = '';
  protected auditActorFilter = '';
  protected auditCorrelationFilter = '';
  protected auditSeverityFilter = 'all';
  protected auditLoading = false;
  protected auditError?: string;
  protected auditEvents: AuditEvent[] = [];
  protected auditSummary?: AuditSummary;
  protected auditPage = 1;
  protected readonly auditPageSize = 20;
  protected auditTotal = 0;
  protected reportingLoading = false;
  protected reportingError?: string;
  protected reportDefinitions: ReportDefinition[] = [];
  protected selectedReportKey = '';
  protected reportParameterValues: Record<string, string> = {};
  protected reportExecution?: ReportExecution;
  protected notificationLoading = false;
  protected notificationError?: string;
  protected notificationTemplates: NotificationTemplate[] = [];
  protected notificationMessages: NotificationMessage[] = [];
  protected notificationActionId?: string;
  protected notificationSaving = false;
  protected notificationSuccess?: string;
  protected notificationTemplateMode: 'create' | 'edit' = 'create';
  protected notificationTemplateEditingId?: string;
  protected notificationTemplateCode = '';
  protected notificationTemplateSubject = '';
  protected notificationTemplateBody = '';
  protected notificationTemplateVariables = '';
  protected notificationTemplateChannel = 2;
  protected notificationSendTemplateCode = '';
  protected notificationSendRecipients = '';
  protected notificationSendVariablesJson = '{}';
  protected notificationSendChannel = '';
  protected notificationSendIdempotencyKey = '';
  protected notificationSendMetadataJson = '';
  protected notificationScheduleAt = '';
  protected integrationLoading = false;
  protected integrationError?: string;
  protected integrationMessageId = '';
  protected integrationIdempotencyKey = '';
  protected integrationInboxSource = '';
  protected integrationInboxKey = '';
  protected outboxByMessageId?: OutboxMessageStatus;
  protected outboxByIdempotencyKey?: OutboxStatus;
  protected inboxProcessedStatus?: InboxProcessedStatus;
  protected readonly currentTenant = 'default';

  protected selectSection(section: AdminSection): void {
    this.activeSection = section;
    void this.activateSection(section);
  }

  protected toggleSidebar(): void {
    this.sidebarCollapsed = !this.sidebarCollapsed;
  }

  private async activateSection(section: AdminSection): Promise<void> {
    if (section === 'operations') {
      await this.refreshModuleHealth();
      return;
    }

    if (section === 'dashboard' || section === 'applications') return;

    if (!this.portalApi.hasAuthenticatedSession()) {
      await this.connectLocalSession();
      if (!this.portalApi.hasAuthenticatedSession()) return;
    }

    if (section === 'security') await this.loadSecurityData();
    if (section === 'menus') await this.loadMenuData();
    if (section === 'configuration') await this.loadConfigurationData();
    if (section === 'catalogs') await this.loadCatalogData();
    if (section === 'content') await this.loadContentData();
    if (section === 'audit') await this.loadAuditData(1);
    if (section === 'reporting') await this.loadReportingData();
    if (section === 'notifications') await this.loadNotificationData();
  }

  protected hasAuthenticatedSession(): boolean {
    return this.portalApi.hasAuthenticatedSession();
  }

  protected async connectLocalSession(): Promise<void> {
    if (this.portalApi.hasAuthenticatedSession() || this.loginSubmitting) return;

    const email = this.loginEmail.trim().toLowerCase();
    const password = this.loginPassword;
    if (!email || !password) {
      this.loginError = 'Ingresa usuario y contraseña.';
      return;
    }

    this.loginSubmitting = true;
    this.securityLoading = true;
    this.loginError = undefined;
    this.securityError = undefined;
    this.securitySuccess = undefined;
    try {
      const session = await firstValueFrom(this.portalApi.createLocalSuperAdminSession(email, password));
      this.portalApi.setAccessToken(session.accessToken);
      this.localAdminSession = session;
      this.loginPassword = '';
      if (this.workspaceApplication) this.publishPortalShellContext(this.workspaceApplication);
      this.securitySuccess = `${session.displayName} conectado · ${session.role} · ${session.permissions.length} permisos`;
      await this.refreshModuleHealth();
      await this.openDeepLinkedApplication();
    } catch {
      this.portalApi.clearAccessToken();
      this.localAdminSession = undefined;
      this.loginError = 'Usuario o contraseña incorrectos.';
    } finally {
      this.securityLoading = false;
      this.loginSubmitting = false;
    }
  }

  protected async clearLocalSession(): Promise<void> {
    this.portalApi.clearAccessToken();
    this.localAdminSession = undefined;
    this.clearPortalShellContext();
    this.securityApplication = undefined;
    try {
      await firstValueFrom(this.portalApi.clearLocalSuperAdminSession());
    } catch {
      // The in-memory credential is already cleared; cookie cleanup is best-effort.
    }
    this.securityUsers = [];
    this.securityRoles = [];
    this.securityPermissions = [];
    this.securityResources = [];
    this.securityUserPermissionCodes = [];
    this.securityCheckAllowed = undefined;
    this.securityError = undefined;
    this.securitySuccess = undefined;
    this.loginError = undefined;
    this.loginPassword = '';
    this.activeSection = 'dashboard';
    this.sidebarCollapsed = false;
    this.closeWorkspace();
  }

  protected selectSecurityTab(tab: SecurityTab): void {
    this.activeSecurityTab = tab;
  }

  protected async createSecurityUser(): Promise<void> {
    const email = this.securityUserEmail.trim().toLowerCase();
    const name = this.securityUserName.trim();
    if (!email || !name) {
      this.securityError = 'Email y nombre son obligatorios.';
      return;
    }
    await this.runSecurityMutation(async () => {
      const response = await firstValueFrom(this.portalApi.createUser(email, name));
      this.securityUserEmail = '';
      this.securityUserName = '';
      this.securitySuccess = `Usuario ${response.data.email} creado correctamente.`;
    });
  }

  protected async createSecurityRole(): Promise<void> {
    const name = this.securityRoleName.trim();
    if (!name) {
      this.securityError = 'El nombre del rol es obligatorio.';
      return;
    }
    await this.runSecurityMutation(async () => {
      const response = await firstValueFrom(this.portalApi.createRole(name));
      this.securityRoleName = '';
      this.securitySuccess = `Rol ${response.data.name} creado correctamente.`;
    });
  }

  protected async createSecurityResource(): Promise<void> {
    const key = this.securityResourceKey.trim().toLowerCase();
    const name = this.securityResourceName.trim();
    if (!key || !name) {
      this.securityError = 'Clave y nombre del recurso son obligatorios.';
      return;
    }
    await this.runSecurityMutation(async () => {
      const response = await firstValueFrom(this.portalApi.createResource(key, name));
      this.securityResourceKey = '';
      this.securityResourceName = '';
      this.securitySuccess = `Recurso ${response.data.key} registrado correctamente.`;
    });
  }

  protected async createSecurityPermission(): Promise<void> {
    const code = this.securityPermissionCode.trim().toLowerCase();
    const resourceKey = this.securityPermissionResourceKey.trim().toLowerCase();
    const action = this.securityPermissionAction.trim().toLowerCase();
    if (!code || !resourceKey || !action) {
      this.securityError = 'Código, recurso y acción son obligatorios.';
      return;
    }
    await this.runSecurityMutation(async () => {
      const response = await firstValueFrom(this.portalApi.createPermission(code, resourceKey, action));
      this.securityPermissionCode = '';
      this.securityPermissionAction = '';
      this.securitySuccess = `Permiso ${response.data.code} creado correctamente.`;
    });
  }

  protected async assignSecurityRoleToUser(): Promise<void> {
    if (!this.securityAssignUserId || !this.securityAssignRoleId) {
      this.securityError = 'Selecciona usuario y rol.';
      return;
    }
    await this.runSecurityMutation(async () => {
      await firstValueFrom(this.portalApi.assignRoleToUser(this.securityAssignUserId, this.securityAssignRoleId));
      this.securitySuccess = 'Rol asignado al usuario correctamente.';
      this.securityInspectUserId = this.securityAssignUserId;
      await this.loadSecurityUserPermissions();
    }, false);
  }

  protected async assignSecurityPermissionToRole(): Promise<void> {
    if (!this.securityAssignPermissionRoleId || !this.securityAssignPermissionId) {
      this.securityError = 'Selecciona rol y permiso.';
      return;
    }
    await this.runSecurityMutation(async () => {
      await firstValueFrom(this.portalApi.assignPermissionToRole(this.securityAssignPermissionRoleId, this.securityAssignPermissionId));
      this.securitySuccess = 'Permiso asignado al rol correctamente.';
    }, false);
  }

  protected async loadSecurityUserPermissions(): Promise<void> {
    if (!this.securityInspectUserId) {
      this.securityUserPermissionCodes = [];
      return;
    }
    this.securityError = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.loadUserPermissions(this.securityInspectUserId));
      this.securityUserPermissionCodes = response.data.permissions ?? [];
    } catch (error: unknown) {
      this.securityUserPermissionCodes = [];
      this.securityError = error instanceof Error ? error.message : 'No fue posible consultar los permisos efectivos del usuario.';
    }
  }

  protected async checkSecurityPermission(): Promise<void> {
    const resourceKey = this.securityCheckResourceKey.trim().toLowerCase();
    const action = this.securityCheckAction.trim().toLowerCase();
    if (!this.securityInspectUserId || !resourceKey || !action) {
      this.securityError = 'Selecciona usuario e ingresa recurso y acción.';
      return;
    }
    this.securityError = undefined;
    this.securityCheckAllowed = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.checkPermission(this.securityInspectUserId, resourceKey, action));
      this.securityCheckAllowed = response.data.allowed;
    } catch (error: unknown) {
      this.securityError = error instanceof Error ? error.message : 'No fue posible evaluar el permiso.';
    }
  }

  private async runSecurityMutation(operation: () => Promise<void>, reload = true): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession() || this.securitySaving) return;
    this.securitySaving = true;
    this.securityError = undefined;
    this.securitySuccess = undefined;
    try {
      await operation();
      if (reload) await this.loadSecurityData();
    } catch (error: unknown) {
      this.securityError = error instanceof Error ? error.message : 'No fue posible completar la operación de seguridad.';
    } finally {
      this.securitySaving = false;
    }
  }

  protected async loadCatalogData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const catalog = this.catalogNameFilter.trim().toLowerCase();
    const isActive = this.catalogActiveFilter === 'all' ? undefined : this.catalogActiveFilter === 'active';
    this.catalogLoading = true;
    this.catalogError = undefined;
    try {
      this.catalogEntries = await firstValueFrom(this.portalApi.loadCatalog(catalog || undefined, isActive));
    } catch (error: unknown) {
      this.catalogEntries = [];
      this.catalogError = error instanceof Error ? error.message : 'No fue posible cargar Catalog API.';
    } finally {
      this.catalogLoading = false;
    }
  }

  protected beginCreateCatalogEntry(): void {
    this.catalogFormMode = 'create';
    this.catalogEditingId = undefined;
    this.catalogFormCatalog = this.catalogNameFilter.trim().toLowerCase();
    this.catalogFormCode = '';
    this.catalogFormName = '';
    this.catalogFormDescription = '';
    this.catalogFormSortOrder = 0;
    this.catalogFormIsActive = true;
    this.catalogError = undefined;
    this.catalogSuccess = undefined;
  }

  protected beginEditCatalogEntry(entry: CatalogEntry): void {
    this.catalogFormMode = 'edit';
    this.catalogEditingId = entry.id;
    this.catalogFormCatalog = entry.catalog;
    this.catalogFormCode = entry.code;
    this.catalogFormName = entry.name;
    this.catalogFormDescription = entry.description ?? '';
    this.catalogFormSortOrder = entry.sortOrder;
    this.catalogFormIsActive = entry.isActive;
    this.catalogError = undefined;
    this.catalogSuccess = undefined;
  }

  protected cancelCatalogEdit(): void {
    this.beginCreateCatalogEntry();
  }

  protected async saveCatalogEntry(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const name = this.catalogFormName.trim();
    const description = this.catalogFormDescription.trim() || null;
    const sortOrder = Number(this.catalogFormSortOrder) || 0;

    if (!name) {
      this.catalogError = 'Ingresa el nombre del valor de catálogo.';
      return;
    }

    this.catalogSaving = true;
    this.catalogError = undefined;
    this.catalogSuccess = undefined;
    try {
      let successMessage = '';
      if (this.catalogFormMode === 'create') {
        const catalog = this.catalogFormCatalog.trim().toLowerCase();
        const code = this.catalogFormCode.trim().toLowerCase();
        if (!catalog || !code) {
          this.catalogError = 'Catálogo y código son obligatorios para crear un valor.';
          return;
        }
        const request: CreateCatalogEntry = { catalog, code, name, description, sortOrder };
        const created = await firstValueFrom(this.portalApi.createCatalogEntry(request));
        successMessage = `Valor ${created.code} creado correctamente.`;
        this.catalogNameFilter = created.catalog;
      } else if (this.catalogEditingId) {
        const request: UpdateCatalogEntry = { name, description, isActive: this.catalogFormIsActive, sortOrder };
        const updated = await firstValueFrom(this.portalApi.updateCatalogEntry(this.catalogEditingId, request));
        successMessage = `Valor ${updated.code} actualizado correctamente.`;
      }
      await this.loadCatalogData();
      this.beginCreateCatalogEntry();
      this.catalogSuccess = successMessage;
    } catch (error: unknown) {
      this.catalogError = error instanceof Error ? error.message : 'No fue posible guardar el valor de catálogo.';
    } finally {
      this.catalogSaving = false;
    }
  }

  protected async toggleCatalogEntry(entry: CatalogEntry): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.catalogSaving = true;
    this.catalogError = undefined;
    this.catalogSuccess = undefined;
    try {
      const request: UpdateCatalogEntry = {
        name: entry.name,
        description: entry.description ?? null,
        isActive: !entry.isActive,
        sortOrder: entry.sortOrder
      };
      const updated = await firstValueFrom(this.portalApi.updateCatalogEntry(entry.id, request));
      const successMessage = `${updated.code} quedó ${updated.isActive ? 'activo' : 'inactivo'}.`;
      await this.loadCatalogData();
      if (this.catalogEditingId === entry.id) this.beginEditCatalogEntry(updated);
      this.catalogSuccess = successMessage;
    } catch (error: unknown) {
      this.catalogError = error instanceof Error ? error.message : 'No fue posible cambiar el estado del catálogo.';
    } finally {
      this.catalogSaving = false;
    }
  }

  protected async loadContentData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const moduleCode = this.contentModuleFilter.trim().toLowerCase();
    const isActive = this.contentActiveFilter === 'all' ? undefined : this.contentActiveFilter === 'active';
    this.contentLoading = true;
    this.contentError = undefined;
    try {
      this.contentDocuments = await firstValueFrom(this.portalApi.loadContent(moduleCode || undefined, isActive));
    } catch (error: unknown) {
      this.contentDocuments = [];
      this.contentError = error instanceof Error ? error.message : 'No fue posible cargar Content API.';
    } finally {
      this.contentLoading = false;
    }
  }

  protected beginCreateContentDocument(): void {
    this.contentFormMode = 'create';
    this.contentEditingId = undefined;
    this.contentFormModuleCode = this.contentModuleFilter.trim().toLowerCase();
    this.contentFormFileName = '';
    this.contentFormContentType = 'application/octet-stream';
    this.contentSelectedFile = undefined;
    this.contentError = undefined;
    this.contentSuccess = undefined;
  }

  protected beginEditContentDocument(document: ContentDocument): void {
    this.contentFormMode = 'edit';
    this.contentEditingId = document.id;
    this.contentFormModuleCode = document.moduleCode;
    this.contentFormFileName = document.fileName;
    this.contentFormContentType = document.contentType;
    this.contentSelectedFile = undefined;
    this.contentError = undefined;
    this.contentSuccess = undefined;
  }

  protected selectContentFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    this.contentSelectedFile = file;
    if (file) {
      this.contentFormFileName = file.name;
      this.contentFormContentType = file.type || 'application/octet-stream';
    }
  }

  protected async saveContentDocument(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const moduleCode = this.contentFormModuleCode.trim().toLowerCase();
    const fileName = this.contentFormFileName.trim();
    const contentType = this.contentFormContentType.trim();
    if (!moduleCode || !fileName || !contentType) {
      this.contentError = 'Módulo, nombre de archivo y tipo MIME son obligatorios.';
      return;
    }

    this.contentSaving = true;
    this.contentError = undefined;
    this.contentSuccess = undefined;
    try {
      let successMessage = '';
      if (this.contentFormMode === 'create') {
        const file = this.contentSelectedFile;
        if (!file) {
          this.contentError = 'Selecciona un archivo para cargar.';
          return;
        }
        if (file.size === 0 || file.size > 10 * 1024 * 1024) {
          this.contentError = 'El archivo debe tener contenido y no superar 10 MB.';
          return;
        }
        const bytes = new Uint8Array(await file.arrayBuffer());
        let binary = '';
        for (let offset = 0; offset < bytes.length; offset += 32768) {
          binary += String.fromCharCode(...bytes.subarray(offset, offset + 32768));
        }
        const request: CreateContentDocument = { moduleCode, fileName, contentType, content: btoa(binary) };
        const created = await firstValueFrom(this.portalApi.createContentDocument(request));
        this.contentModuleFilter = created.moduleCode;
        successMessage = `Documento ${created.fileName} cargado. SHA-256 ${created.sha256.slice(0, 12)}…`;
      } else if (this.contentEditingId) {
        const request: UpdateContentMetadata = { moduleCode, fileName, contentType };
        const updated = await firstValueFrom(this.portalApi.updateContentMetadata(this.contentEditingId, request));
        successMessage = `Metadatos de ${updated.fileName} actualizados sin modificar el contenido.`;
      }
      await this.loadContentData();
      this.beginCreateContentDocument();
      this.contentSuccess = successMessage;
    } catch (error: unknown) {
      this.contentError = error instanceof Error ? error.message : 'No fue posible guardar el documento.';
    } finally {
      this.contentSaving = false;
    }
  }

  protected async toggleContentDocument(document: ContentDocument): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.contentSaving = true;
    this.contentError = undefined;
    this.contentSuccess = undefined;
    try {
      const updated = await firstValueFrom(this.portalApi.setContentActive(document.id, !document.isActive));
      const successMessage = `${updated.fileName} quedó ${updated.isActive ? 'activo' : 'inactivo'}.`;
      await this.loadContentData();
      if (this.contentEditingId === document.id) this.beginEditContentDocument(updated);
      this.contentSuccess = successMessage;
    } catch (error: unknown) {
      this.contentError = error instanceof Error ? error.message : 'No fue posible cambiar el estado del documento.';
    } finally {
      this.contentSaving = false;
    }
  }

  protected async downloadContentDocument(document: ContentDocument): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession() || !document.isActive) return;
    this.downloadingContentId = document.id;
    this.contentError = undefined;
    try {
      const blob = await firstValueFrom(this.portalApi.downloadContent(document.id));
      const url = URL.createObjectURL(blob);
      const anchor = window.document.createElement('a');
      anchor.href = url;
      anchor.download = document.fileName;
      anchor.click();
      URL.revokeObjectURL(url);
    } catch (error: unknown) {
      this.contentError = error instanceof Error ? error.message : 'No fue posible descargar el documento.';
    } finally {
      this.downloadingContentId = undefined;
    }
  }

  protected formatFileSize(length: number): string {
    if (length < 1024) return `${length} B`;
    if (length < 1024 * 1024) return `${(length / 1024).toFixed(1)} KB`;
    return `${(length / (1024 * 1024)).toFixed(1)} MB`;
  }

  protected async loadAuditData(page = 1): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const severity = this.auditSeverityFilter === 'all' ? undefined : Number(this.auditSeverityFilter);
    this.auditLoading = true;
    this.auditError = undefined;
    try {
      const [eventsResponse, summaryResponse] = await Promise.all([
        firstValueFrom(this.portalApi.loadAudit({
          resource: this.auditResourceFilter.trim() || undefined,
          action: this.auditActionFilter.trim() || undefined,
          actorId: this.auditActorFilter.trim() || undefined,
          correlationId: this.auditCorrelationFilter.trim() || undefined,
          severity,
          page,
          pageSize: this.auditPageSize
        })),
        firstValueFrom(this.portalApi.loadAuditSummary(24))
      ]);
      const auditPage = eventsResponse.data;
      this.auditEvents = auditPage?.items ?? [];
      this.auditPage = auditPage?.page ?? page;
      this.auditTotal = auditPage?.total ?? 0;
      this.auditSummary = summaryResponse.data;
    } catch (error: unknown) {
      this.auditEvents = [];
      this.auditTotal = 0;
      this.auditSummary = undefined;
      this.auditError = error instanceof Error ? error.message : 'No fue posible cargar Audit API.';
    } finally {
      this.auditLoading = false;
    }
  }

  protected auditLastPage(): number {
    return Math.max(1, Math.ceil(this.auditTotal / this.auditPageSize));
  }

  protected auditSeverityLabel(severity: number): string {
    return ['Información', 'Advertencia', 'Error', 'Crítico'][severity] ?? `Nivel ${severity}`;
  }

  protected formatAuditTimestamp(value: string): string {
    return new Date(value).toLocaleString();
  }

  protected async loadReportingData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.reportingLoading = true;
    this.reportingError = undefined;
    try {
      this.reportDefinitions = await firstValueFrom(this.portalApi.loadReports());
      if (!this.selectedReportKey && this.reportDefinitions.length > 0) {
        this.selectReport(this.reportDefinitions[0].key);
      }
    } catch (error: unknown) {
      this.reportDefinitions = [];
      this.reportExecution = undefined;
      this.reportingError = error instanceof Error ? error.message : 'No fue posible cargar Reporting API.';
    } finally {
      this.reportingLoading = false;
    }
  }

  protected selectReport(key: string): void {
    this.selectedReportKey = key;
    this.reportExecution = undefined;
    this.reportingError = undefined;
    const definition = this.selectedReport();
    const nextValues: Record<string, string> = {};
    for (const parameter of definition?.requiredParameters ?? []) nextValues[parameter] = this.reportParameterValues[parameter] ?? '';
    this.reportParameterValues = nextValues;
  }

  protected selectedReport(): ReportDefinition | undefined {
    return this.reportDefinitions.find((report) => report.key === this.selectedReportKey);
  }

  protected setReportParameter(name: string, value: string): void {
    this.reportParameterValues = { ...this.reportParameterValues, [name]: value };
  }

  protected async executeSelectedReport(): Promise<void> {
    const definition = this.selectedReport();
    if (!definition || !this.portalApi.hasAuthenticatedSession()) return;
    const parameters: Record<string, string> = {};
    for (const name of definition.requiredParameters) {
      const value = (this.reportParameterValues[name] ?? '').trim();
      if (!value) {
        this.reportingError = `Completa el parámetro requerido: ${name}.`;
        this.reportExecution = undefined;
        return;
      }
      parameters[name] = value;
    }
    this.reportingLoading = true;
    this.reportingError = undefined;
    try {
      this.reportExecution = await firstValueFrom(this.portalApi.executeReport(definition.key, parameters));
    } catch (error: unknown) {
      this.reportExecution = undefined;
      this.reportingError = error instanceof Error ? error.message : 'No fue posible ejecutar el reporte.';
    } finally {
      this.reportingLoading = false;
    }
  }

  protected reportColumns(): string[] {
    const firstRow = this.reportExecution?.rows[0];
    return firstRow ? Object.keys(firstRow) : [];
  }

  protected beginCreateNotificationTemplate(): void {
    this.notificationTemplateMode = 'create';
    this.notificationTemplateEditingId = undefined;
    this.notificationTemplateCode = '';
    this.notificationTemplateSubject = '';
    this.notificationTemplateBody = '';
    this.notificationTemplateVariables = '';
    this.notificationTemplateChannel = 2;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
  }

  protected beginEditNotificationTemplate(template: NotificationTemplate): void {
    this.notificationTemplateMode = 'edit';
    this.notificationTemplateEditingId = template.id;
    this.notificationTemplateCode = template.code;
    this.notificationTemplateSubject = template.subject;
    this.notificationTemplateBody = template.body;
    this.notificationTemplateVariables = template.allowedVariables.join(', ');
    this.notificationTemplateChannel = template.defaultChannel;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
  }

  protected async saveNotificationTemplate(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const code = this.notificationTemplateCode.trim().toLowerCase();
    const subject = this.notificationTemplateSubject.trim();
    const body = this.notificationTemplateBody.trim();
    const allowedVariables = this.notificationTemplateVariables.split(',').map(x => x.trim()).filter(Boolean);
    if (!code || !subject || !body) {
      this.notificationError = 'Código, asunto y cuerpo son obligatorios.';
      return;
    }
    this.notificationSaving = true;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
    try {
      let message = '';
      if (this.notificationTemplateMode === 'create') {
        const request: CreateNotificationTemplate = { code, subject, body, allowedVariables, defaultChannel: Number(this.notificationTemplateChannel) };
        const response = await firstValueFrom(this.portalApi.createNotificationTemplate(request));
        message = `Plantilla ${response.data.code} creada en versión ${response.data.version}.`;
      } else if (this.notificationTemplateEditingId) {
        const request: UpdateNotificationTemplate = { subject, body, allowedVariables, defaultChannel: Number(this.notificationTemplateChannel) };
        const response = await firstValueFrom(this.portalApi.updateNotificationTemplate(this.notificationTemplateEditingId, request));
        message = `Plantilla ${response.data.code} actualizada a versión ${response.data.version}.`;
      }
      await this.loadNotificationData();
      this.beginCreateNotificationTemplate();
      this.notificationSuccess = message;
    } catch (error: unknown) {
      this.notificationError = error instanceof Error ? error.message : 'No fue posible guardar la plantilla.';
    } finally {
      this.notificationSaving = false;
    }
  }

  protected async toggleNotificationTemplate(template: NotificationTemplate): Promise<void> {
    this.notificationSaving = true;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.setNotificationTemplateActive(template.id, !template.isActive));
      await this.loadNotificationData();
      this.notificationSuccess = `${response.data.code} quedó ${response.data.isActive ? 'activa' : 'inactiva'}.`;
    } catch (error: unknown) {
      this.notificationError = error instanceof Error ? error.message : 'No fue posible cambiar el estado de la plantilla.';
    } finally {
      this.notificationSaving = false;
    }
  }

  protected prepareNotificationSend(template: NotificationTemplate): void {
    this.notificationSendTemplateCode = template.code;
    this.notificationSendVariablesJson = JSON.stringify(Object.fromEntries(template.allowedVariables.map(x => [x, ''])), null, 2);
    this.notificationSendChannel = String(template.defaultChannel);
    this.notificationSendIdempotencyKey = `portal-ui-${Date.now()}`;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
  }

  protected async submitNotification(schedule: boolean): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const templateCode = this.notificationSendTemplateCode.trim().toLowerCase();
    const recipients = this.notificationSendRecipients.split(/[;,\n]/).map(x => x.trim()).filter(Boolean);
    const idempotencyKey = this.notificationSendIdempotencyKey.trim();
    if (!templateCode || recipients.length === 0 || !idempotencyKey) {
      this.notificationError = 'Plantilla, destinatarios e idempotency key son obligatorios.';
      return;
    }
    let variables: Record<string,string>;
    let metadataJson: string | null = this.notificationSendMetadataJson.trim() || null;
    try {
      variables = JSON.parse(this.notificationSendVariablesJson || '{}') as Record<string,string>;
      if (metadataJson) JSON.parse(metadataJson);
    } catch {
      this.notificationError = 'Variables y metadata deben contener JSON válido.';
      return;
    }
    if (schedule && !this.notificationScheduleAt) {
      this.notificationError = 'Selecciona fecha y hora para programar la notificación.';
      return;
    }
    const channel = this.notificationSendChannel === '' ? null : Number(this.notificationSendChannel);
    const base: NotificationRequest = { templateCode, recipients, variables, channel, idempotencyKey, metadataJson };
    this.notificationSaving = true;
    this.notificationError = undefined;
    this.notificationSuccess = undefined;
    try {
      const response = schedule
        ? await firstValueFrom(this.portalApi.scheduleNotification({ ...base, scheduledAtUtc: new Date(this.notificationScheduleAt).toISOString() } as ScheduleNotificationRequest))
        : await firstValueFrom(this.portalApi.sendNotification(base));
      await this.loadNotificationData();
      this.notificationSuccess = `Notificación ${response.data.id} ${schedule ? 'programada' : 'solicitada'} correctamente.`;
    } catch (error: unknown) {
      this.notificationError = error instanceof Error ? error.message : 'No fue posible solicitar la notificación.';
    } finally {
      this.notificationSaving = false;
    }
  }

  protected async loadNotificationData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.notificationLoading = true;
    this.notificationError = undefined;
    try {
      const [templatesResponse, messagesResponse] = await Promise.all([
        firstValueFrom(this.portalApi.loadNotificationTemplates()),
        firstValueFrom(this.portalApi.loadNotificationMessages())
      ]);
      this.notificationTemplates = templatesResponse.data ?? [];
      this.notificationMessages = messagesResponse.data ?? [];
    } catch (error: unknown) {
      this.notificationTemplates = [];
      this.notificationMessages = [];
      this.notificationError = error instanceof Error ? error.message : 'No fue posible cargar Notification API.';
    } finally {
      this.notificationLoading = false;
    }
  }

  protected notificationChannelLabel(channel: number): string {
    return ['Interno', 'Email Dev', 'Log Dev'][channel] ?? `Canal ${channel}`;
  }

  protected notificationStatusLabel(status: number): string {
    return ['Pendiente', 'Procesando', 'Enviado', 'Fallido', 'Cancelado', 'Dead letter'][status] ?? `Estado ${status}`;
  }

  protected canRetryNotification(message: NotificationMessage): boolean {
    return message.status === 3 || message.status === 5;
  }

  protected canCancelNotification(message: NotificationMessage): boolean {
    return message.status !== 2 && message.status !== 4;
  }

  protected async retryNotification(message: NotificationMessage): Promise<void> {
    if (!this.canRetryNotification(message) || !this.portalApi.hasAuthenticatedSession()) return;
    this.notificationActionId = message.id;
    this.notificationError = undefined;
    try {
      await firstValueFrom(this.portalApi.retryNotification(message.id));
      await this.loadNotificationData();
    } catch (error: unknown) {
      this.notificationError = error instanceof Error ? error.message : 'No fue posible reintentar la notificación.';
    } finally {
      this.notificationActionId = undefined;
    }
  }

  protected async cancelNotification(message: NotificationMessage): Promise<void> {
    if (!this.canCancelNotification(message) || !this.portalApi.hasAuthenticatedSession()) return;
    this.notificationActionId = message.id;
    this.notificationError = undefined;
    try {
      await firstValueFrom(this.portalApi.cancelNotification(message.id));
      await this.loadNotificationData();
    } catch (error: unknown) {
      this.notificationError = error instanceof Error ? error.message : 'No fue posible cancelar la notificación.';
    } finally {
      this.notificationActionId = undefined;
    }
  }

  protected async lookupOutboxByMessageId(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const messageId = this.integrationMessageId.trim();
    if (!messageId) {
      this.integrationError = 'Ingresa un messageId válido.';
      this.outboxByMessageId = undefined;
      return;
    }
    this.integrationLoading = true;
    this.integrationError = undefined;
    try {
      this.outboxByMessageId = await firstValueFrom(this.portalApi.loadOutboxByMessageId(messageId));
    } catch (error: unknown) {
      this.outboxByMessageId = undefined;
      this.integrationError = error instanceof Error ? error.message : 'No fue posible consultar el Outbox.';
    } finally {
      this.integrationLoading = false;
    }
  }

  protected async lookupOutboxByIdempotencyKey(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const key = this.integrationIdempotencyKey.trim();
    if (!key) {
      this.integrationError = 'Ingresa una idempotencyKey válida.';
      this.outboxByIdempotencyKey = undefined;
      return;
    }
    this.integrationLoading = true;
    this.integrationError = undefined;
    try {
      this.outboxByIdempotencyKey = await firstValueFrom(this.portalApi.loadOutboxByIdempotencyKey(this.currentTenant, key));
    } catch (error: unknown) {
      this.outboxByIdempotencyKey = undefined;
      this.integrationError = error instanceof Error ? error.message : 'No fue posible consultar el Outbox por idempotencia.';
    } finally {
      this.integrationLoading = false;
    }
  }

  protected async lookupInboxProcessed(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const source = this.integrationInboxSource.trim();
    const key = this.integrationInboxKey.trim();
    if (!source || !key) {
      this.integrationError = 'Ingresa source e idempotencyKey para consultar Inbox.';
      this.inboxProcessedStatus = undefined;
      return;
    }
    this.integrationLoading = true;
    this.integrationError = undefined;
    try {
      this.inboxProcessedStatus = await firstValueFrom(this.portalApi.checkInboxProcessed(this.currentTenant, source, key));
    } catch (error: unknown) {
      this.inboxProcessedStatus = undefined;
      this.integrationError = error instanceof Error ? error.message : 'No fue posible consultar el Inbox.';
    } finally {
      this.integrationLoading = false;
    }
  }

  protected beginCreateConfigurationItem(): void {
    this.configurationFormMode = 'create';
    this.configurationEditingId = undefined;
    this.configurationFormKey = '';
    this.configurationFormScope = Number(this.configurationScope);
    this.configurationFormModuleCode = this.configurationScope >= 2 ? this.configurationModuleCode.trim().toLowerCase() : '';
    this.configurationFormUserId = this.configurationScope === 3 ? this.configurationUserId.trim() : '';
    this.configurationFormCategory = 0;
    this.configurationFormValueJson = '{}';
    this.configurationFormIsActive = true;
    this.configurationError = undefined;
    this.configurationSuccess = undefined;
  }

  protected beginEditConfigurationItem(item: ConfigurationItem): void {
    this.configurationFormMode = 'edit';
    this.configurationEditingId = item.id;
    this.configurationFormKey = item.key;
    this.configurationFormScope = item.scope;
    this.configurationFormModuleCode = item.moduleCode ?? '';
    this.configurationFormUserId = item.userId ?? '';
    this.configurationFormCategory = item.category;
    this.configurationFormValueJson = item.valueJson;
    this.configurationFormIsActive = item.isActive;
    this.configurationError = undefined;
    this.configurationSuccess = undefined;
  }

  protected cancelConfigurationEdit(): void {
    this.beginCreateConfigurationItem();
  }

  protected async saveConfigurationItem(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const key = this.configurationFormKey.trim().toLowerCase();
    const scope = Number(this.configurationFormScope);
    const moduleCode = scope >= 2 ? this.configurationFormModuleCode.trim().toLowerCase() : '';
    const userId = scope === 3 ? this.configurationFormUserId.trim() : '';
    const valueJson = this.configurationFormValueJson.trim();

    if (!key) {
      this.configurationError = 'Ingresa la clave del parámetro.';
      return;
    }
    if (scope >= 2 && !moduleCode) {
      this.configurationError = 'El código de módulo es obligatorio para scope Módulo o Usuario.';
      return;
    }
    if (scope === 3 && !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(userId)) {
      this.configurationError = 'Ingresa un User ID GUID válido para scope Usuario.';
      return;
    }
    try {
      JSON.parse(valueJson);
    } catch {
      this.configurationError = 'ValueJson debe contener JSON válido.';
      return;
    }

    this.configurationSaving = true;
    this.configurationError = undefined;
    this.configurationSuccess = undefined;
    try {
      let successMessage = '';
      if (this.configurationFormMode === 'create') {
        const request: CreateConfigurationItem = {
          key,
          scope,
          moduleCode: moduleCode || null,
          userId: userId || null,
          category: Number(this.configurationFormCategory),
          valueJson
        };
        const response = await firstValueFrom(this.portalApi.createConfigurationItem(request));
        successMessage = `Parámetro ${response.data.key} creado en versión ${response.data.version}.`;
        this.configurationScope = response.data.scope;
        this.configurationModuleCode = response.data.moduleCode ?? '';
        this.configurationUserId = response.data.userId ?? '';
      } else if (this.configurationEditingId) {
        const request: UpdateConfigurationItem = { category: Number(this.configurationFormCategory), valueJson };
        const response = await firstValueFrom(this.portalApi.updateConfigurationItem(this.configurationEditingId, request));
        successMessage = `Parámetro ${response.data.key} actualizado a versión ${response.data.version}.`;
      }
      await this.loadConfigurationData();
      this.beginCreateConfigurationItem();
      this.configurationSuccess = successMessage;
    } catch (error: unknown) {
      this.configurationError = error instanceof Error ? error.message : 'No fue posible guardar el parámetro.';
    } finally {
      this.configurationSaving = false;
    }
  }

  protected async toggleConfigurationItem(item: ConfigurationItem): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.configurationSaving = true;
    this.configurationError = undefined;
    this.configurationSuccess = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.setConfigurationActive(item.id, !item.isActive));
      const updated = response.data;
      const successMessage = `${updated.key} quedó ${updated.isActive ? 'activo' : 'inactivo'} en versión ${updated.version}.`;
      await this.loadConfigurationData();
      if (this.configurationEditingId === item.id) this.beginEditConfigurationItem(updated);
      this.configurationSuccess = successMessage;
    } catch (error: unknown) {
      this.configurationError = error instanceof Error ? error.message : 'No fue posible cambiar el estado del parámetro.';
    } finally {
      this.configurationSaving = false;
    }
  }

  protected configurationScopeLabel(scope: number): string {
    return ['Global', 'Tenant', 'Módulo', 'Usuario'][scope] ?? `Scope ${scope}`;
  }

  protected configurationCategoryLabel(category: number): string {
    return ['Visual', 'Funcional', 'Grid', 'Formulario', 'Acción', 'Layout', 'Tema'][category] ?? `Categoría ${category}`;
  }

  protected async loadConfigurationData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const scope = Number(this.configurationScope);
    const moduleCode = scope >= 2 ? this.configurationModuleCode.trim().toLowerCase() : '';
    const userId = scope === 3 ? this.configurationUserId.trim() : '';

    if (scope >= 2 && !moduleCode) {
      this.configurationError = 'Ingresa un código de módulo para scope Módulo o Usuario.';
      this.configurationItems = [];
      return;
    }
    if (scope === 3 && !userId) {
      this.configurationError = 'Ingresa un userId para scope Usuario.';
      this.configurationItems = [];
      return;
    }

    this.configurationLoading = true;
    this.configurationError = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.loadConfigurationScope(scope, moduleCode || undefined, userId || undefined));
      this.configurationItems = response.data ?? [];
    } catch (error: unknown) {
      this.configurationItems = [];
      this.configurationError = error instanceof Error ? error.message : 'No fue posible cargar Configuration API.';
    } finally {
      this.configurationLoading = false;
    }
  }

  protected async loadMenuData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    const moduleCode = this.menuModuleCode.trim().toLowerCase();
    if (!moduleCode) {
      this.menuError = 'Ingresa un código de módulo.';
      this.menuItems = [];
      return;
    }

    this.menuLoading = true;
    this.menuError = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.loadMenu(moduleCode));
      this.menuItems = response.data ?? [];
      if (this.menuItems.length > 0) this.menuDefinitionId = this.menuItems[0].menuId;
    } catch (error: unknown) {
      this.menuItems = [];
      this.menuDefinitionId = '';
      this.menuError = error instanceof Error ? error.message : 'No fue posible cargar Menu API.';
    } finally {
      this.menuLoading = false;
    }
  }

  protected async createMenuDefinition(): Promise<void> {
    const moduleCode = this.menuModuleCode.trim().toLowerCase();
    const name = this.menuDefinitionName.trim();
    if (!moduleCode || !name) {
      this.menuError = 'Código de módulo y nombre del menú son obligatorios.';
      return;
    }
    this.menuSaving = true;
    this.menuError = undefined;
    this.menuSuccess = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.createMenu(moduleCode, name));
      this.menuDefinitionId = response.data;
      this.menuSuccess = `Menú ${name} creado para ${moduleCode}.`;
      this.beginCreateMenuItem();
    } catch (error: unknown) {
      this.menuError = error instanceof Error ? error.message : 'No fue posible crear la definición de menú.';
    } finally {
      this.menuSaving = false;
    }
  }

  protected beginCreateMenuItem(): void {
    this.menuItemMode = 'create';
    this.menuEditingItemId = undefined;
    this.menuItemCode = '';
    this.menuItemLabel = '';
    this.menuItemRoute = '';
    this.menuItemIcon = '';
    this.menuItemOrder = this.menuItems.length;
    this.menuItemParentId = '';
    this.menuItemResourceKey = '';
    this.menuItemPermissionCode = '';
    this.menuItemMetadataJson = '';
    this.menuError = undefined;
  }

  protected beginEditMenuItem(item: MenuItem): void {
    this.menuItemMode = 'edit';
    this.menuEditingItemId = item.id;
    this.menuDefinitionId = item.menuId;
    this.menuItemCode = item.code;
    this.menuItemLabel = item.label;
    this.menuItemRoute = item.route;
    this.menuItemIcon = item.icon ?? '';
    this.menuItemOrder = item.order;
    this.menuItemParentId = item.parentId ?? '';
    this.menuItemResourceKey = item.resourceKey;
    this.menuItemPermissionCode = item.permissionCode;
    this.menuItemMetadataJson = item.metadataJson ?? '';
    this.menuError = undefined;
  }

  protected async saveMenuItem(): Promise<void> {
    if (!this.menuDefinitionId) {
      this.menuError = 'Primero consulta un módulo existente o crea la definición del menú.';
      return;
    }
    const code = this.menuItemCode.trim().toLowerCase();
    const label = this.menuItemLabel.trim();
    const route = this.menuItemRoute.trim();
    const resourceKey = this.menuItemResourceKey.trim().toLowerCase();
    const permissionCode = this.menuItemPermissionCode.trim().toLowerCase();
    const metadataJson = this.menuItemMetadataJson.trim() || null;
    if (!code || !label || !route || !resourceKey || !permissionCode) {
      this.menuError = 'Código, etiqueta, ruta, recurso y permiso son obligatorios.';
      return;
    }
    if (metadataJson) {
      try { JSON.parse(metadataJson); } catch {
        this.menuError = 'MetadataJson debe contener JSON válido.';
        return;
      }
    }

    this.menuSaving = true;
    this.menuError = undefined;
    this.menuSuccess = undefined;
    try {
      if (this.menuItemMode === 'create') {
        const request: CreateMenuItem = {
          menuId: this.menuDefinitionId,
          parentId: this.menuItemParentId || null,
          code,
          label,
          route,
          icon: this.menuItemIcon.trim() || null,
          order: Number(this.menuItemOrder) || 0,
          resourceKey,
          permissionCode,
          metadataJson
        };
        const response = await firstValueFrom(this.portalApi.createMenuItem(request));
        this.menuSuccess = `Elemento ${response.data.label} creado.`;
      } else if (this.menuEditingItemId) {
        const request: UpdateMenuItem = {
          label,
          route,
          icon: this.menuItemIcon.trim() || null,
          resourceKey,
          permissionCode,
          metadataJson
        };
        const response = await firstValueFrom(this.portalApi.updateMenuItem(this.menuEditingItemId, request));
        await firstValueFrom(this.portalApi.reorderMenuItems([{
          itemId: response.data.id,
          parentId: this.menuItemParentId || null,
          order: Number(this.menuItemOrder) || 0
        }]));
        this.menuSuccess = `Elemento ${response.data.label} actualizado.`;
      }
      this.invalidateGovernedApplicationMenu(this.menuModuleCode);
      await this.loadMenuData();
      this.beginCreateMenuItem();
    } catch (error: unknown) {
      this.menuError = error instanceof Error ? error.message : 'No fue posible guardar el elemento de menú.';
    } finally {
      this.menuSaving = false;
    }
  }

  protected async toggleMenuItem(item: MenuItem): Promise<void> {
    this.menuSaving = true;
    this.menuError = undefined;
    this.menuSuccess = undefined;
    try {
      const response = await firstValueFrom(this.portalApi.setMenuItemActive(item.id, !item.isActive));
      this.menuSuccess = `${response.data.label} quedó ${response.data.isActive ? 'activo' : 'inactivo'}.`;
      this.invalidateGovernedApplicationMenu(this.menuModuleCode);
      await this.loadMenuData();
    } catch (error: unknown) {
      this.menuError = error instanceof Error ? error.message : 'No fue posible cambiar el estado del elemento.';
    } finally {
      this.menuSaving = false;
    }
  }

  protected async loadSecurityData(): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;
    this.securityLoading = true;
    this.securityError = undefined;

    try {
      const [users, roles, permissions, resources] = await Promise.all([
        firstValueFrom(this.portalApi.loadUsers()),
        firstValueFrom(this.portalApi.loadRoles()),
        firstValueFrom(this.portalApi.loadPermissions()),
        firstValueFrom(this.portalApi.loadResources())
      ]);
      this.securityUsers = users;
      this.securityRoles = roles;
      this.securityPermissions = permissions;
      this.securityResources = resources;
    } catch (error: unknown) {
      this.securityError = error instanceof Error ? error.message : 'No fue posible cargar Security API.';
    } finally {
      this.securityLoading = false;
    }
  }

  protected probeResult(module: ShellModule): ModuleProbeResult {
    return this.moduleProbeResults.get(module.label) ?? { state: 'idle' };
  }

  protected probeCount(state: ModuleProbeState): number {
    return this.modules.filter((module) => this.probeResult(module).state === state).length;
  }

  protected async openApplication(application: ApplicationCard): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) {
      await this.connectLocalSession();
      if (!this.portalApi.hasAuthenticatedSession()) return;
    }

    await this.loadGovernedApplicationMenu(application);

    this.workspaceApplication = application;
    this.sidebarCollapsed = true;
    this.workspaceMenuItem = this.visibleApplicationMenu(application)[0] ?? application.menuItems[0];
    this.workspaceUrl = undefined;
    this.workspaceProbeState = 'checking';
    this.workspaceProbeStatus = undefined;
    this.resetWorkspaceData();
    this.activeSection = 'applications';

    this.publishPortalShellContext(application);
    this.updateWorkspaceUrl(application, this.workspaceMenuItem);

    const module = this.modules.find(candidate => candidate.gatewayPath === application.path);
    if (module) {
      const result = await this.probeModule(module);
      this.workspaceProbeState = result.state;
      this.workspaceProbeStatus = result.status;
    } else {
      this.workspaceProbeState = 'unavailable';
    }

    if (application.uiMode === 'native') {
      await this.refreshWorkspaceData();
    }
  }

  protected visibleApplicationMenu(application: ApplicationCard): ApplicationMenuItem[] {
    const source = this.governedApplicationMenus.get(application.code) ?? application.menuItems;
    return source.filter(item => this.permissionGranted(item.permission));
  }

  private async loadGovernedApplicationMenu(application: ApplicationCard): Promise<void> {
    if (!this.portalApi.hasAuthenticatedSession()) return;

    try {
      const response = await firstValueFrom(this.portalApi.loadMenu(application.moduleCode));
      const governedItems = (response.data ?? [])
        .filter(item => item.isActive)
        .map(item => this.toApplicationMenuItem(application, item))
        .filter((item): item is ApplicationMenuItem => item !== undefined)
        .sort((a, b) => a.order - b.order);

      if (governedItems.length > 0) {
        this.governedApplicationMenus.set(application.code, governedItems);
      } else {
        this.governedApplicationMenus.delete(application.code);
      }
    } catch {
      this.governedApplicationMenus.delete(application.code);
    }
  }

  private toApplicationMenuItem(application: ApplicationCard, item: MenuItem): ApplicationMenuItem | undefined {
    const permission = item.permissionCode?.trim() || application.accessPermission;
    const route = item.route?.trim() ?? '';
    const metadata = this.parseMenuMetadata(item.metadataJson);

    if (application.uiMode === 'native') {
      const fallback = application.menuItems.find(candidate =>
        candidate.label.toLowerCase() === item.label.toLowerCase() ||
        candidate.route === route ||
        candidate.dataPath === route
      );
      const dataPath = typeof metadata?.['dataPath'] === 'string'
        ? String(metadata['dataPath']).trim()
        : route.startsWith('/api/')
          ? route
          : fallback?.dataPath;

      if (!dataPath) return undefined;
      return {
        label: item.label,
        dataPath,
        permission,
        order: item.order
      };
    }

    let normalizedRoute = route;
    const webPath = application.webPath ?? '';
    if (webPath && normalizedRoute.startsWith(webPath)) {
      normalizedRoute = normalizedRoute.slice(webPath.length);
    }
    normalizedRoute = normalizedRoute.replace(/^\/+/, '');

    return {
      label: item.label,
      route: normalizedRoute,
      permission,
      order: item.order
    };
  }

  private parseMenuMetadata(metadataJson?: string | null): Record<string, unknown> | undefined {
    if (!metadataJson?.trim()) return undefined;
    try {
      const parsed = JSON.parse(metadataJson);
      return this.isRecord(parsed) ? parsed : undefined;
    } catch {
      return undefined;
    }
  }

  protected async selectWorkspaceMenuItem(item: ApplicationMenuItem): Promise<void> {
    const application = this.workspaceApplication;
    if (!application || !this.permissionGranted(item.permission)) return;

    this.workspaceMenuItem = item;
    this.resetWorkspaceData();
    if (application.uiMode === 'iframe') {
      this.updateWorkspaceUrl(application, item);
      return;
    }

    await this.refreshWorkspaceData();
  }

  protected async refreshWorkspaceData(): Promise<void> {
    const application = this.workspaceApplication;
    if (!application || !this.portalApi.hasAuthenticatedSession() || this.workspaceDataLoading) return;

    const dataPath = this.workspaceMenuItem?.dataPath ?? application.dataPath;
    this.workspaceDataLoading = true;
    this.workspaceDataError = undefined;
    try {
      const data = await firstValueFrom(this.portalApi.loadApplicationSurface(dataPath));
      this.workspaceDataText = JSON.stringify(data, null, 2) ?? String(data);
      this.updateWorkspaceStructuredData(data);
    } catch (error: unknown) {
      this.resetWorkspaceData();
      this.workspaceDataError = error instanceof Error
        ? error.message
        : `No fue posible cargar ${dataPath}.`;
    } finally {
      this.workspaceDataLoading = false;
    }
  }

  protected isHrWorkspace(): boolean {
    return this.workspaceApplication?.code === 'HR';
  }

  protected hrActiveEmployees(): number {
    return this.workspaceDataRows.filter(row => row['isActive'] === true).length;
  }

  protected hrDepartmentCount(): number {
    return new Set(
      this.workspaceDataRows
        .map(row => String(row['department'] ?? '').trim())
        .filter(Boolean)
    ).size;
  }

  protected async createHrEmployee(): Promise<void> {
    if (!this.isHrWorkspace() || this.hrSaving) return;

    const createRequest: CreateHrEmployee = {
      employeeCode: this.hrEmployeeCode.trim(),
      fullName: this.hrFullName.trim(),
      email: this.hrEmail.trim().toLowerCase(),
      position: this.hrPosition.trim(),
      department: this.hrDepartment.trim()
    };

    if ((!this.hrEditingId && !createRequest.employeeCode) || !createRequest.fullName || !createRequest.email || !createRequest.position || !createRequest.department) {
      this.workspaceDataError = 'Completa código, nombre, email, cargo y departamento.';
      return;
    }

    this.hrSaving = true;
    this.hrSuccess = undefined;
    this.workspaceDataError = undefined;
    try {
      if (this.hrEditingId) {
        const request: UpdateHrEmployee = {
          fullName: createRequest.fullName,
          email: createRequest.email,
          position: createRequest.position,
          department: createRequest.department
        };
        const updated = await firstValueFrom(this.portalApi.updateHrEmployee(this.hrEditingId, request));
        this.hrSuccess = `Empleado ${updated.fullName} actualizado correctamente.`;
      } else {
        const created = await firstValueFrom(this.portalApi.createHrEmployee(createRequest));
        this.hrSuccess = `Empleado ${created.fullName} creado correctamente.`;
      }
      this.resetHrEmployeeForm();
      await this.refreshWorkspaceData();
    } catch (error: unknown) {
      this.workspaceDataError = error instanceof Error ? error.message : 'No fue posible guardar el empleado.';
    } finally {
      this.hrSaving = false;
    }
  }

  protected beginEditHrEmployee(row: Record<string, unknown>): void {
    this.hrEditingId = String(row['id'] ?? '');
    this.hrEmployeeCode = String(row['employeeCode'] ?? '');
    this.hrFullName = String(row['fullName'] ?? '');
    this.hrEmail = String(row['email'] ?? '');
    this.hrPosition = String(row['position'] ?? '');
    this.hrDepartment = String(row['department'] ?? '');
    this.hrSuccess = undefined;
    this.workspaceDataError = undefined;
  }

  protected cancelHrEmployeeEdit(): void {
    this.resetHrEmployeeForm();
  }

  protected async toggleHrEmployeeActive(row: Record<string, unknown>): Promise<void> {
    if (this.hrSaving) return;
    const id = String(row['id'] ?? '');
    if (!id) return;
    const active = row['isActive'] !== true;
    this.hrSaving = true;
    this.hrSuccess = undefined;
    this.workspaceDataError = undefined;
    try {
      const updated = await firstValueFrom(this.portalApi.setHrEmployeeActive(id, active));
      this.hrSuccess = `${updated.fullName}: ${updated.isActive ? 'activo' : 'inactivo'}.`;
      await this.refreshWorkspaceData();
    } catch (error: unknown) {
      this.workspaceDataError = error instanceof Error ? error.message : 'No fue posible cambiar el estado del empleado.';
    } finally {
      this.hrSaving = false;
    }
  }

  private resetHrEmployeeForm(): void {
    this.hrEditingId = undefined;
    this.hrEmployeeCode = '';
    this.hrFullName = '';
    this.hrEmail = '';
    this.hrPosition = '';
    this.hrDepartment = '';
  }

  protected formatWorkspaceCell(value: unknown): string {
    if (value === null || value === undefined) return '—';
    if (typeof value === 'object') return JSON.stringify(value);
    return String(value);
  }

  private updateWorkspaceUrl(application: ApplicationCard, item?: ApplicationMenuItem): void {
    if (application.uiMode !== 'iframe' || !application.webPath) {
      this.workspaceUrl = undefined;
      return;
    }

    const route = item?.route?.replace(/^\/+/, '') ?? '';
    const target = new URL(`${application.webPath}${route}`, window.location.origin).toString();
    this.workspaceUrl = this.sanitizer.bypassSecurityTrustResourceUrl(target);
  }

  private updateWorkspaceStructuredData(data: unknown): void {
    const collection = Array.isArray(data)
      ? data
      : this.isRecord(data) && Array.isArray(data['data'])
        ? data['data']
        : [];

    this.workspaceDataRows = collection.filter((item): item is Record<string, unknown> => this.isRecord(item));
    this.workspaceDataColumns = this.workspaceDataRows.length > 0
      ? Object.keys(this.workspaceDataRows[0]).slice(0, 6)
      : [];
  }

  private resetWorkspaceData(): void {
    this.workspaceDataText = '';
    this.workspaceDataRows = [];
    this.workspaceDataColumns = [];
    this.workspaceDataError = undefined;
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
  }

  protected manageApplicationSecurity(application?: ApplicationCard): void {
    this.securityApplication = application;
    if (application) {
      const permissionParts = application.accessPermission.split('.');
      if (permissionParts.at(-1) === '*') {
        this.securityCheckResourceKey = permissionParts.slice(0, -1).join('.');
        this.securityCheckAction = '*';
      } else {
        this.securityCheckResourceKey = permissionParts.slice(0, -1).join('.');
        this.securityCheckAction = permissionParts.at(-1) ?? '';
      }
      this.activeSecurityTab = 'permissions';
    }
    this.selectSection('security');
  }

  protected applicationAuthorized(application: ApplicationCard): boolean {
    return this.permissionGranted(application.accessPermission);
  }

  private permissionGranted(requiredPermission: string): boolean {
    const permissions = this.localAdminSession?.permissions ?? [];
    return permissions.some(permission =>
      permission === requiredPermission ||
      (permission.endsWith('.*') && requiredPermission.startsWith(permission.slice(0, -1)))
    );
  }

  private publishPortalShellContext(application: ApplicationCard): void {
    const session = this.localAdminSession;
    if (!session || typeof window === 'undefined') return;

    const menuItems = this.visibleApplicationMenu(application).map(item => ({
      route: item.route ? `/${item.route.replace(/^\/+/, '')}` : '/',
      title: item.label,
      permission: item.permission,
      order: item.order,
      foundationOnly: true,
      readOnly: true
    }));

    const shellContext = {
      contractVersion: '1.0',
      source: 'portal',
      issuedAt: new Date().toISOString(),
      expiresAt: session.expiresAtUtc,
      capabilities: [`${application.moduleCode}.portal-embedded`, 'portal.security', 'portal.menu'],
      warnings: [],
      user: {
        userId: session.user,
        displayName: session.displayName,
        roles: [session.role]
      },
      tenant: {
        tenantId: session.tenantId,
        tenantName: session.tenantId
      },
      permissions: {
        permissions: Array.from(new Set([
          ...session.permissions,
          ...menuItems.map(item => item.permission)
        ])),
        roles: [session.role]
      },
      menu: { items: menuItems },
      notifications: {
        channels: ['portal'],
        delegatedToPortal: true
      },
      correlation: {
        correlationId: globalThis.crypto?.randomUUID?.() ?? `portal-${Date.now()}`
      },
      environment: {
        apiBaseUrl: '/api',
        shellMode: 'portal-integrated',
        production: true
      },
      featureFlags: {
        showAtsXmlReadiness: true,
        showExternalApprovals: true,
        showPurchases: true,
        showVoidedDocuments: true,
        allowDevHeaders: false,
        allowPurchaseCommands: false,
        allowVoidedDocumentCommands: false,
        allowExternalApprovalCommands: false,
        allowEvidenceReferenceMetadata: false,
        allowApprovalDecisionFoundation: false,
        allowPortalContentFileEvidenceReferences: false,
        allowPortalNotificationIntents: false,
        allowNotificationSend: false,
        allowEvidenceUpload: false,
        allowProductizationReadiness: true,
        allowProductiveActivation: false,
        allowOfficialTaxFlows: false,
        allowAtsOfficialActions: false,
        allowSriSubmission: false,
        allowXmlPreviewUi: false,
        allowMutations: false
      },
      delegatedAuthToken: session.accessToken
    };

    (window as unknown as { __PORTAL_SHELL_CONTEXT__?: unknown }).__PORTAL_SHELL_CONTEXT__ = shellContext;
  }

  private clearPortalShellContext(): void {
    if (typeof window === 'undefined') return;
    delete (window as unknown as { __PORTAL_SHELL_CONTEXT__?: unknown }).__PORTAL_SHELL_CONTEXT__;
  }

  protected applicationIntegrationLabel(application: ApplicationCard): string {
    return application.uiMode === 'iframe' ? 'Aplicación embebida' : 'Vista integrada Portal';
  }

  protected manageApplicationMenu(application: ApplicationCard): void {
    this.menuModuleCode = application.moduleCode;
    this.selectSection('menus');
  }

  private invalidateGovernedApplicationMenu(moduleCode: string): void {
    const application = this.applications.find(candidate => candidate.moduleCode === moduleCode.trim().toLowerCase());
    if (application) this.governedApplicationMenus.delete(application.code);
  }

  protected manageApplicationConfiguration(application: ApplicationCard): void {
    this.configurationScope = 2;
    this.configurationModuleCode = application.moduleCode;
    this.selectSection('configuration');
  }

  protected closeWorkspace(): void {
    this.workspaceApplication = undefined;
    this.workspaceMenuItem = undefined;
    this.workspaceUrl = undefined;
    this.clearPortalShellContext();
    this.workspaceProbeState = 'idle';
    this.workspaceProbeStatus = undefined;
    this.resetWorkspaceData();
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
      const response = await firstValueFrom(this.portalApi.probe(module.probePath));
      const result: ModuleProbeResult = {
        state: response.ok ? 'available' : 'unavailable',
        status: response.status,
        checkedAt: new Date()
      };
      this.moduleProbeResults.set(module.label, result);
      return result;
    } catch (error: unknown) {
      const status = typeof error === 'object' && error !== null && 'status' in error
        ? Number((error as { status?: number }).status)
        : undefined;
      const result: ModuleProbeResult = {
        state: status === 401 || status === 403 ? 'protected' : 'unavailable',
        status,
        checkedAt: new Date()
      };
      this.moduleProbeResults.set(module.label, result);
      return result;
    }
  }
}