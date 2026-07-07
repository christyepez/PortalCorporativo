using Microsoft.EntityFrameworkCore;
using Portal.Audit.Application;
using Portal.Audit.Contracts;
using Portal.Audit.Domain;
using Portal.Audit.Infrastructure;
using Portal.BuildingBlocks;
using Portal.Integration.Application;
using Portal.Integration.Contracts;
using Portal.Integration.Domain;
using Xunit;

namespace Portal.Reliability.UnitTests;

public sealed class AuditTests
{
    [Fact]
    public void Redacts_sensitive_fields_recursively()
    {
        var redacted = AuditRedactor.RedactJson("{\"email\":\"a@b.com\",\"nested\":{\"token\":\"abc\"},\"safe\":1}");
        Assert.DoesNotContain("a@b.com", redacted); Assert.DoesNotContain("abc", redacted); Assert.Contains("[REDACTED]", redacted);
    }

    [Fact]
    public async Task Audit_store_rejects_updates_and_deletes()
    {
        await using var db = Context();
        var audit = CreateAudit("portal.audit", "read", AuditSeverity.Information);
        db.Add(audit); await db.SaveChangesAsync();
        db.Entry(audit).State = EntityState.Modified;
        await Assert.ThrowsAsync<InvalidOperationException>(() => db.SaveChangesAsync());
    }

    [Fact]
    public async Task Audit_search_applies_resource_action_and_severity_filters()
    {
        await using var db = Context();
        db.AddRange(CreateAudit("portal.audit", "read", AuditSeverity.Information), CreateAudit("portal.security", "manage", AuditSeverity.Warning));
        await db.SaveChangesAsync();
        var store = new EfAuditStore(db);
        var page = await store.SearchAsync(new("default", "portal.security", "manage", null, null, null, 1, 1, 20), default);
        Assert.Single(page.Items); Assert.Equal("portal.security", page.Items.Single().Resource);
    }

    private static AuditDbContext Context() => new(new DbContextOptionsBuilder<AuditDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
    private static AuditLog CreateAudit(string resource, string action, AuditSeverity severity) =>
        AuditLog.Create("actor", "default", resource, action, "Entity", "1", null, "{}", null, "corr", null, null, null, null, severity, DateTimeOffset.UtcNow);
}

public sealed class MessagingTests
{
    [Fact]
    public async Task Outbox_enqueue_is_idempotent()
    {
        var store = new MemoryStore(); var service = new ReliableMessagingService(store, store.Clock);
        var request = new EnqueueOutboxRequest(null, "Order", "1", "OrderCreatedV1", "{}", null, "corr", null, "key-1");
        var first = await service.EnqueueAsync(request, default); var second = await service.EnqueueAsync(request, default);
        Assert.False(first.Value!.Duplicate); Assert.True(second.Value!.Duplicate); Assert.Single(store.Outbox);
    }

    [Fact]
    public async Task Outbox_processor_marks_successful_message_processed()
    {
        var store = new MemoryStore(); var service = new ReliableMessagingService(store, store.Clock);
        await service.EnqueueAsync(new(null, "Order", "1", "Created", "{}", null, "corr", null, "k"), default);
        await new OutboxProcessor(store, new Publisher(false), store.Clock).ProcessBatchAsync(10, 3, TimeSpan.FromSeconds(1), default);
        Assert.Equal(MessageStatus.Processed, store.Outbox.Single().Status);
    }

    [Fact]
    public async Task Outbox_retries_then_moves_to_dead_letter()
    {
        var store = new MemoryStore(); var service = new ReliableMessagingService(store, store.Clock);
        await service.EnqueueAsync(new(null, "Order", "1", "Created", "{}", null, "corr", null, "k"), default);
        var processor = new OutboxProcessor(store, new Publisher(true), store.Clock);
        await processor.ProcessBatchAsync(10, 2, TimeSpan.FromSeconds(1), default);
        Assert.Equal(MessageStatus.Failed, store.Outbox.Single().Status);
        store.Clock.Now = store.Clock.Now.AddSeconds(2);
        await processor.ProcessBatchAsync(10, 2, TimeSpan.FromSeconds(1), default);
        Assert.Equal(MessageStatus.DeadLetter, store.Outbox.Single().Status);
    }

    [Fact]
    public async Task Inbox_detects_duplicate_source_and_key()
    {
        var store = new MemoryStore(); var service = new ReliableMessagingService(store, store.Clock);
        var request = new RegisterInboxRequest(null, "crm", "CustomerChangedV1", "{}", null, "corr", "same");
        var first = await service.RegisterIncomingAsync(request, default); var duplicate = await service.RegisterIncomingAsync(request, default);
        Assert.False(first.Value!.Duplicate); Assert.True(duplicate.Value!.Duplicate); Assert.Single(store.Inbox);
    }

    [Fact]
    public async Task Inbox_reports_processed_idempotency_key()
    {
        var store = new MemoryStore(); var service = new ReliableMessagingService(store, store.Clock);
        await service.RegisterIncomingAsync(new(null, "finance", "PostedV1", "{}", null, "corr", "same"), default);
        await service.MarkInboxProcessedAsync(store.Inbox.Single(), default);
        Assert.True(await service.CheckAlreadyProcessedAsync("default", "finance", "same", default));
    }

    private sealed class Publisher(bool fail) : IEventPublisher
    { public Task PublishAsync(IntegrationEventEnvelopeV1 message, CancellationToken cancellationToken) => fail ? Task.FromException(new InvalidOperationException("failure")) : Task.CompletedTask; }

    private sealed class TestClock : IClock { public DateTimeOffset Now { get; set; } = DateTimeOffset.UtcNow; public DateTimeOffset UtcNow => Now; }
    private sealed class MemoryStore : IReliableMessageStore
    {
        public TestClock Clock { get; } = new(); public List<OutboxMessage> Outbox { get; } = []; public List<InboxMessage> Inbox { get; } = [];
        public Task<OutboxMessage?> FindOutboxByIdempotencyKeyAsync(string tenantId, string key, CancellationToken ct) => Task.FromResult(Outbox.SingleOrDefault(x => x.TenantId == tenantId && x.IdempotencyKey == key));
        public Task<InboxMessage?> FindInboxAsync(string tenantId, string source, string key, CancellationToken ct) => Task.FromResult(Inbox.SingleOrDefault(x => x.TenantId == tenantId && x.Source == source && x.IdempotencyKey == key));
        public Task<IReadOnlyCollection<OutboxMessage>> GetPendingAsync(DateTimeOffset now, int batchSize, CancellationToken ct) => Task.FromResult<IReadOnlyCollection<OutboxMessage>>(Outbox.Where(x => (x.Status is MessageStatus.Pending or MessageStatus.Failed) && x.NextRetryAtUtc <= now).Take(batchSize).ToArray());
        public Task AddAsync<T>(T entity, CancellationToken ct) where T : class { if (entity is OutboxMessage o) Outbox.Add(o); else if (entity is InboxMessage i) Inbox.Add(i); return Task.CompletedTask; }
        public Task SaveChangesAsync(CancellationToken ct) => Task.CompletedTask;
    }
}
