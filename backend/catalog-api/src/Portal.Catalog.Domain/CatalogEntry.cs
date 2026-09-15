namespace Portal.Catalog.Domain;

public sealed class CatalogEntry
{
    public Guid Id { get; private set; }
    public string Catalog { get; private set; }
    public string Code { get; private set; }
    public string Name { get; private set; }
    public string? Description { get; private set; }
    public bool IsActive { get; private set; }
    public int SortOrder { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public DateTimeOffset UpdatedAt { get; private set; }

    private CatalogEntry(Guid id, string catalog, string code, string name, string? description, bool isActive, int sortOrder, DateTimeOffset createdAt, DateTimeOffset updatedAt)
    {
        Id = id;
        Catalog = catalog;
        Code = code;
        Name = name;
        Description = description;
        IsActive = isActive;
        SortOrder = sortOrder;
        CreatedAt = createdAt;
        UpdatedAt = updatedAt;
    }

    public static CatalogEntry Create(string catalog, string code, string name, string? description, int sortOrder, DateTimeOffset now)
    {
        Validate(catalog, code, name, sortOrder);
        return new CatalogEntry(Guid.NewGuid(), catalog.Trim(), code.Trim(), name.Trim(), Normalize(description), true, sortOrder, now, now);
    }

    public void Update(string name, string? description, bool isActive, int sortOrder, DateTimeOffset now)
    {
        Validate(Catalog, Code, name, sortOrder);
        Name = name.Trim();
        Description = Normalize(description);
        IsActive = isActive;
        SortOrder = sortOrder;
        UpdatedAt = now;
    }

    private static void Validate(string catalog, string code, string name, int sortOrder)
    {
        if (string.IsNullOrWhiteSpace(catalog) || catalog.Trim().Length > 80) throw new ArgumentException("Catalog is required and must be <= 80 characters.", nameof(catalog));
        if (string.IsNullOrWhiteSpace(code) || code.Trim().Length > 80) throw new ArgumentException("Code is required and must be <= 80 characters.", nameof(code));
        if (string.IsNullOrWhiteSpace(name) || name.Trim().Length > 160) throw new ArgumentException("Name is required and must be <= 160 characters.", nameof(name));
        if (sortOrder < 0) throw new ArgumentOutOfRangeException(nameof(sortOrder));
    }

    private static string? Normalize(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
