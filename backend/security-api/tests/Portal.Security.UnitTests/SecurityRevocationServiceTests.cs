using Portal.BuildingBlocks;
using Portal.Security.Application;
using Portal.Security.Domain;
using Xunit;

namespace Portal.Security.UnitTests;

public sealed class SecurityRevocationServiceTests
{
    [Fact]
    public async Task Revoke_role_removes_existing_assignment()
    {
        var user = User.Create(TenantIds.Default, "revocation@example.com", "Revocation User");
        var role = Role.Create(TenantIds.Default, "Operator");
        var store = new RevocationStore(user, role, null) { UserRoleExists = true };
        var service = new SecurityRevocationService(store, new PortalTenantContext());

        var result = await service.RevokeRoleFromUserAsync(user.Id, role.Id, default);

        Assert.True(result.IsSuccess);
        Assert.False(store.UserRoleExists);
    }

    [Fact]
    public async Task Revoke_permission_removes_existing_assignment()
    {
        var role = Role.Create(TenantIds.Default, "Auditor");
        var permission = Permission.Create(TenantIds.Default, "portal.audit.read", "portal.audit", "read");
        var store = new RevocationStore(null, role, permission) { RolePermissionExists = true };
        var service = new SecurityRevocationService(store, new PortalTenantContext());

        var result = await service.RevokePermissionFromRoleAsync(role.Id, permission.Id, default);

        Assert.True(result.IsSuccess);
        Assert.False(store.RolePermissionExists);
    }

    [Fact]
    public async Task Revoke_missing_assignment_returns_not_found()
    {
        var user = User.Create(TenantIds.Default, "revocation@example.com", "Revocation User");
        var role = Role.Create(TenantIds.Default, "Operator");
        var store = new RevocationStore(user, role, null);
        var service = new SecurityRevocationService(store, new PortalTenantContext());

        var result = await service.RevokeRoleFromUserAsync(user.Id, role.Id, default);

        Assert.False(result.IsSuccess);
        Assert.Equal("security.user_role.not_found", result.Error?.Code);
    }

    private sealed class RevocationStore(User? user, Role? role, Permission? permission) : ISecurityRevocationStore
    {
        public bool UserRoleExists { get; set; }
        public bool RolePermissionExists { get; set; }

        public Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken)
            => Task.FromResult(user is not null && user.TenantId == tenantId && user.Id == id ? user : null);

        public Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken)
            => Task.FromResult(role is not null && role.TenantId == tenantId && role.Id == id ? role : null);

        public Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken)
            => Task.FromResult(permission is not null && permission.TenantId == tenantId && permission.Id == id ? permission : null);

        public Task<bool> RemoveUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken)
        {
            var existed = UserRoleExists;
            UserRoleExists = false;
            return Task.FromResult(existed);
        }

        public Task<bool> RemoveRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken)
        {
            var existed = RolePermissionExists;
            RolePermissionExists = false;
            return Task.FromResult(existed);
        }
    }
}
