using System.Collections.Concurrent;
using Portal.Catalog.Application;
using Portal.Catalog.Domain;

namespace Portal.Catalog.Infrastructure;

public sealed class InMemoryCatalogRepository : ICatalogRepository
{
    private readonly ConcurrentDictionary<Guid, CatalogEntry> _entries = new();

    public Task<IReadOnlyCollection<CatalogEntry>> ListAsync(string tenantId, string? catalog, bool? isActive, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        IEnumerable<CatalogEntry> query = _entries.Values.Where(x => x.TenantId == tenantId);
        if (!string.IsNullOrWhiteSpace(catalog)) query = query.Where(x => x.Catalog.Equals(catalog.Trim(), StringComparison.OrdinalIgnoreCase));
        if (isActive.HasValue) query = query.Where(x => x.IsActive == isActive.Value);
        return Task.FromResult<IReadOnlyCollection<CatalogEntry>>(query.OrderBy(x => x.Catalog).ThenBy(x => x.SortOrder).ThenBy(x => x.Name).ToArray());
    }

    public Task<CatalogEntry?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        _entries.TryGetValue(id, out var entry);
        return Task.FromResult(entry is not null && entry.TenantId == tenantId ? entry : null);
    }

    public Task<CatalogEntry?> FindByCodeAsync(string tenantId, string catalog, string code, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var entry = _entries.Values.FirstOrDefault(x =>
            x.TenantId == tenantId &&
            x.Catalog.Equals(catalog.Trim(), StringComparison.OrdinalIgnoreCase) &&
            x.Code.Equals(code.Trim(), StringComparison.OrdinalIgnoreCase));
        return Task.FromResult(entry);
    }

    public Task AddAsync(CatalogEntry entry, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!_entries.TryAdd(entry.Id, entry)) throw new InvalidOperationException("Catalog entry could not be added.");
        return Task.CompletedTask;
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.CompletedTask;
    }
}
