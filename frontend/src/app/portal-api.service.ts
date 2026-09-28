import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface SecurityUser {
  readonly id: string;
  readonly tenantId: string;
  readonly email: string;
  readonly name: string;
  readonly isActive: boolean;
}

export interface SecurityRole {
  readonly id: string;
  readonly tenantId: string;
  readonly name: string;
}

export interface SecurityPermission {
  readonly id: string;
  readonly tenantId: string;
  readonly code: string;
  readonly resourceKey: string;
  readonly action: string;
}

export interface SecurityResource {
  readonly id: string;
  readonly tenantId: string;
  readonly key: string;
  readonly name: string;
}

export interface MenuItem {
  readonly id: string;
  readonly menuId: string;
  readonly parentId?: string | null;
  readonly code: string;
  readonly label: string;
  readonly route: string;
  readonly icon?: string | null;
  readonly order: number;
  readonly resourceKey: string;
  readonly permissionCode: string;
  readonly metadataJson?: string | null;
}

export interface ConfigurationItem {
  readonly id: string;
  readonly key: string;
  readonly scope: number;
  readonly tenantId: string;
  readonly moduleCode?: string | null;
  readonly userId?: string | null;
  readonly category: number;
  readonly valueJson: string;
  readonly version: number;
  readonly isActive: boolean;
}

export interface CreateConfigurationItem {
  readonly key: string;
  readonly scope: number;
  readonly moduleCode?: string | null;
  readonly userId?: string | null;
  readonly category: number;
  readonly valueJson: string;
}

export interface UpdateConfigurationItem {
  readonly category: number;
  readonly valueJson: string;
}

export interface CatalogEntry {
  readonly id: string;
  readonly catalog: string;
  readonly code: string;
  readonly name: string;
  readonly description?: string | null;
  readonly isActive: boolean;
  readonly sortOrder: number;
  readonly createdAt: string;
  readonly updatedAt: string;
}

export interface CreateCatalogEntry {
  readonly catalog: string;
  readonly code: string;
  readonly name: string;
  readonly description?: string | null;
  readonly sortOrder: number;
}

export interface UpdateCatalogEntry {
  readonly name: string;
  readonly description?: string | null;
  readonly isActive: boolean;
  readonly sortOrder: number;
}

export interface ContentDocument {
  readonly id: string;
  readonly moduleCode: string;
  readonly fileName: string;
  readonly contentType: string;
  readonly length: number;
  readonly sha256: string;
  readonly isActive: boolean;
  readonly createdAt: string;
}

export interface AuditEvent {
  readonly id: string;
  readonly actorId: string;
  readonly tenantId: string;
  readonly resource: string;
  readonly action: string;
  readonly entityName: string;
  readonly entityId?: string | null;
  readonly correlationId: string;
  readonly severity: number;
  readonly createdAtUtc: string;
}

export interface AuditPage {
  readonly items: AuditEvent[];
  readonly page: number;
  readonly pageSize: number;
  readonly total: number;
}

export interface AuditMetric {
  readonly key: string;
  readonly count: number;
}

export interface AuditSummary {
  readonly tenantId: string;
  readonly fromUtc: string;
  readonly toUtc: string;
  readonly total: number;
  readonly warningOrHigher: number;
  readonly errorOrHigher: number;
  readonly topResources: AuditMetric[];
  readonly topActions: AuditMetric[];
}

export interface ReportDefinition {
  readonly key: string;
  readonly name: string;
  readonly description: string;
  readonly moduleCode: string;
  readonly requiredParameters: string[];
}

export interface ReportExecution {
  readonly key: string;
  readonly generatedAt: string;
  readonly rows: Record<string, unknown>[];
  readonly sourceMode: string;
}

export interface NotificationTemplate {
  readonly id: string;
  readonly code: string;
  readonly subject: string;
  readonly body: string;
  readonly allowedVariables: string[];
  readonly defaultChannel: number;
  readonly version: number;
  readonly isActive: boolean;
}

export interface NotificationMessage {
  readonly id: string;
  readonly templateCode: string;
  readonly channel: number;
  readonly status: number;
  readonly attemptCount: number;
  readonly createdAtUtc: string;
  readonly scheduledAtUtc?: string | null;
  readonly sentAtUtc?: string | null;
  readonly failedAtUtc?: string | null;
  readonly lastError?: string | null;
  readonly correlationId: string;
}

export interface OutboxMessageStatus {
  readonly messageId: string;
  readonly tenantId: string;
  readonly eventType: string;
  readonly status: string;
  readonly attempts: number;
  readonly processedAtUtc?: string | null;
  readonly lastError?: string | null;
}

