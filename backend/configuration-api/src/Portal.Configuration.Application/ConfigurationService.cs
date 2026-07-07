using Portal.BuildingBlocks;
using Portal.Configuration.Contracts;
using Portal.Configuration.Domain;

namespace Portal.Configuration.Application;

public interface IConfigurationStore
{
    Task<ConfigurationItem?> GetAsync(Guid id, CancellationToken ct);
    Task<IReadOnlyCollection<ConfigurationItem>> FindCandidatesAsync(string tenant, string key, string? module, Guid? user, CancellationToken ct);
    Task<IReadOnlyCollection<ConfigurationItem>> GetByScopeAsync(ConfigurationScope scope, string tenant, string? module, Guid? user, CancellationToken ct);
    Task AddAsync(ConfigurationItem item, CancellationToken ct); Task SaveChangesAsync(CancellationToken ct);
}
public interface IPlatformChangeRecorder
{ Task RecordAsync(string capability, string action, string entityId, object payload, string correlationId, CancellationToken ct); }

public sealed class ConfigurationService(IConfigurationStore store, IPlatformChangeRecorder recorder, IClock clock)
{
    public async Task<Result<ConfigurationResponse>> CreateAsync(CreateConfigurationRequest request, string correlationId, CancellationToken ct)
    {
        try
        {
            var item = ConfigurationItem.Create(request.Key, (ConfigurationScope)request.Scope, "default", request.ModuleCode,
                request.UserId, (ConfigurationCategory)request.Category, request.ValueJson, clock.UtcNow);
            await store.AddAsync(item, ct); await store.SaveChangesAsync(ct);
            await recorder.RecordAsync("configuration", "created", item.Id.ToString(), new ConfigurationChangedV1(item.Id, item.Key, item.Version, "Created", correlationId), correlationId, ct);
            return Result<ConfigurationResponse>.Success(Map(item));
        }
        catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException)
        { return Result<ConfigurationResponse>.Failure("configuration.validation", e.Message); }
    }
    public async Task<Result<ConfigurationResponse>> UpdateAsync(Guid id, UpdateConfigurationRequest request, string correlationId, CancellationToken ct)
    {
        var item = await store.GetAsync(id, ct); if (item is null) return NotFound();
        try { item.Update((ConfigurationCategory)request.Category, request.ValueJson, clock.UtcNow); }
        catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException) { return Result<ConfigurationResponse>.Failure("configuration.validation", e.Message); }
        await store.SaveChangesAsync(ct); await Changed(item, "Changed", correlationId, ct); return Result<ConfigurationResponse>.Success(Map(item));
    }
    public async Task<Result<ConfigurationResponse>> SetActiveAsync(Guid id, bool active, string correlationId, CancellationToken ct)
    {
        var item = await store.GetAsync(id, ct); if (item is null) return NotFound();
        if (active) item.Activate(clock.UtcNow); else item.Deactivate(clock.UtcNow);
        await store.SaveChangesAsync(ct); await Changed(item, active ? "Activated" : "Deactivated", correlationId, ct);
        return Result<ConfigurationResponse>.Success(Map(item));
    }
    public async Task<Result<EffectiveConfigurationResponse>> ResolveAsync(string key, string? module, Guid? user, CancellationToken ct)
    {
        var candidates = await store.FindCandidatesAsync("default", key.ToLowerInvariant(), module?.ToLowerInvariant(), user, ct);
        var item = candidates.Where(x => x.IsActive).OrderByDescending(x => x.Scope).ThenByDescending(x => x.Version).FirstOrDefault();
        return item is null ? Result<EffectiveConfigurationResponse>.Failure("configuration.not_found", "No active configuration matched.") :
            Result<EffectiveConfigurationResponse>.Success(new(item.Key, item.ValueJson, (int)item.Scope, item.Version));
    }
    public async Task<Result<IReadOnlyCollection<ConfigurationResponse>>> GetScopeAsync(int scope, string? module, Guid? user, CancellationToken ct)
    { var items = await store.GetByScopeAsync((ConfigurationScope)scope, "default", module, user, ct); return Result<IReadOnlyCollection<ConfigurationResponse>>.Success(items.Select(Map).ToArray()); }
    private Task Changed(ConfigurationItem item, string type, string correlationId, CancellationToken ct) => recorder.RecordAsync("configuration", type.ToLowerInvariant(), item.Id.ToString(), new ConfigurationChangedV1(item.Id, item.Key, item.Version, type, correlationId), correlationId, ct);
    private static Result<ConfigurationResponse> NotFound() => Result<ConfigurationResponse>.Failure("configuration.not_found", "Configuration item was not found.");
    private static ConfigurationResponse Map(ConfigurationItem x) => new(x.Id, x.Key, (int)x.Scope, x.TenantId, x.ModuleCode, x.UserId, (int)x.Category, x.ValueJson, x.Version, x.IsActive);
}
