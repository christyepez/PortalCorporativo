using Microsoft.EntityFrameworkCore;
using Portal.Security.Application;
using Portal.Security.Domain;

namespace Portal.Security.Infrastructure;

public sealed class EfSecurityStore(SecurityDbContext dbContext) : ISecurityStore
{
    public Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Users.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public Task<User?> FindUserByEmailAsync(string tenantId, string normalizedEmail, CancellationToken cancellationToken) =>
        dbContext.Users.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.NormalizedEmail == normalizedEmail, cancellationToken);

    public Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Roles.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public Task<Role?> FindRoleByNameAsync(string tenantId, string normalizedName, CancellationToken cancellationToken) =>
        dbContext.Roles.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.NormalizedName == normalizedName, cancellationToken);

    public Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
        dbContext.Permissions.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);

    public Task<Permission?> FindPermissionByCodeAsync(string tenantId, string code, CancellationToken cancellationToken) =>
        dbContext.Permissions.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Code == code, cancellationToken);

    public Task<Permission?> FindPermissionAsync(string tenantId, string resourceKey, string action, CancellationToken cancellationToken) =>
        dbContext.Permissions.SingleOrDefaultAsync(
            x => x.TenantId == tenantId && x.ResourceKey == resourceKey && x.Action == action,
            cancellationToken);

    public Task<Resource?> FindResourceByKeyAsync(string tenantId, string key, CancellationToken cancellationToken) =>
        dbContext.Resources.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Key == key, cancellationToken);

    public Task<bool> HasUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken) =>
        dbContext.UserRoles.AnyAsync(x => x.TenantId == tenantId && x.UserId == userId && x.RoleId == roleId, cancellationToken);

    public Task<bool> HasRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken) =>
        dbContext.RolePermissions.AnyAsync(
            x => x.TenantId == tenantId && x.RoleId == roleId && x.PermissionId == permissionId,
            cancellationToken);

    public Task<bool> UserHasPermissionAsync(string tenantId, Guid userId, Guid permissionId, CancellationToken cancellationToken) =>
        (from userRole in dbContext.UserRoles
         join rolePermission in dbContext.RolePermissions
             on new { userRole.TenantId, userRole.RoleId } equals new { rolePermission.TenantId, rolePermission.RoleId }
         where userRole.TenantId == tenantId && userRole.UserId == userId && rolePermission.PermissionId == permissionId
         select rolePermission).AnyAsync(cancellationToken);

    public async Task<IReadOnlyCollection<Permission>> GetUserPermissionsAsync(string tenantId, Guid userId, CancellationToken cancellationToken) =>
        await (from userRole in dbContext.UserRoles
               join rolePermission in dbContext.RolePermissions
                   on new { userRole.TenantId, userRole.RoleId } equals new { rolePermission.TenantId, rolePermission.RoleId }
               join permission in dbContext.Permissions on rolePermission.PermissionId equals permission.Id
               where userRole.TenantId == tenantId && userRole.UserId == userId
               select permission).Distinct().ToArrayAsync(cancellationToken);

    public Task AddAsync<T>(T entity, CancellationToken cancellationToken) where T : class =>
        dbContext.Set<T>().AddAsync(entity, cancellationToken).AsTask();

    public Task SaveChangesAsync(CancellationToken cancellationToken) => dbContext.SaveChangesAsync(cancellationToken);
}
