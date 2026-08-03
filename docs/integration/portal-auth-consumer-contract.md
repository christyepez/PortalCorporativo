# Portal Auth Consumer Contract

## Purpose

Define how consumer domains such as CRM and Financiero will consume Portal Auth without duplicating identity or authorization capabilities.

## Consumer rules

- Consumers must not create their own login.
- Consumers must not create their own Security API.
- Consumers must not persist Portal tokens in browser storage.
- Consumers must register resources and permissions through Portal Security.
- Consumers must rely on Portal-issued or Portal-validated identity context.
- Consumers must keep their own domain data in separate logical databases.

## Required consumer context

Future requests from consumers should carry:

- tenant id.
- subject/user id.
- correlation id.
- permission claims or a trusted permission decision reference.

## Not implemented in Sprint 13

- real SSO/OIDC provider.
- consumer production callbacks.
- CRM/Financiero runtime navigation.
- shared consumer database.
