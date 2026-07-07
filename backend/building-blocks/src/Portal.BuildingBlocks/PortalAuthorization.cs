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

    public static readonly string[] All =
    [
        SecurityManage, ConfigurationManage, ConfigurationRead, MenuManage, MenuRead,
        AuditRead, AuditWrite, NotificationManage, NotificationSend, NotificationRead
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
