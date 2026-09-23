# Mapa de dependencias

## Camino crítico

```text
SQL común + Secret Provider
            ↓
Gateway health/readiness
            ↓
Entra ID + Portal context + permissions
            ↓
Portal Shell + menú
            ↓
E2E transversal
       ↙          ↘
CRM productivo   Financiero E2E
```

## Dependencias por dominio

| Dominio | Puede avanzar ahora | Dependencias bloqueantes |
|---|---|---|
| Portal | Runtime, Shell, Auth, servicios compartidos | Infraestructura y configuración de ambiente |
| CRM | Modelo, pruebas, primera ruta vertical preparada | SQL, Secret Provider, Auth, Gateway, Shell |
| Financiero | Reglas, pruebas, SRI foundation, hardening | SQL, Gateway, Shell, contexto, correlación |
| Talento Humano | HR Core | Content/File, Workflow, Task Inbox para fases posteriores |
| CodexCommonAgents | Orquestación, quality gates, contratos | Acceso y convenciones de repositorios |

## Dependencias compartidas

| Capacidad | CRM | Financiero | TTHH | Prioridad |
|---|:---:|:---:|:---:|---:|
| SQL/Secret Provider | X | X | X | P1 |
| Gateway/Auth/Context | X | X | X | P1 |
| Portal Shell/Menu | X | X | X | P1 |
| Content/File | X | X | X | P1 |
| Catalog | X | X | X | P2 |
| Notification | X | X | X | P2 |
| Workflow/Task Inbox | X | X | X | P2 |
| Reporting/Exports | X | X | X | P3 |

## Política de dependencias

- El proveedor publica contrato, versión, health y evidencia.
- El consumidor usa adaptador; nunca accede a la base del proveedor.
- Todo bloqueo incluye owner, fecha objetivo, workaround permitido y criterio de desbloqueo.
- Las dependencias se revisan dos veces por semana durante PI-1.
