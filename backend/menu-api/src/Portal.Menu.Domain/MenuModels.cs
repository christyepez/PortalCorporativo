using System.Text.Json;

namespace Portal.Menu.Domain;

public sealed class MenuDefinition
{
    private MenuDefinition() { }
    private MenuDefinition(Guid id, string tenantId, string moduleCode, string name)
    { Id = id; TenantId = Req(tenantId, 64); ModuleCode = Req(moduleCode, 100).ToLowerInvariant(); Name = Req(name, 160); IsActive = true; }
    public Guid Id { get; private set; } public string TenantId { get; private set; } = null!;
    public string ModuleCode { get; private set; } = null!; public string Name { get; private set; } = null!; public bool IsActive { get; private set; }
    public static MenuDefinition Create(string tenant, string module, string name) => new(Guid.NewGuid(), tenant, module, name);
    public static MenuDefinition Seed(Guid id, string tenant, string module, string name) => new(id, tenant, module, name);
    internal static string Req(string value, int max) => string.IsNullOrWhiteSpace(value) ? throw new ArgumentException("Value is required.") : value.Trim().Length > max ? throw new ArgumentException("Value is too long.") : value.Trim();
}

public sealed class MenuItem
{
    private MenuItem() { }
    private MenuItem(Guid id, Guid menuId, Guid? parentId, string code, string label, string route, string? icon,
        int order, string resourceKey, string permissionCode, string? metadataJson)
    { Id = id; MenuId = menuId; ParentId = parentId; Code = MenuDefinition.Req(code, 100).ToLowerInvariant(); Label = MenuDefinition.Req(label, 160); Route = MenuDefinition.Req(route, 300); Icon = icon; Order = order; ResourceKey = MenuDefinition.Req(resourceKey, 160).ToLowerInvariant(); PermissionCode = MenuDefinition.Req(permissionCode, 180).ToLowerInvariant(); MetadataJson = Json(metadataJson); IsActive = true; }
    public Guid Id { get; private set; } public Guid MenuId { get; private set; } public Guid? ParentId { get; private set; }
    public string Code { get; private set; } = null!; public string Label { get; private set; } = null!; public string Route { get; private set; } = null!;
    public string? Icon { get; private set; } public int Order { get; private set; } public bool IsActive { get; private set; }
    public string ResourceKey { get; private set; } = null!; public string PermissionCode { get; private set; } = null!; public string? MetadataJson { get; private set; }
    public static MenuItem Create(Guid menuId, Guid? parent, string code, string label, string route, string? icon, int order, string resource, string permission, string? metadata) => new(Guid.NewGuid(), menuId, parent, code, label, route, icon, order, resource, permission, metadata);
    public static MenuItem Seed(Guid id, Guid menuId, Guid? parent, string code, string label, string route, string? icon, int order, string resource, string permission) => new(id, menuId, parent, code, label, route, icon, order, resource, permission, null);
    public void Update(string label, string route, string? icon, string resource, string permission, string? metadata) { Label = MenuDefinition.Req(label, 160); Route = MenuDefinition.Req(route, 300); Icon = icon; ResourceKey = MenuDefinition.Req(resource, 160).ToLowerInvariant(); PermissionCode = MenuDefinition.Req(permission, 180).ToLowerInvariant(); MetadataJson = Json(metadata); }
    public void SetActive(bool active) => IsActive = active; public void Reorder(int order, Guid? parent) { Order = order; ParentId = parent; }
    private static string? Json(string? value) { if (string.IsNullOrWhiteSpace(value)) return null; JsonDocument.Parse(value); return value; }
}

public sealed class MenuAction
{
    private MenuAction() { }
    private MenuAction(Guid id, Guid menuItemId, string code, string label, string permissionCode, int order)
    { Id = id; MenuItemId = menuItemId; Code = MenuDefinition.Req(code, 80).ToLowerInvariant(); Label = MenuDefinition.Req(label, 120); PermissionCode = MenuDefinition.Req(permissionCode, 180).ToLowerInvariant(); Order = order; IsActive = true; }
    public Guid Id { get; private set; } public Guid MenuItemId { get; private set; } public string Code { get; private set; } = null!;
    public string Label { get; private set; } = null!; public string PermissionCode { get; private set; } = null!; public int Order { get; private set; } public bool IsActive { get; private set; }
    public static MenuAction Create(Guid item, string code, string label, string permission, int order) => new(Guid.NewGuid(), item, code, label, permission, order);
    public static MenuAction Seed(Guid id, Guid item, string code, string label, string permission, int order) => new(id, item, code, label, permission, order);
}
