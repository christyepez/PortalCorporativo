# Portal Operational Incident Triage Runbook

## NonProduction triage sequence

1. Confirm scope is controlled NonProduction.
2. Capture health:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
```

3. Capture logs:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-logs.ps1 -Tail 150
```

4. Identify `CorrelationId`.
5. Review Gateway, API and worker logs for the same correlation.
6. Confirm no production provider or consumer runtime coupling was activated.
7. Stop the stack when validation is complete.

ProductionActivationDecision: NoGo.
