using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Portal.Security.Domain;

namespace Portal.Security.Infrastructure;

internal sealed class SecurityDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<SecurityDbContext>();

        await dbContext.Database.EnsureCreatedAsync(cancellationToken);
        await BootstrapGovernedSecurityAsync(dbContext, cancellationToken);
    }

    private static async Task BootstrapGovernedSecurityAsync(SecurityDbContext dbContext, CancellationToken cancellationToken)
    {
        var existingResourceKeys = await dbContext.Resources
            .AsNoTracking()
            .Where(resource => resource.TenantId == TenantIds.Default)
            .Select(resource => resource.Key)
            .ToHashSetAsync(cancellationToken);

        foreach (var definition in SecuritySeedCatalog.Resources)
        {
            if (!existingResourceKeys.Contains(definition.Key))
            {
                dbContext.Resources.Add(Resource.Seed(definition.Id, TenantIds.Default, definition.Key, definition.Name));
            }
        }

        var existingPermissionCodes = await dbContext.Permissions
            .AsNoTracking()
            .Where(permission => permission.TenantId == TenantIds.Default)
            .Select(permission => permission.Code)
            .ToHashSetAsync(cancellationToken);

        foreach (var definition in SecuritySeedCatalog.Permissions)
        {
            if (!existingPermissionCodes.Contains(definition.Code))
            {
                dbContext.Permissions.Add(Permission.Seed(
                    definition.Id,
                    TenantIds.Default,
                    definition.Code,
                    definition.ResourceKey,
                    definition.Action));
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        var permissionIdsByCode = await dbContext.Permissions
            .AsNoTracking()
            .Where(permission => permission.TenantId == TenantIds.Default)
            .ToDictionaryAsync(permission => permission.Code, permission => permission.Id, cancellationToken);

        var existingAssignments = await dbContext.RolePermissions
            .AsNoTracking()
            .Where(assignment =>
                assignment.TenantId == TenantIds.Default &&
                (assignment.RoleId == SecuritySeedCatalog.SuperAdminRoleId ||
                 assignment.RoleId == SecuritySeedCatalog.PortalAdminRoleId))
            .Select(assignment => new { assignment.RoleId, assignment.PermissionId })
            .ToListAsync(cancellationToken);

        var assignmentKeys = existingAssignments
            .Select(assignment => (assignment.RoleId, assignment.PermissionId))
            .ToHashSet();

        foreach (var definition in SecuritySeedCatalog.Permissions)
        {
            if (!permissionIdsByCode.TryGetValue(definition.Code, out var permissionId))
            {
                throw new InvalidOperationException($"Security permission bootstrap failed for '{definition.Code}'.");
            }

            var superAdminKey = (SecuritySeedCatalog.SuperAdminRoleId, permissionId);
            if (!assignmentKeys.Contains(superAdminKey))
            {
                dbContext.RolePermissions.Add(RolePermission.Seed(
                    TenantIds.Default,
                    SecuritySeedCatalog.SuperAdminRoleId,
                    permissionId));
                assignmentKeys.Add(superAdminKey);
            }

            if (definition.GrantToPortalAdmin)
            {
                var portalAdminKey = (SecuritySeedCatalog.PortalAdminRoleId, permissionId);
                if (!assignmentKeys.Contains(portalAdminKey))
                {
                    dbContext.RolePermissions.Add(RolePermission.Seed(
                        TenantIds.Default,
                        SecuritySeedCatalog.PortalAdminRoleId,
                        permissionId));
                    assignmentKeys.Add(portalAdminKey);
                }
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
