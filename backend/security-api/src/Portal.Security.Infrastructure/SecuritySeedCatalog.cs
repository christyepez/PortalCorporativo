namespace Portal.Security.Infrastructure;

internal static class SecuritySeedCatalog
{
    internal static readonly Guid SuperAdminRoleId = Guid.Parse("10000000-0000-0000-0000-000000000001");
    internal static readonly Guid PortalAdminRoleId = Guid.Parse("10000000-0000-0000-0000-000000000002");

    internal sealed record ResourceDefinition(Guid Id, string Key, string Name);
    internal sealed record PermissionDefinition(Guid Id, string Code, string ResourceKey, string Action, bool GrantToPortalAdmin);

    internal static readonly ResourceDefinition[] Resources =
    [
        new(Guid.Parse("20000000-0000-0000-0000-000000000001"), "portal.security", "Portal Security"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000002"), "portal.menu", "Portal Menu"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000003"), "portal.configuration", "Portal Configuration"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000004"), "portal.audit", "Portal Audit"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000005"), "portal.notification", "Portal Notification"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000006"), "crm", "CRM"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000007"), "financial", "Financiero"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000008"), "hr.employees", "Talento Humano - Empleados"),
        new(Guid.Parse("20000000-0000-0000-0000-000000000009"), "historiaspaolin.channels", "HistoriasPaolin - Canales")
    ];

    internal static readonly PermissionDefinition[] Permissions =
    [
        new(Guid.Parse("30000000-0000-0000-0000-000000000001"), "portal.security.manage", "portal.security", "manage", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000002"), "portal.menu.manage", "portal.menu", "manage", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000003"), "portal.configuration.manage", "portal.configuration", "manage", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000004"), "portal.audit.read", "portal.audit", "read", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000005"), "portal.notification.manage", "portal.notification", "manage", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000006"), "portal.notification.send", "portal.notification", "send", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000007"), "portal.notification.read", "portal.notification", "read", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000008"), "portal.configuration.read", "portal.configuration", "read", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000009"), "portal.menu.read", "portal.menu", "read", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000010"), "portal.audit.write", "portal.audit", "write", true),
        new(Guid.Parse("30000000-0000-0000-0000-000000000011"), "crm.*", "crm", "*", false),
        new(Guid.Parse("30000000-0000-0000-0000-000000000012"), "financial.*", "financial", "*", false),
        new(Guid.Parse("30000000-0000-0000-0000-000000000013"), "hr.employees.view", "hr.employees", "view", false),
        new(Guid.Parse("30000000-0000-0000-0000-000000000014"), "hr.employees.manage", "hr.employees", "manage", false),
        new(Guid.Parse("30000000-0000-0000-0000-000000000015"), "historiaspaolin.channels.view", "historiaspaolin.channels", "view", false)
    ];
}
