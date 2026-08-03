# Portal External Consumer Navigation Contract

## Purpose

Define future navigation metadata for external consumers without enabling productive navigation.

## Contract

- Navigation entries are metadata controlled by Portal Menu.
- Route prefixes are relative placeholders until a route gate approves runtime activation.
- Visibility depends on Portal Security permissions.
- Menu metadata must not include private URLs or secrets.

## Forbidden in Sprint 16

- Productive CRM navigation.
- Productive Financiero navigation.
- External absolute URLs.
- Browser token storage.
- Runtime module shell loading.

## Sprint 16 status

- ProductiveExternalNavigationEnabled: false.
- ExternalModuleRuntimeEnabled: false.
