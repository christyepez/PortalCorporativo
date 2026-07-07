using Portal.BuildingBlocks;
using Portal.Security.Contracts;
using Portal.Security.Domain;

namespace Portal.Security.Application;

public sealed class SecurityService(ISecurityStore store)
{
    public async Task<Result<UserResponse>> CreateUserAsync(CreateUserRequest request, CancellationToken cancellationToken)
    {
        User user;
        try { user = User.Create(TenantIds.Default, request.Email, request.Name); }
        catch (ArgumentException exception) { return Invalid<UserResponse>(exception); }

        if (await store.FindUserByEmailAsync(user.TenantId, user.NormalizedEmail, cancellationToken) is not null)
            return Result<UserResponse>.Failure("security.user.email_conflict", "A user with this email already exists in the tenant.");

        await store.AddAsync(user, cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<UserResponse>.Success(ToResponse(user));
    }

    public async Task<Result<UserResponse>> GetUserAsync(Guid id, CancellationToken cancellationToken)
    {
        var user = await store.FindUserAsync(TenantIds.Default, id, cancellationToken);
        return user is null
            ? Result<UserResponse>.Failure("security.user.not_found", "User was not found.")
            : Result<UserResponse>.Success(ToResponse(user));
    }

    public async Task<Result<RoleResponse>> CreateRoleAsync(CreateRoleRequest request, CancellationToken cancellationToken)
    {
        Role role;
        try { role = Role.Create(TenantIds.Default, request.Name); }
        catch (ArgumentException exception) { return Invalid<RoleResponse>(exception); }

        if (await store.FindRoleByNameAsync(role.TenantId, role.NormalizedName, cancellationToken) is not null)
            return Result<RoleResponse>.Failure("security.role.conflict", "Role already exists in the tenant.");

        await store.AddAsync(role, cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<RoleResponse>.Success(new RoleResponse(role.Id, role.TenantId, role.Name));
    }

    public async Task<Result<ResourceResponse>> RegisterResourceAsync(RegisterProtectedResourceRequest request, CancellationToken cancellationToken)
    {
        Resource resource;
        try { resource = Resource.Create(TenantIds.Default, request.Key, request.Name); }
        catch (ArgumentException exception) { return Invalid<ResourceResponse>(exception); }

        if (await store.FindResourceByKeyAsync(resource.TenantId, resource.Key, cancellationToken) is not null)
            return Result<ResourceResponse>.Failure("security.resource.conflict", "Resource already exists in the tenant.");

        await store.AddAsync(resource, cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<ResourceResponse>.Success(new ResourceResponse(resource.Id, resource.TenantId, resource.Key, resource.Name));
    }

    public async Task<Result<PermissionResponse>> CreatePermissionAsync(CreatePermissionRequest request, CancellationToken cancellationToken)
    {
        Permission permission;
        try { permission = Permission.Create(TenantIds.Default, request.Code, request.ResourceKey, request.Action); }
        catch (ArgumentException exception) { return Invalid<PermissionResponse>(exception); }

        if (await store.FindResourceByKeyAsync(permission.TenantId, permission.ResourceKey, cancellationToken) is null)
            return Result<PermissionResponse>.Failure("security.resource.not_found", "Protected resource must be registered first.");
        if (await store.FindPermissionByCodeAsync(permission.TenantId, permission.Code, cancellationToken) is not null)
            return Result<PermissionResponse>.Failure("security.permission.conflict", "Permission already exists in the tenant.");

        await store.AddAsync(permission, cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<PermissionResponse>.Success(ToResponse(permission));
    }

    public async Task<Result<bool>> AssignRoleAsync(Guid userId, Guid roleId, CancellationToken cancellationToken)
    {
        var user = await store.FindUserAsync(TenantIds.Default, userId, cancellationToken);
        if (user is null) return Result<bool>.Failure("security.user.not_found", "User was not found.");
        var role = await store.FindRoleAsync(TenantIds.Default, roleId, cancellationToken);
        if (role is null) return Result<bool>.Failure("security.role.not_found", "Role was not found.");
        if (await store.HasUserRoleAsync(TenantIds.Default, userId, roleId, cancellationToken))
            return Result<bool>.Failure("security.user_role.conflict", "Role is already assigned to the user.");

        await store.AddAsync(UserRole.Create(TenantIds.Default, userId, roleId), cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<bool>.Success(true);
    }

    public async Task<Result<bool>> AssignPermissionAsync(Guid roleId, Guid permissionId, CancellationToken cancellationToken)
    {
        var role = await store.FindRoleAsync(TenantIds.Default, roleId, cancellationToken);
        if (role is null) return Result<bool>.Failure("security.role.not_found", "Role was not found.");
        var permission = await store.FindPermissionAsync(TenantIds.Default, permissionId, cancellationToken);
        if (permission is null) return Result<bool>.Failure("security.permission.not_found", "Permission was not found.");
        if (await store.HasRolePermissionAsync(TenantIds.Default, roleId, permissionId, cancellationToken))
            return Result<bool>.Failure("security.role_permission.conflict", "Permission is already assigned to the role.");

        await store.AddAsync(RolePermission.Create(TenantIds.Default, roleId, permissionId), cancellationToken);
        await store.SaveChangesAsync(cancellationToken);
        return Result<bool>.Success(true);
    }

    public async Task<Result<PermissionDecisionResponse>> CheckPermissionAsync(CheckPermissionRequest request, CancellationToken cancellationToken)
    {
        var user = await store.FindUserAsync(TenantIds.Default, request.UserId, cancellationToken);
        if (user is null || !user.IsActive)
            return Result<PermissionDecisionResponse>.Failure("security.user.not_found", "Active user was not found.");

        Resource? resource;
        Permission? permission;
        try
        {
            var resourceKey = request.ResourceKey.Trim().ToLowerInvariant();
            var action = request.Action.Trim().ToLowerInvariant();
            resource = await store.FindResourceByKeyAsync(TenantIds.Default, resourceKey, cancellationToken);
            permission = await store.FindPermissionAsync(TenantIds.Default, resourceKey, action, cancellationToken);
        }
        catch (Exception exception) when (exception is ArgumentException or NullReferenceException)
        {
            return Result<PermissionDecisionResponse>.Failure("validation.invalid", "Resource and action are required.");
        }

        if (resource is null) return Result<PermissionDecisionResponse>.Failure("security.resource.not_found", "Resource was not found.");
        if (permission is null) return Result<PermissionDecisionResponse>.Failure("security.permission.not_found", "Action is not registered for the resource.");

        var allowed = await store.UserHasPermissionAsync(TenantIds.Default, user.Id, permission.Id, cancellationToken);
        return Result<PermissionDecisionResponse>.Success(new PermissionDecisionResponse(user.Id, resource.Key, permission.Action, allowed));
    }

    public async Task<Result<UserPermissionsResponse>> GetUserPermissionsAsync(Guid userId, CancellationToken cancellationToken)
    {
        if (await store.FindUserAsync(TenantIds.Default, userId, cancellationToken) is null)
            return Result<UserPermissionsResponse>.Failure("security.user.not_found", "User was not found.");

        var permissions = await store.GetUserPermissionsAsync(TenantIds.Default, userId, cancellationToken);
        return Result<UserPermissionsResponse>.Success(new UserPermissionsResponse(userId, permissions.Select(x => x.Code).Distinct().Order().ToArray()));
    }

    private static Result<T> Invalid<T>(ArgumentException exception) =>
        Result<T>.Failure("validation.invalid", exception.Message);

    private static UserResponse ToResponse(User user) => new(user.Id, user.TenantId, user.Email, user.Name, user.IsActive);
    private static PermissionResponse ToResponse(Permission permission) =>
        new(permission.Id, permission.TenantId, permission.Code, permission.ResourceKey, permission.Action);
}
