# CRM Controlled Consumer Runtime Pilot Checklist

## Entry checklist

- CRM repository status is clean and based on the approved frozen or successor base.
- CRM Common DB Controlled Activation Plan is approved.
- CRM Portal Consumer Contract Alignment is approved.
- CRM module metadata is reviewed by Portal.
- CRM navigation contract is reviewed by Portal.
- CRM permissions and claims contract is reviewed by Portal Security.
- CRM audit, configuration and notification usage is reviewed.
- CRM health endpoint contract is reviewed.
- CRM deployment owner and rollback owner are identified.

## Portal checklist

- Portal NonProduction package remains healthy.
- Local Seq observability remains available.
- Gateway routes remain disabled until the activation gate.
- External navigation remains disabled until the activation gate.
- Shared database boundaries remain intact.
