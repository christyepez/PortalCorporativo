using Portal.Security.Domain;

namespace Portal.Security.Application;

public interface ISecurityStore
{
    Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<User?> FindUserByEmailAsync(string tenantId, string normalizedEmail, CancellationToken cancellationToken);
    Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<Role?> FindRoleByNameAsync(string tenantId, string normalizedName, CancellationToken cancellationToken);
    Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<Permission?> FindPermissionByCodeAsync(string tenantId, string code, CancellationToken cancellationToken);
    Task<Permission?> FindPermissionAsync(string tenantId, string resourceKey, string action, CancellationToken cancellationToken);
    Task<Resource?> FindResourceByKeyAsync(string tenantId, string key, CancellationToken cancellationToken);
    Task<bool> HasUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken);
    Task<bool> HasRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken);
    Task<bool> UserHasPermissionAsync(string tenantId, Guid userId, Guid permissionId, CancellationToken cancellationToken);
    Task<IReadOnlyCollection<Permission>> GetUserPermissionsAsync(string tenantId, Guid userId, CancellationToken cancellationToken);
    Task AddAsync<T>(T entity, CancellationToken cancellationToken) where T : class;
    Task SaveChangesAsync(CancellationToken cancellationToken);
}
