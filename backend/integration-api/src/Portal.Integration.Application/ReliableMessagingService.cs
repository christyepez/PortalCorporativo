using Portal.BuildingBlocks;
using Portal.Integration.Contracts;
using Portal.Integration.Domain;

namespace Portal.Integration.Application;

public interface IReliableMessageStore
{
    Task<OutboxMessage?> FindOutboxByIdempotencyKeyAsync(string tenantId, string key, CancellationToken ct);
    Task<InboxMessage?> FindInboxAsync(string tenantId, string source, string key, CancellationToken ct);
    Task<IReadOnlyCollection<OutboxMessage>> GetPendingAsync(DateTimeOffset now, int batchSize, CancellationToken ct);
    Task AddAsync<T>(T entity, CancellationToken ct) where T : class;
    Task SaveChangesAsync(CancellationToken ct);
}

public interface IEventPublisher
{
    Task PublishAsync(IntegrationEventEnvelopeV1 message, CancellationToken cancellationToken);
}

public sealed class ReliableMessagingService(IReliableMessageStore store, IClock clock)
{
    public async Task<Result<MessageRegistrationResponse>> EnqueueAsync(EnqueueOutboxRequest request, CancellationToken ct)
    {
        var tenant = request.TenantId ?? "default";
        if (!string.IsNullOrWhiteSpace(request.IdempotencyKey))
        {
            var existing = await store.FindOutboxByIdempotencyKeyAsync(tenant, request.IdempotencyKey, ct);
            if (existing is not null) return Result<MessageRegistrationResponse>.Success(new(existing.MessageId, true, existing.Status.ToString()));
        }
        try
        {
            var message = OutboxMessage.Enqueue(tenant, request.AggregateType, request.AggregateId, request.EventType,
                request.PayloadJson, request.HeadersJson, request.CorrelationId, request.CausationId, request.IdempotencyKey, clock.UtcNow);
            await store.AddAsync(message, ct); await store.SaveChangesAsync(ct);
            return Result<MessageRegistrationResponse>.Success(new(message.MessageId, false, message.Status.ToString()));
        }
        catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException)
        { return Result<MessageRegistrationResponse>.Failure("outbox.validation", e.Message); }
    }

    public async Task<Result<MessageRegistrationResponse>> RegisterIncomingAsync(RegisterInboxRequest request, CancellationToken ct)
    {
        var tenant = request.TenantId ?? "default";
        var existing = await store.FindInboxAsync(tenant, request.Source, request.IdempotencyKey, ct);
        if (existing is not null) return Result<MessageRegistrationResponse>.Success(new(existing.MessageId, true, existing.Status.ToString()));
        try
        {
            var message = InboxMessage.Register(tenant, request.Source, request.EventType, request.PayloadJson,
                request.HeadersJson, request.CorrelationId, request.IdempotencyKey, clock.UtcNow);
            await store.AddAsync(message, ct); await store.SaveChangesAsync(ct);
            return Result<MessageRegistrationResponse>.Success(new(message.MessageId, false, message.Status.ToString()));
        }
        catch (Exception e) when (e is ArgumentException or System.Text.Json.JsonException)
        { return Result<MessageRegistrationResponse>.Failure("inbox.validation", e.Message); }
    }

    public async Task<bool> CheckAlreadyProcessedAsync(string tenantId, string source, string key, CancellationToken ct) =>
        (await store.FindInboxAsync(tenantId, source, key, ct))?.Status == MessageStatus.Processed;
    public async Task MarkInboxProcessedAsync(InboxMessage message, CancellationToken ct) { message.MarkProcessed(clock.UtcNow); await store.SaveChangesAsync(ct); }
    public async Task MarkInboxFailedAsync(InboxMessage message, string error, CancellationToken ct) { message.MarkFailed(error); await store.SaveChangesAsync(ct); }
}

public sealed class OutboxProcessor(IReliableMessageStore store, IEventPublisher publisher, IClock clock)
{
    public async Task<int> ProcessBatchAsync(int batchSize, int maxAttempts, TimeSpan baseDelay, CancellationToken ct)
    {
        var messages = await store.GetPendingAsync(clock.UtcNow, Math.Clamp(batchSize, 1, 500), ct);
        foreach (var message in messages)
        {
            message.MarkProcessing(); await store.SaveChangesAsync(ct);
            try
            {
                await publisher.PublishAsync(new(message.MessageId, message.TenantId, message.AggregateType, message.AggregateId,
                    message.EventType, message.PayloadJson, message.HeadersJson, message.CorrelationId, message.CausationId,
                    message.IdempotencyKey, message.CreatedAtUtc), ct);
                message.MarkProcessed(clock.UtcNow);
            }
            catch (Exception exception)
            {
                var multiplier = Math.Pow(2, Math.Max(0, message.Attempts - 1));
                message.MarkFailed(exception.Message, clock.UtcNow, maxAttempts, TimeSpan.FromMilliseconds(baseDelay.TotalMilliseconds * multiplier));
            }
            await store.SaveChangesAsync(ct);
        }
        return messages.Count;
    }
}