export interface OutboxStatus {
  readonly messageId: string;
  readonly tenantId: string;
  readonly idempotencyKey?: string | null;
  readonly status: string;
  readonly attempts: number;
  readonly createdAtUtc: string;
  readonly processedAtUtc?: string | null;
  readonly nextRetryAtUtc?: string | null;
  readonly lastError?: string | null;
}

export interface InboxProcessedStatus {
  readonly tenantId: string;
  readonly source: string;
  readonly idempotencyKey: string;
  readonly processed: boolean;
}

interface ApiResponse<T> {
  readonly data: T;
  readonly error?: unknown;
  readonly correlationId?: string;
}

@Injectable({ providedIn: 'root' })
export class PortalApiService {
  private accessToken: string | null = null;

  constructor(private readonly http: HttpClient) {}

  setAccessToken(token: string | null): void {
    this.accessToken = token?.trim() || null;
  }

  clearAccessToken(): void {
    this.accessToken = null;
  }

  hasAuthenticatedSession(): boolean {
    return this.accessToken !== null;
  }

  loadUsers(): Observable<SecurityUser[]> {
    return this.http.get<SecurityUser[]>(`${environment.apiBasePath}/security/users`, { headers: this.headers() });
  }

  loadRoles(): Observable<SecurityRole[]> {
    return this.http.get<SecurityRole[]>(`${environment.apiBasePath}/security/roles`, { headers: this.headers() });
  }

  loadPermissions(): Observable<SecurityPermission[]> {
    return this.http.get<SecurityPermission[]>(`${environment.apiBasePath}/security/permissions`, { headers: this.headers() });
  }

  loadResources(): Observable<SecurityResource[]> {
    return this.http.get<SecurityResource[]>(`${environment.apiBasePath}/security/resources`, { headers: this.headers() });
  }

  loadUserPermissions(userId: string): Observable<unknown> {
    return this.http.get(`${environment.apiBasePath}/security/users/${encodeURIComponent(userId)}/permissions`, { headers: this.headers() });
  }

  loadMenu(moduleCode: string): Observable<ApiResponse<MenuItem[]>> {
    return this.http.get<ApiResponse<MenuItem[]>>(`${environment.apiBasePath}/menu/modules/${encodeURIComponent(moduleCode)}`, { headers: this.headers() });
  }

  loadConfiguration(key: string, moduleCode?: string): Observable<unknown> {
    const params = new URLSearchParams({ key });
    if (moduleCode) params.set('moduleCode', moduleCode);
    return this.http.get(`${environment.apiBasePath}/configuration/effective?${params.toString()}`, { headers: this.headers() });
  }

  loadConfigurationScope(scope: number, moduleCode?: string, userId?: string): Observable<ApiResponse<ConfigurationItem[]>> {
    const params = new URLSearchParams();
    if (moduleCode) params.set('moduleCode', moduleCode);
    if (userId) params.set('userId', userId);
    const suffix = params.size ? `?${params.toString()}` : '';
    return this.http.get<ApiResponse<ConfigurationItem[]>>(`${environment.apiBasePath}/configuration/scopes/${scope}${suffix}`, { headers: this.headers() });
  }

  createConfigurationItem(request: CreateConfigurationItem): Observable<ApiResponse<ConfigurationItem>> {
    return this.http.post<ApiResponse<ConfigurationItem>>(`${environment.apiBasePath}/configuration/items`, request, { headers: this.headers() });
  }

  updateConfigurationItem(id: string, request: UpdateConfigurationItem): Observable<ApiResponse<ConfigurationItem>> {
    return this.http.put<ApiResponse<ConfigurationItem>>(`${environment.apiBasePath}/configuration/items/${encodeURIComponent(id)}`, request, { headers: this.headers() });
  }

  setConfigurationActive(id: string, active: boolean): Observable<ApiResponse<ConfigurationItem>> {
    const action = active ? 'activate' : 'deactivate';
    return this.http.post<ApiResponse<ConfigurationItem>>(`${environment.apiBasePath}/configuration/items/${encodeURIComponent(id)}/${action}`, {}, { headers: this.headers() });
  }

  loadCatalog(catalog?: string, isActive?: boolean): Observable<CatalogEntry[]> {
    const params = new URLSearchParams();
    if (catalog) params.set('catalog', catalog);
    if (isActive !== undefined) params.set('isActive', String(isActive));
    const suffix = params.size ? `?${params.toString()}` : '';
    return this.http.get<CatalogEntry[]>(`${environment.apiBasePath}/catalog/entries${suffix}`, { headers: this.headers() });
  }

  createCatalogEntry(request: CreateCatalogEntry): Observable<CatalogEntry> {
    return this.http.post<CatalogEntry>(`${environment.apiBasePath}/catalog/entries`, request, { headers: this.headers() });
  }

