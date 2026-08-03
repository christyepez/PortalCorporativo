# Portal Controlled NonProduction Service Port Matrix

| Service | Internal port | Default host port | Source |
| --- | ---: | ---: | --- |
| api-gateway | 8080 | 8082 | `API_GATEWAY_PORT` |
| sqlserver | 1433 | 21433 | `SQLSERVER_PORT` |
| redis | 6379 | 6380 | `REDIS_PORT` |
| seq | 80 | 5342 | `SEQ_PORT` |
| minio api | 9000 | 9002 | `MINIO_API_PORT` |
| minio console | 9001 | 9003 | `MINIO_CONSOLE_PORT` |
| security-api | 8080 | internal only | Docker network |
| configuration-api | 8080 | internal only | Docker network |
| menu-api | 8080 | internal only | Docker network |
| audit-api | 8080 | internal only | Docker network |
| notification-api | 8080 | internal only | Docker network |
| catalog-api | 8080 | internal only | Docker network |
| content-api | 8080 | internal only | Docker network |
| integration-api | 8080 | internal only | Docker network |
| reporting-api | 8080 | internal only | Docker network |
| notification-worker | 8080 | internal only | Docker network |
| integration-worker | 8080 | internal only | Docker network |

CRM and Financiero services are not part of this Compose runtime.
