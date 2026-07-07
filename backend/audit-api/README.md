# Audit API

Audit Foundation transversal append-only. Expone `POST /api/audit/events`, búsqueda paginada `GET /api/audit/events`, detalle `GET /api/audit/events/{id}` y `GET /health`.

Los JSON se validan y redactan por claves sensibles. No existen operaciones update/delete. Retención: 365 días en línea; archivo/purga queda para Sprint 2.