  updateCatalogEntry(id: string, request: UpdateCatalogEntry): Observable<CatalogEntry> {
    return this.http.put<CatalogEntry>(`${environment.apiBasePath}/catalog/entries/${encodeURIComponent(id)}`, request, { headers: this.headers() });
  }

  loadContent(moduleCode?: string, isActive?: boolean): Observable<ContentDocument[]> {
    const params = new URLSearchParams();
    if (moduleCode) params.set('moduleCode', moduleCode);
    if (isActive !== undefined) params.set('isActive', String(isActive));
    const suffix = params.size ? `?${params.toString()}` : '';
    return this.http.get<ContentDocument[]>(`${environment.apiBasePath}/content/documents${suffix}`, { headers: this.headers() });
  }

  downloadContent(id: string): Observable<Blob> {
    return this.http.get(`${environment.apiBasePath}/content/documents/${encodeURIComponent(id)}/download`, {
      headers: this.headers(),
      responseType: 'blob'
    });
  }

  loadAudit(filters: { resource?: string; action?: string; actorId?: string; severity?: number; correlationId?: string; page?: number; pageSize?: number }): Observable<ApiResponse<AuditPage>> {
    const params = new URLSearchParams();
    if (filters.resource) params.set('resource', filters.resource);
    if (filters.action) params.set('action', filters.action);
    if (filters.actorId) params.set('actorId', filters.actorId);
    if (filters.severity !== undefined) params.set('severity', String(filters.severity));
    if (filters.correlationId) params.set('correlationId', filters.correlationId);
    params.set('page', String(filters.page ?? 1));
    params.set('pageSize', String(filters.pageSize ?? 20));
    return this.http.get<ApiResponse<AuditPage>>(`${environment.apiBasePath}/audit/events/?${params.toString()}`, { headers: this.headers() });
  }

  loadAuditSummary(hours = 24): Observable<ApiResponse<AuditSummary>> {
    return this.http.get<ApiResponse<AuditSummary>>(`${environment.apiBasePath}/audit/events/summary?hours=${encodeURIComponent(hours)}`, { headers: this.headers() });
  }

  loadReports(): Observable<ReportDefinition[]> {
    return this.http.get<ReportDefinition[]>(`${environment.apiBasePath}/reporting/reports`, { headers: this.headers() });
  }

  executeReport(key: string, parameters: Record<string, string>): Observable<ReportExecution> {
    return this.http.post<ReportExecution>(`${environment.apiBasePath}/reporting/reports/${encodeURIComponent(key)}/execute`, { parameters }, { headers: this.headers() });
  }

  loadNotificationTemplates(): Observable<ApiResponse<NotificationTemplate[]>> {
    return this.http.get<ApiResponse<NotificationTemplate[]>>(`${environment.apiBasePath}/notifications/templates`, { headers: this.headers() });
  }

  loadNotificationMessages(): Observable<ApiResponse<NotificationMessage[]>> {
    return this.http.get<ApiResponse<NotificationMessage[]>>(`${environment.apiBasePath}/notifications/`, { headers: this.headers() });
  }

  retryNotification(id: string): Observable<ApiResponse<NotificationMessage>> {
    return this.http.post<ApiResponse<NotificationMessage>>(`${environment.apiBasePath}/notifications/${encodeURIComponent(id)}/retry`, {}, { headers: this.headers() });
  }

  cancelNotification(id: string): Observable<ApiResponse<NotificationMessage>> {
    return this.http.post<ApiResponse<NotificationMessage>>(`${environment.apiBasePath}/notifications/${encodeURIComponent(id)}/cancel`, {}, { headers: this.headers() });
  }

  loadOutboxByMessageId(messageId: string): Observable<OutboxMessageStatus> {
    return this.http.get<OutboxMessageStatus>(`${environment.apiBasePath}/integration/outbox/${encodeURIComponent(messageId)}`, { headers: this.headers() });
  }

  loadOutboxByIdempotencyKey(tenantId: string, idempotencyKey: string): Observable<OutboxStatus> {
    const params = new URLSearchParams({ tenantId, idempotencyKey });
    return this.http.get<OutboxStatus>(`${environment.apiBasePath}/integration/outbox/status?${params.toString()}`, { headers: this.headers() });
  }

  checkInboxProcessed(tenantId: string, source: string, idempotencyKey: string): Observable<InboxProcessedStatus> {
    const params = new URLSearchParams({ tenantId, source, idempotencyKey });
    return this.http.get<InboxProcessedStatus>(`${environment.apiBasePath}/integration/inbox/processed?${params.toString()}`, { headers: this.headers() });
  }

  private headers(): HttpHeaders {
    return this.accessToken ? new HttpHeaders({ Authorization: `Bearer ${this.accessToken}` }) : new HttpHeaders();
  }
}
