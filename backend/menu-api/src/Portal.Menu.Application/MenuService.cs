using Portal.BuildingBlocks;
using Portal.Menu.Contracts;
using Portal.Menu.Domain;

namespace Portal.Menu.Application;
public interface IMenuStore
{
    Task<MenuDefinition?> GetMenuAsync(Guid id, CancellationToken ct); Task<MenuDefinition?> GetMenuByModuleAsync(string tenant, string module, CancellationToken ct);
    Task<MenuItem?> GetItemAsync(Guid id, CancellationToken ct); Task<IReadOnlyCollection<MenuItem>> GetItemsAsync(Guid menuId, CancellationToken ct);
    Task AddAsync<T>(T value, CancellationToken ct) where T : class; Task SaveChangesAsync(CancellationToken ct);
}
public interface IPermissionChecker { Task<bool> HasPermissionAsync(Guid userId, string resource, string action, CancellationToken ct); }
public interface IMenuChangeRecorder { Task RecordAsync(string action, string entityId, object payload, string correlationId, CancellationToken ct); }

public sealed class MenuService(IMenuStore store, IPermissionChecker permissions, IMenuChangeRecorder recorder)
{
    public async Task<Result<Guid>> CreateMenuAsync(CreateMenuRequest request, string correlation, CancellationToken ct)
    { try { var menu = MenuDefinition.Create("default", request.ModuleCode, request.Name); await store.AddAsync(menu, ct); await store.SaveChangesAsync(ct); await recorder.RecordAsync("created", menu.Id.ToString(), new MenuChangedV1(menu.Id, null, "Created", correlation), correlation, ct); return Result<Guid>.Success(menu.Id); } catch (ArgumentException e) { return Result<Guid>.Failure("menu.validation", e.Message); } }
    public async Task<Result<MenuItemResponse>> CreateItemAsync(CreateMenuItemRequest r, string correlation, CancellationToken ct)
    { if (await store.GetMenuAsync(r.MenuId, ct) is null) return NotFound(); try { var item = MenuItem.Create(r.MenuId, r.ParentId, r.Code, r.Label, r.Route, r.Icon, r.Order, r.ResourceKey, r.PermissionCode, r.MetadataJson); await store.AddAsync(item, ct); await store.SaveChangesAsync(ct); await Changed(item, "Created", correlation, ct); return Result<MenuItemResponse>.Success(Map(item)); } catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException) { return Result<MenuItemResponse>.Failure("menu.validation", e.Message); } }
    public async Task<Result<MenuItemResponse>> UpdateItemAsync(Guid id, UpdateMenuItemRequest r, string correlation, CancellationToken ct)
    { var item = await store.GetItemAsync(id, ct); if (item is null) return NotFound(); try { item.Update(r.Label, r.Route, r.Icon, r.ResourceKey, r.PermissionCode, r.MetadataJson); } catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException) { return Result<MenuItemResponse>.Failure("menu.validation", e.Message); } await store.SaveChangesAsync(ct); await Changed(item, "Changed", correlation, ct); return Result<MenuItemResponse>.Success(Map(item)); }
    public async Task<Result<MenuItemResponse>> AssignPermissionAsync(Guid id, AssignPermissionRequest r, string correlation, CancellationToken ct)
    { var item = await store.GetItemAsync(id, ct); if (item is null) return NotFound(); item.Update(item.Label, item.Route, item.Icon, r.ResourceKey, r.PermissionCode, item.MetadataJson); await store.SaveChangesAsync(ct); await Changed(item, "PermissionAssigned", correlation, ct); return Result<MenuItemResponse>.Success(Map(item)); }
    public async Task<Result<MenuItemResponse>> SetActiveAsync(Guid id, bool active, string correlation, CancellationToken ct)
    { var item = await store.GetItemAsync(id, ct); if (item is null) return NotFound(); item.SetActive(active); await store.SaveChangesAsync(ct); await Changed(item, active ? "Activated" : "Deactivated", correlation, ct); return Result<MenuItemResponse>.Success(Map(item)); }
    public async Task<Result<bool>> ReorderAsync(ReorderMenuRequest request, string correlation, CancellationToken ct)
    { foreach (var change in request.Items) { var item = await store.GetItemAsync(change.ItemId, ct); if (item is null) return Result<bool>.Failure("menu.not_found", "Menu item was not found."); item.Reorder(change.Order, change.ParentId); } await store.SaveChangesAsync(ct); await recorder.RecordAsync("reordered", "menu", new { request.Items, correlation }, correlation, ct); return Result<bool>.Success(true); }
    public async Task<Result<IReadOnlyCollection<MenuItemResponse>>> GetForUserAsync(Guid user, string module, CancellationToken ct)
    { var menu = await store.GetMenuByModuleAsync("default", module.ToLowerInvariant(), ct); if (menu is null) return Result<IReadOnlyCollection<MenuItemResponse>>.Failure("menu.not_found", "Menu was not found."); var visible = new List<MenuItemResponse>(); foreach (var item in (await store.GetItemsAsync(menu.Id, ct)).Where(x => x.IsActive).OrderBy(x => x.Order)) { var action = item.PermissionCode.Split('.').Last(); if (await permissions.HasPermissionAsync(user, item.ResourceKey, action, ct)) visible.Add(Map(item)); } return Result<IReadOnlyCollection<MenuItemResponse>>.Success(visible); }
    public async Task<Result<IReadOnlyCollection<MenuItemResponse>>> GetByModuleAsync(string module, CancellationToken ct)
    { var menu = await store.GetMenuByModuleAsync("default", module.ToLowerInvariant(), ct); if (menu is null) return Result<IReadOnlyCollection<MenuItemResponse>>.Failure("menu.not_found", "Menu was not found."); return Result<IReadOnlyCollection<MenuItemResponse>>.Success((await store.GetItemsAsync(menu.Id, ct)).OrderBy(x => x.Order).Select(Map).ToArray()); }
    private Task Changed(MenuItem x, string type, string correlation, CancellationToken ct) => recorder.RecordAsync(type.ToLowerInvariant(), x.Id.ToString(), new MenuChangedV1(x.MenuId, x.Id, type, correlation), correlation, ct);
    private static Result<MenuItemResponse> NotFound() => Result<MenuItemResponse>.Failure("menu.not_found", "Menu or item was not found.");
    private static MenuItemResponse Map(MenuItem x) => new(x.Id, x.MenuId, x.ParentId, x.Code, x.Label, x.Route, x.Icon, x.Order, x.ResourceKey, x.PermissionCode, x.MetadataJson);
}
