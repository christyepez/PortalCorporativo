import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface PortalMenuItem {
  readonly id?: string;
  readonly label?: string;
  readonly title?: string;
  readonly route?: string;
  readonly url?: string;
  readonly children?: readonly PortalMenuItem[];
}

export interface PortalConfigurationItem {
  readonly key?: string;
  readonly value?: string;
  readonly moduleCode?: string;
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
