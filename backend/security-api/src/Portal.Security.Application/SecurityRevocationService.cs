using Portal.BuildingBlocks;
using Portal.Security.Domain;

namespace Portal.Security.Application;

public interface ISecurityRevocationStore
{
    Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<bool> RemoveUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken);
    Task<bool> RemoveRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken);
}

public sealed class SecurityRevocationService(ISecurityRevocationStore store, IPortalTenantContext tenantContext)
{
    public async Task<Result<bool>> RevokeRoleFromUserAsync(Guid userId, Guid roleId, CancellationToken cancellationToken)
    {
        if (await store.FindUserAsync(tenantContext.TenantId, userId, cancellationToken) is null)
            return Result<bool>.Failure("security.user.not_found", "User was not found.");
        if (await store.FindRoleAsync(tenantContext.TenantId, roleId, cancellationToken) is null)
            return Result<bool>.Failure("security.role.not_found", "Role was not found.");

        var removed = await store.RemoveUserRoleAsync(tenantContext.TenantId, userId, roleId, cancellationToken);
        return removed
            ? Result<bool>.Success(true)
            : Result<bool>.Failure("security.user_role.not_found", "Role assignment was not found.");
    }

    public async Task<Result<bool>> RevokePermissionFromRoleAsync(Guid roleId, Guid permissionId, CancellationToken cancellationToken)
    {
        if (await store.FindRoleAsync(tenantContext.TenantId, roleId, cancellationToken) is null)
            return Result<bool>.Failure("security.role.not_found", "Role was not found.");
        if (await store.FindPermissionAsync(tenantContext.TenantId, permissionId, cancellationToken) is null)
            return Result<bool>.Failure("security.permission.not_found", "Permission was not found.");

        var removed = await store.RemoveRolePermissionAsync(tenantContext.TenantId, roleId, permissionId, cancellationToken);
        return removed
            ? Result<bool>.Success(true)
            : Result<bool>.Failure("security.role_permission.not_found", "Permission assignment was not found.");
    }
}
