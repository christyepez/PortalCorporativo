using Xunit;
using Portal.Catalog.Application;
using Portal.Catalog.Contracts;
using Portal.Catalog.Domain;

namespace Portal.DynamicPlatform.UnitTests;

public sealed class CatalogTests
{
    [Fact]
    public async Task Create_records_structured_change()
    {
        var f = new Fixture();
        var created = await f.Service.CreateAsync("tenant-a", new("types", "one", "One", null, 1), "corr-1", default);
        Assert.Equal("one", created.Code);
        Assert.Equal("created", f.Recorder.Changes.Single().Action);
        Assert.Equal("corr-1", f.Recorder.Changes.Single().CorrelationId);
    }

    [Fact]
    public async Task Update_status_records_deactivated_change()
    {
        var f = new Fixture();
        var created = await f.Service.CreateAsync("tenant-a", new("types", "one", "One", null, 1), "corr-1", default);
        var updated = await f.Service.UpdateAsync("tenant-a", created.Id, new("One", null, false, 2), "corr-2", default);
        Assert.NotNull(updated);
        Assert.False(updated!.IsActive);
        Assert.Equal("deactivated", f.Recorder.Changes.Last().Action);
    }

    [Fact]
    public async Task Duplicate_catalog_code_is_rejected_per_tenant()
    {
        var f = new Fixture();
        await f.Service.CreateAsync("tenant-a", new("types", "one", "One", null, 0), "c1", default);
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            f.Service.CreateAsync("tenant-a", new("types", "one", "Duplicate", null, 0), "c2", default));
        var otherTenant = await f.Service.CreateAsync("tenant-b", new("types", "one", "Allowed", null, 0), "c3", default);
        Assert.Equal("tenant-b", f.Store.Items.Single(x => x.Id == otherTenant.Id).TenantId);
    }

    private sealed class Fixture
    {
        public Store Store { get; } = new();
        public Recorder Recorder { get; } = new();
        public CatalogService Service { get; }
        public Fixture() => Service = new(Store, Recorder, TimeProvider.System);
    }

    private sealed class Recorder : ICatalogChangeRecorder
    {
        public List<(string Action, string CorrelationId)> Changes { get; } = [];
        public Task RecordAsync(string action, string entityId, object payload, string correlationId, CancellationToken cancellationToken)
        { Changes.Add((action, correlationId)); return Task.CompletedTask; }
    }

    private sealed class Store : ICatalogRepository
    {
        public List<CatalogEntry> Items { get; } = [];
        public Task<IReadOnlyCollection<CatalogEntry>> ListAsync(string tenantId, string? catalog, bool? isActive, CancellationToken cancellationToken)
            => Task.FromResult<IReadOnlyCollection<CatalogEntry>>(Items.Where(x => x.TenantId == tenantId &&
                (catalog == null || x.Catalog == catalog) && (!isActive.HasValue || x.IsActive == isActive.Value)).ToArray());
        public Task<CatalogEntry?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken)
            => Task.FromResult(Items.SingleOrDefault(x => x.TenantId == tenantId && x.Id == id));
        public Task<CatalogEntry?> FindByCodeAsync(string tenantId, string catalog, string code, CancellationToken cancellationToken)
            => Task.FromResult(Items.SingleOrDefault(x => x.TenantId == tenantId && x.Catalog == catalog && x.Code == code));
        public Task AddAsync(CatalogEntry entry, CancellationToken cancellationToken)
        { Items.Add(entry); return Task.CompletedTask; }
        public Task SaveChangesAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }
}
