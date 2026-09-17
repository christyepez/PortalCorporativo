using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection;

namespace Portal.BuildingBlocks;

public static class PortalPermissions
{
    public const string ClaimType = "permission";
    public const string SecurityManage = "portal.security.manage";
    public const string ConfigurationManage = "portal.configuration.manage";
    public const string ConfigurationRead = "portal.configuration.read";
    public const string MenuManage = "portal.menu.manage";
    public const string MenuRead = "portal.menu.read";
    public const string AuditRead = "portal.audit.read";
    public const string AuditWrite = "portal.audit.write";
    public const string NotificationManage = "portal.notification.manage";
    public const string NotificationSend = "portal.notification.send";
    public const string NotificationRead = "portal.notification.read";
    public const string CatalogManage = "portal.catalog.manage";
    public const string CatalogRead = "portal.catalog.read";
    public const string ContentManage = "portal.content.manage";
    public const string ContentRead = "portal.content.read";
    public const string ReportingRead = "portal.reporting.read";
    public const string IntegrationManage = "portal.integration.manage";
    public const string IntegrationRead = "portal.integration.read";
    public const string HrEmployeesView = "hr.employees.view";
    public const string HrEmployeesManage = "hr.employees.manage";

    public static readonly string[] All =
    [
        SecurityManage, ConfigurationManage, ConfigurationRead, MenuManage, MenuRead,
        AuditRead, AuditWrite, NotificationManage, NotificationSend, NotificationRead,
        CatalogManage, CatalogRead, ContentManage, ContentRead, ReportingRead,
        IntegrationManage, IntegrationRead, HrEmployeesView, HrEmployeesManage
    ];
}

public static class PortalAuthorizationExtensions
{
    public static IServiceCollection AddPortalPermissionAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(options =>
        {
            foreach (var permission in PortalPermissions.All)
                options.AddPolicy(permission, policy => policy.RequireAuthenticatedUser().RequireClaim(PortalPermissions.ClaimType, permission));
        });
        return services;
    }
}
