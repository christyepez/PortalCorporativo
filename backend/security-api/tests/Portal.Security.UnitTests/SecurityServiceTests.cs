using Portal.Security.Application;
using Portal.Security.Contracts;
using Portal.Security.Domain;
using Xunit;

namespace Portal.Security.UnitTests;

public sealed class SecurityServiceTests
{
    [Fact]
    public void User_rejects_invalid_email_and_missing_name()
    {
        Assert.Throws<ArgumentException>(() => User.Create(TenantIds.Default, "invalid", "Valid Name"));
        Assert.Throws<ArgumentException>(() => User.Create(TenantIds.Default, "valid@example.com", " "));
    }

    [Fact]
    public async Task Role_is_unique_per_tenant()
    {
        var service = new SecurityService(new InMemorySecurityStore());
        Assert.True((await service.CreateRoleAsync(new("PortalAdmin"), default)).IsSuccess);

        var duplicate = await service.CreateRoleAsync(new("portaladmin"), default);

        Assert.False(duplicate.IsSuccess);
        Assert.Equal("security.role.conflict", duplicate.Error?.Code);
    }

    [Fact]
    public async Task Assign_role_rejects_duplicates()
    {
        var service = new SecurityService(new InMemorySecurityStore());
        var user = (await service.CreateUserAsync(new("user@example.com", "User"), default)).Value!;
        var role = (await service.CreateRoleAsync(new("Reader"), default)).Value!;

        Assert.True((await service.AssignRoleAsync(user.Id, role.Id, default)).IsSuccess);
        var duplicate = await service.AssignRoleAsync(user.Id, role.Id, default);

        Assert.Equal("security.user_role.conflict", duplicate.Error?.Code);
    }

    [Fact]
    public async Task Assign_permission_rejects_duplicates()
    {
        var service = new SecurityService(new InMemorySecurityStore());
        var role = (await service.CreateRoleAsync(new("Reader"), default)).Value!;
        await service.RegisterResourceAsync(new("portal.audit", "Audit"), default);
        var permission = (await service.CreatePermissionAsync(new("portal.audit.read", "portal.audit", "read"), default)).Value!;

        Assert.True((await service.AssignPermissionAsync(role.Id, permission.Id, default)).IsSuccess);
        var duplicate = await service.AssignPermissionAsync(role.Id, permission.Id, default);

        Assert.Equal("security.role_permission.conflict", duplicate.Error?.Code);
    }

    [Fact]
    public async Task Check_permission_allows_assigned_permission()
    {
        var service = new SecurityService(new InMemorySecurityStore());
        var user = (await service.CreateUserAsync(new("user@example.com", "User"), default)).Value!;
        var role = (await service.CreateRoleAsync(new("Auditor"), default)).Value!;
        await service.RegisterResourceAsync(new("portal.audit", "Audit"), default);
        var permission = (await service.CreatePermissionAsync(new("portal.audit.read", "portal.audit", "read"), default)).Value!;
        await service.AssignRoleAsync(user.Id, role.Id, default);
        await service.AssignPermissionAsync(role.Id, permission.Id, default);

        var decision = await service.CheckPermissionAsync(new(user.Id, "portal.audit", "read"), default);

        Assert.True(decision.IsSuccess);
        Assert.True(decision.Value?.Allowed);
    }

    [Fact]
    public async Task Check_permission_denies_unassigned_and_validates_resource_action()
    {
        var service = new SecurityService(new InMemorySecurityStore());
        var user = (await service.CreateUserAsync(new("user@example.com", "User"), default)).Value!;
        await service.RegisterResourceAsync(new("portal.audit", "Audit"), default);
        await service.CreatePermissionAsync(new("portal.audit.read", "portal.audit", "read"), default);

        var denied = await service.CheckPermissionAsync(new(user.Id, "portal.audit", "read"), default);
        var unknownAction = await service.CheckPermissionAsync(new(user.Id, "portal.audit", "manage"), default);

        Assert.False(denied.Value?.Allowed);
        Assert.Equal("security.permission.not_found", unknownAction.Error?.Code);
    }

