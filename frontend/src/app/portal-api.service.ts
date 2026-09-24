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

  loadCatalog(catalog?: string): Observable<unknown> {
    const suffix = catalog ? `?catalog=${encodeURIComponent(catalog)}` : '';
    return this.http.get(`${environment.apiBasePath}/catalog/entries${suffix}`, { headers: this.headers() });
  }

  loadReports(): Observable<unknown> {
    return this.http.get(`${environment.apiBasePath}/reporting/reports`, { headers: this.headers() });
  }

  private headers(): HttpHeaders {
    return this.accessToken ? new HttpHeaders({ Authorization: `Bearer ${this.accessToken}` }) : new HttpHeaders();
  }
}
