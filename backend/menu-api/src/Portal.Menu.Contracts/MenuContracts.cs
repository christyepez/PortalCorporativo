namespace Portal.Menu.Contracts;
public sealed record CreateMenuRequest(string ModuleCode, string Name);
public sealed record CreateMenuItemRequest(Guid MenuId, Guid? ParentId, string Code, string Label, string Route, string? Icon, int Order, string ResourceKey, string PermissionCode, string? MetadataJson);
public sealed record UpdateMenuItemRequest(string Label, string Route, string? Icon, string ResourceKey, string PermissionCode, string? MetadataJson);
public sealed record AssignPermissionRequest(string ResourceKey, string PermissionCode);
public sealed record ReorderMenuItem(Guid ItemId, Guid? ParentId, int Order);
public sealed record ReorderMenuRequest(IReadOnlyCollection<ReorderMenuItem> Items);
public sealed record MenuItemResponse(Guid Id, Guid MenuId, Guid? ParentId, string Code, string Label, string Route, string? Icon, int Order, string ResourceKey, string PermissionCode, string? MetadataJson);
public sealed record MenuChangedV1(Guid MenuId, Guid? ItemId, string ChangeType, string CorrelationId);
