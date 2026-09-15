using Portal.Catalog.Contracts;
using Portal.Catalog.Domain;

namespace Portal.Catalog.Application;

public interface ICatalogRepository
{
    Task<IReadOnlyCollection<CatalogEntry>> ListAsync(string? catalog, bool? isActive, CancellationToken cancellationToken);
    Task<CatalogEntry?> GetAsync(Guid id, CancellationToken cancellationToken);
    Task<CatalogEntry?> FindByCodeAsync(string catalog, string code, CancellationToken cancellationToken);
    Task AddAsync(CatalogEntry entry, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}

public sealed class CatalogService(ICatalogRepository repository, TimeProvider timeProvider)
{
    public async Task<IReadOnlyCollection<CatalogEntryDto>> ListAsync(string? catalog, bool? isActive, CancellationToken cancellationToken)
        => (await repository.ListAsync(catalog, isActive, cancellationToken)).Select(Map).ToArray();

    public async Task<CatalogEntryDto?> GetAsync(Guid id, CancellationToken cancellationToken)
        => (await repository.GetAsync(id, cancellationToken)) is { } entry ? Map(entry) : null;

    public async Task<CatalogEntryDto> CreateAsync(CreateCatalogEntryRequest request, CancellationToken cancellationToken)
    {
        if (await repository.FindByCodeAsync(request.Catalog, request.Code, cancellationToken) is not null)
            throw new InvalidOperationException("A catalog entry with the same catalog and code already exists.");

        var entry = CatalogEntry.Create(request.Catalog, request.Code, request.Name, request.Description, request.SortOrder, timeProvider.GetUtcNow());
        await repository.AddAsync(entry, cancellationToken);
        await repository.SaveChangesAsync(cancellationToken);
        return Map(entry);
    }

    public async Task<CatalogEntryDto?> UpdateAsync(Guid id, UpdateCatalogEntryRequest request, CancellationToken cancellationToken)
    {
        var entry = await repository.GetAsync(id, cancellationToken);
        if (entry is null) return null;

        entry.Update(request.Name, request.Description, request.IsActive, request.SortOrder, timeProvider.GetUtcNow());
        await repository.SaveChangesAsync(cancellationToken);
        return Map(entry);
    }

    private static CatalogEntryDto Map(CatalogEntry entry) => new(entry.Id, entry.Catalog, entry.Code, entry.Name, entry.Description, entry.IsActive, entry.SortOrder, entry.CreatedAt, entry.UpdatedAt);
}
