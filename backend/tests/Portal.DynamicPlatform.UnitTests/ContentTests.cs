using System.Security.Cryptography;
using Portal.Content.Application;
using Portal.Content.Contracts;
using Portal.Content.Domain;
using Xunit;

namespace Portal.DynamicPlatform.UnitTests;

public sealed class ContentTests
{
    [Fact]
    public async Task Create_computes_sha256_and_records_change()
    {
        var f = new Fixture();
        var bytes = "hello-content"u8.ToArray();
        var created = await f.Service.CreateAsync("tenant-a",
            new CreateContentDocumentRequest("portal", "a.txt", "text/plain", bytes),
            "corr-create", default);
        var expected = Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();
        Assert.Equal(expected, created.Sha256);
        Assert.Equal(bytes.Length, created.Length);
        Assert.Equal("created", f.Recorder.Changes.Single().Action);
    }

    [Fact]
    public async Task Create_rejects_content_over_10mb()
    {
        var f = new Fixture();
        var bytes = new byte[(10 * 1024 * 1024) + 1];
        await Assert.ThrowsAsync<ArgumentException>(() => f.Service.CreateAsync("tenant-a",
            new CreateContentDocumentRequest("portal", "large.bin", "application/octet-stream", bytes),
            "corr-large", default));
    }

    [Fact]
    public async Task Metadata_update_preserves_blob_length_and_hash()
    {
        var f = new Fixture();
        var created = await f.Service.CreateAsync("tenant-a",
            new CreateContentDocumentRequest("portal", "before.txt", "text/plain", "abc"u8.ToArray()),
            "corr-create", default);
        var updated = await f.Service.UpdateMetadataAsync("tenant-a", created.Id,
            new UpdateContentMetadataRequest("portal2", "after.txt", "text/markdown"),
            "corr-update", default);
        Assert.NotNull(updated);
        Assert.Equal(created.Length, updated!.Length);
        Assert.Equal(created.Sha256, updated.Sha256);
        Assert.Equal("metadata_updated", f.Recorder.Changes.Last().Action);
    }

    [Fact]
    public async Task Activate_and_deactivate_are_tenant_scoped_and_audited()
    {
        var f = new Fixture();
        var created = await f.Service.CreateAsync("tenant-a",
            new CreateContentDocumentRequest("portal", "state.txt", "text/plain", "state"u8.ToArray()),
            "corr-create", default);
        var off = await f.Service.SetActiveAsync("tenant-a", created.Id, false, "corr-off", default);
        Assert.False(off!.IsActive);
        Assert.Null(await f.Service.SetActiveAsync("tenant-b", created.Id, true, "corr-other", default));
        var on = await f.Service.SetActiveAsync("tenant-a", created.Id, true, "corr-on", default);
        Assert.True(on!.IsActive);
        Assert.Equal(new[] { "created", "deactivated", "activated" }, f.Recorder.Changes.Select(x => x.Action));
    }

    private sealed class Fixture
    {
        public Store Store { get; } = new();
        public Recorder Recorder { get; } = new();
        public ContentService Service { get; }
        public Fixture() => Service = new(Store, Recorder, TimeProvider.System);
    }

    private sealed class Recorder : IContentChangeRecorder
    {
        public List<(string Action, string CorrelationId)> Changes { get; } = [];
        public Task RecordAsync(string action, string entityId, object payload, string correlationId, CancellationToken cancellationToken)
        {
            Changes.Add((action, correlationId));
            return Task.CompletedTask;
        }
    }

    private sealed class Store : IContentRepository
    {
        private readonly Dictionary<Guid, StoredContent> items = [];

        public Task<IReadOnlyCollection<ContentDocument>> ListAsync(string tenantId, string? moduleCode, bool? isActive, CancellationToken cancellationToken)
        {
            var query = items.Values.Where(x => x.Document.TenantId == tenantId);
            if (!string.IsNullOrWhiteSpace(moduleCode)) query = query.Where(x => x.Document.ModuleCode == moduleCode);
            if (isActive.HasValue) query = query.Where(x => x.Document.IsActive == isActive.Value);
            return Task.FromResult<IReadOnlyCollection<ContentDocument>>(query.Select(x => x.Document).ToArray());
        }

        public Task<StoredContent?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken)
            => Task.FromResult(items.TryGetValue(id, out var stored) && stored.Document.TenantId == tenantId ? stored : null);

        public Task AddAsync(StoredContent content, CancellationToken cancellationToken)
        {
            items.Add(content.Document.Id, content);
            return Task.CompletedTask;
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }
}
