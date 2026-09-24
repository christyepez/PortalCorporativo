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

  loadMenu(): Observable<unknown> {
    return this.http.get(`${environment.apiBasePath}/menu`, { headers: this.headers() });
  }

  loadConfiguration(key: string, moduleCode?: string): Observable<unknown> {
    const params = new URLSearchParams({ key });
    if (moduleCode) params.set('moduleCode', moduleCode);
    return this.http.get(`${environment.apiBasePath}/configuration/effective?${params.toString()}`, { headers: this.headers() });
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
