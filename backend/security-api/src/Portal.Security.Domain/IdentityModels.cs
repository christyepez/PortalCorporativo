using System.Net.Mail;

namespace Portal.Security.Domain;

public static class TenantIds
{
    public const string Default = "default";
}

public sealed class Tenant
{
    private Tenant() { }
    public Tenant(string id, string name)
    {
        Id = Required(id, nameof(id), 64);
        Name = Required(name, nameof(name), 160);
    }

    public string Id { get; private set; } = null!;
    public string Name { get; private set; } = null!;

    private static string Required(string value, string field, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value)) throw new ArgumentException($"{field} is required.", field);
        return value.Trim().Length <= maxLength ? value.Trim() : throw new ArgumentException($"{field} is too long.", field);
    }
}

public sealed class User
{
    private User() { }
    private User(Guid id, string tenantId, string email, string name)
    {
        Id = id;
        TenantId = Guard.Tenant(tenantId);
        Email = Guard.Email(email);
        NormalizedEmail = Email.ToUpperInvariant();
        Name = Guard.Required(name, nameof(name), 160);
        IsActive = true;
        CreatedAtUtc = DateTimeOffset.UtcNow;
    }

    public Guid Id { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string Email { get; private set; } = null!;
    public string NormalizedEmail { get; private set; } = null!;
    public string Name { get; private set; } = null!;
    public bool IsActive { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; }

    public static User Create(string tenantId, string email, string name) => new(Guid.NewGuid(), tenantId, email, name);
}

public sealed class Role
{
    private Role() { }
    private Role(Guid id, string tenantId, string name)
    {
        Id = id;
        TenantId = Guard.Tenant(tenantId);
        Name = Guard.Required(name, nameof(name), 120);
        NormalizedName = Name.ToUpperInvariant();
    }

    public Guid Id { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string Name { get; private set; } = null!;
    public string NormalizedName { get; private set; } = null!;

    public static Role Create(string tenantId, string name) => new(Guid.NewGuid(), tenantId, name);
    public static Role Seed(Guid id, string tenantId, string name) => new(id, tenantId, name);
}

public sealed class Permission
{
    private Permission() { }
    private Permission(Guid id, string tenantId, string code, string resourceKey, string action)
    {
        Id = id;
        TenantId = Guard.Tenant(tenantId);
        Code = Guard.Key(code, nameof(code), 180);
        ResourceKey = Guard.Key(resourceKey, nameof(resourceKey), 160);
        Action = Guard.Key(action, nameof(action), 80);
    }

    public Guid Id { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string Code { get; private set; } = null!;
    public string ResourceKey { get; private set; } = null!;
    public string Action { get; private set; } = null!;

    public static Permission Create(string tenantId, string code, string resourceKey, string action) =>
        new(Guid.NewGuid(), tenantId, code, resourceKey, action);
    public static Permission Seed(Guid id, string tenantId, string code, string resourceKey, string action) =>
        new(id, tenantId, code, resourceKey, action);
}

public sealed class Resource
{
    private Resource() { }
    private Resource(Guid id, string tenantId, string key, string name)
    {
        Id = id;
        TenantId = Guard.Tenant(tenantId);
        Key = Guard.Key(key, nameof(key), 160);
        Name = Guard.Required(name, nameof(name), 160);
    }

    public Guid Id { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string Key { get; private set; } = null!;
    public string Name { get; private set; } = null!;

    public static Resource Create(string tenantId, string key, string name) => new(Guid.NewGuid(), tenantId, key, name);
    public static Resource Seed(Guid id, string tenantId, string key, string name) => new(id, tenantId, key, name);
}

public sealed class UserRole
{
    private UserRole() { }
    private UserRole(string tenantId, Guid userId, Guid roleId)
    {
        TenantId = Guard.Tenant(tenantId);
        UserId = Guard.Id(userId, nameof(userId));
        RoleId = Guard.Id(roleId, nameof(roleId));
    }

    public string TenantId { get; private set; } = null!;
    public Guid UserId { get; private set; }
    public Guid RoleId { get; private set; }
    public static UserRole Create(string tenantId, Guid userId, Guid roleId) => new(tenantId, userId, roleId);
}

public sealed class RolePermission
{
    private RolePermission() { }
    private RolePermission(string tenantId, Guid roleId, Guid permissionId)
    {
        TenantId = Guard.Tenant(tenantId);
        RoleId = Guard.Id(roleId, nameof(roleId));
        PermissionId = Guard.Id(permissionId, nameof(permissionId));
    }

    public string TenantId { get; private set; } = null!;
    public Guid RoleId { get; private set; }
    public Guid PermissionId { get; private set; }
    public static RolePermission Create(string tenantId, Guid roleId, Guid permissionId) => new(tenantId, roleId, permissionId);
    public static RolePermission Seed(string tenantId, Guid roleId, Guid permissionId) => new(tenantId, roleId, permissionId);
}

internal static class Guard
{
    public static Guid Id(Guid value, string field) => value != Guid.Empty ? value : throw new ArgumentException($"{field} is required.", field);
    public static string Tenant(string value) => Required(value, "tenantId", 64).ToLowerInvariant();
    public static string Key(string value, string field, int maxLength) => Required(value, field, maxLength).ToLowerInvariant();

    public static string Required(string value, string field, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value)) throw new ArgumentException($"{field} is required.", field);
        var normalized = value.Trim();
        return normalized.Length <= maxLength ? normalized : throw new ArgumentException($"{field} is too long.", field);
    }

    public static string Email(string value)
    {
        var normalized = Required(value, "email", 320).ToLowerInvariant();
        try
        {
            var address = new MailAddress(normalized);
            return address.Address == normalized && normalized.Contains('.')
                ? normalized
                : throw new ArgumentException("email is invalid.", "email");
        }
        catch (FormatException)
        {
            throw new ArgumentException("email is invalid.", "email");
        }
    }
}
