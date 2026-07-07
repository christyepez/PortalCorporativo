using System.Text.Json;

namespace Portal.Configuration.Domain;

public enum ConfigurationScope { Global = 0, Tenant = 1, Module = 2, User = 3 }
public enum ConfigurationCategory { Visual, Functional, Grid, Form, Action, Layout, Theme }

public sealed class ConfigurationItem
{
    private ConfigurationItem() { }
    private ConfigurationItem(Guid id, string key, ConfigurationScope scope, string tenantId, string? moduleCode,
        Guid? userId, ConfigurationCategory category, string valueJson, DateTimeOffset now)
    {
        Id = id; Key = Required(key, nameof(key), 180).ToLowerInvariant(); Scope = scope;
        TenantId = Required(tenantId, nameof(tenantId), 64).ToLowerInvariant();
        ModuleCode = Optional(moduleCode, 100)?.ToLowerInvariant(); UserId = userId; Category = category;
        ValidateScope(scope, ModuleCode, userId); ValueJson = Json(valueJson); Version = 1; IsActive = false;
        CreatedAtUtc = now; UpdatedAtUtc = now;
    }
    public Guid Id { get; private set; } public string Key { get; private set; } = null!;
    public ConfigurationScope Scope { get; private set; } public string TenantId { get; private set; } = null!;
    public string? ModuleCode { get; private set; } public Guid? UserId { get; private set; }
    public ConfigurationCategory Category { get; private set; } public string ValueJson { get; private set; } = null!;
    public int Version { get; private set; } public bool IsActive { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; } public DateTimeOffset UpdatedAtUtc { get; private set; }
    public static ConfigurationItem Create(string key, ConfigurationScope scope, string tenantId, string? moduleCode,
        Guid? userId, ConfigurationCategory category, string valueJson, DateTimeOffset now) =>
        new(Guid.NewGuid(), key, scope, tenantId, moduleCode, userId, category, valueJson, now);
    public void Update(ConfigurationCategory category, string valueJson, DateTimeOffset now)
    { Category = category; ValueJson = Json(valueJson); Version++; UpdatedAtUtc = now; }
    public void Activate(DateTimeOffset now) { IsActive = true; UpdatedAtUtc = now; }
    public void Deactivate(DateTimeOffset now) { IsActive = false; UpdatedAtUtc = now; }
    private static void ValidateScope(ConfigurationScope scope, string? module, Guid? user)
    {
        if (scope >= ConfigurationScope.Module && string.IsNullOrWhiteSpace(module)) throw new ArgumentException("moduleCode is required for module/user scope.");
        if (scope == ConfigurationScope.User && (!user.HasValue || user == Guid.Empty)) throw new ArgumentException("userId is required for user scope.");
        if (scope < ConfigurationScope.Module && (module is not null || user.HasValue)) throw new ArgumentException("moduleCode/userId do not apply to this scope.");
    }
    private static string Json(string value) { JsonDocument.Parse(value); return value; }
    private static string Required(string value, string field, int max) => string.IsNullOrWhiteSpace(value) ? throw new ArgumentException($"{field} is required.") : value.Trim().Length > max ? throw new ArgumentException($"{field} is too long.") : value.Trim();
    private static string? Optional(string? value, int max) => string.IsNullOrWhiteSpace(value) ? null : value.Trim().Length > max ? throw new ArgumentException("Value is too long.") : value.Trim();
}
