namespace Portal.Catalog.Contracts;

public sealed record CatalogEntryDto(
    Guid Id,
    string Catalog,
    string Code,
    string Name,
    string? Description,
    bool IsActive,
    int SortOrder,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);

public sealed record CreateCatalogEntryRequest(
    string Catalog,
    string Code,
    string Name,
    string? Description,
    int SortOrder = 0);

public sealed record UpdateCatalogEntryRequest(
    string Name,
    string? Description,
    bool IsActive,
    int SortOrder = 0);