    private sealed class InMemorySecurityStore : ISecurityStore
    {
        private readonly List<User> users = [];
        private readonly List<Role> roles = [];
        private readonly List<Permission> permissions = [];
        private readonly List<Resource> resources = [];
        private readonly List<UserRole> userRoles = [];
        private readonly List<RolePermission> rolePermissions = [];

        public Task<User?> FindUserAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
            Task.FromResult(users.SingleOrDefault(x => x.TenantId == tenantId && x.Id == id));
        public Task<User?> FindUserByEmailAsync(string tenantId, string normalizedEmail, CancellationToken cancellationToken) =>
            Task.FromResult(users.SingleOrDefault(x => x.TenantId == tenantId && x.NormalizedEmail == normalizedEmail));
        public Task<Role?> FindRoleAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
            Task.FromResult(roles.SingleOrDefault(x => x.TenantId == tenantId && x.Id == id));
        public Task<Role?> FindRoleByNameAsync(string tenantId, string normalizedName, CancellationToken cancellationToken) =>
            Task.FromResult(roles.SingleOrDefault(x => x.TenantId == tenantId && x.NormalizedName == normalizedName));
        public Task<Permission?> FindPermissionAsync(string tenantId, Guid id, CancellationToken cancellationToken) =>
            Task.FromResult(permissions.SingleOrDefault(x => x.TenantId == tenantId && x.Id == id));
        public Task<Permission?> FindPermissionByCodeAsync(string tenantId, string code, CancellationToken cancellationToken) =>
            Task.FromResult(permissions.SingleOrDefault(x => x.TenantId == tenantId && x.Code == code));
        public Task<Permission?> FindPermissionAsync(string tenantId, string resourceKey, string action, CancellationToken cancellationToken) =>
            Task.FromResult(permissions.SingleOrDefault(x => x.TenantId == tenantId && x.ResourceKey == resourceKey && x.Action == action));
        public Task<Resource?> FindResourceByKeyAsync(string tenantId, string key, CancellationToken cancellationToken) =>
            Task.FromResult(resources.SingleOrDefault(x => x.TenantId == tenantId && x.Key == key));
        public Task<bool> HasUserRoleAsync(string tenantId, Guid userId, Guid roleId, CancellationToken cancellationToken) =>
            Task.FromResult(userRoles.Any(x => x.TenantId == tenantId && x.UserId == userId && x.RoleId == roleId));
        public Task<bool> HasRolePermissionAsync(string tenantId, Guid roleId, Guid permissionId, CancellationToken cancellationToken) =>
            Task.FromResult(rolePermissions.Any(x => x.TenantId == tenantId && x.RoleId == roleId && x.PermissionId == permissionId));
        public Task<bool> UserHasPermissionAsync(string tenantId, Guid userId, Guid permissionId, CancellationToken cancellationToken) =>
            Task.FromResult(userRoles.Where(x => x.TenantId == tenantId && x.UserId == userId)
                .Join(rolePermissions, x => x.RoleId, x => x.RoleId, (_, assignment) => assignment)
                .Any(x => x.PermissionId == permissionId));
        public Task<IReadOnlyCollection<Permission>> GetUserPermissionsAsync(string tenantId, Guid userId, CancellationToken cancellationToken)
        {
            var result = userRoles.Where(x => x.TenantId == tenantId && x.UserId == userId)
                .Join(rolePermissions, x => x.RoleId, x => x.RoleId, (_, assignment) => assignment)
                .Join(permissions, x => x.PermissionId, x => x.Id, (_, permission) => permission)
                .Distinct().ToArray();
            return Task.FromResult<IReadOnlyCollection<Permission>>(result);
        }
        public Task AddAsync<T>(T entity, CancellationToken cancellationToken) where T : class
        {
            switch (entity)
            {
                case User value: users.Add(value); break;
                case Role value: roles.Add(value); break;
                case Permission value: permissions.Add(value); break;
                case Resource value: resources.Add(value); break;
                case UserRole value: userRoles.Add(value); break;
                case RolePermission value: rolePermissions.Add(value); break;
                default: throw new NotSupportedException(typeof(T).Name);
            }
            return Task.CompletedTask;
        }
        public Task SaveChangesAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }
}
