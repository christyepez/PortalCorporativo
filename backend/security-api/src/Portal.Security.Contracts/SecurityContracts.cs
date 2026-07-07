namespace Portal.Security.Contracts;

public sealed record CreateUserRequest(string Email, string Name);
public sealed record CreateRoleRequest(string Name);
public sealed record CreatePermissionRequest(string Code, string ResourceKey, string Action);
public sealed record AssignRoleToUserRequest(Guid RoleId);
public sealed record AssignPermissionToRoleRequest(Guid PermissionId);
public sealed record RegisterProtectedResourceRequest(string Key, string Name);
public sealed record CheckPermissionRequest(Guid UserId, string ResourceKey, string Action);

public sealed record UserResponse(Guid Id, string TenantId, string Email, string Name, bool IsActive);
public sealed record RoleResponse(Guid Id, string TenantId, string Name);
public sealed record PermissionResponse(Guid Id, string TenantId, string Code, string ResourceKey, string Action);
public sealed record ResourceResponse(Guid Id, string TenantId, string Key, string Name);
public sealed record UserPermissionsResponse(Guid UserId, IReadOnlyCollection<string> Permissions);
public sealed record PermissionDecisionResponse(Guid UserId, string ResourceKey, string Action, bool Allowed);
