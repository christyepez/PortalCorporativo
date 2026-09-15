using Microsoft.EntityFrameworkCore;
using Portal.Security.Application;
using Portal.Security.Domain;

namespace Portal.Security.Infrastructure;

public sealed class EfSecurityRevocationStore(SecurityDbContext dbContext) : ISecurityRevocationStore
{
    public Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Users.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Roles.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Permissions.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public async Task<bool> RemoveUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken)
        => await dbContext.UserRoles
            .Where(x => x.TenantId == tenantId && x.UserId == userId && x.RoleId == roleId)
            .ExecuteDeleteAsync(cancellationToken) == 1;

    public async Task<bool> RemoveRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken)
        => await dbContext.RolePermissions
            .Where(x => x.TenantId == tenantId && x.RoleId == roleId && x.PermissionId == permissionId)
            .ExecuteDeleteAsync(cancellationToken) == 1;
}
