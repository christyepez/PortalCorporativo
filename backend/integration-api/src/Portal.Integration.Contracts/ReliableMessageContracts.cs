namespace Portal.Integration.Contracts;

public sealed record IntegrationEventEnvelopeV1(Guid MessageId, string TenantId, string AggregateType, string AggregateId,
    string EventType, string PayloadJson, string? HeadersJson, string CorrelationId, string? CausationId,
    string? IdempotencyKey, DateTimeOffset OccurredAtUtc);

public sealed record EnqueueOutboxRequest(string? TenantId, string AggregateType, string AggregateId, string EventType,
    string PayloadJson, string? HeadersJson, string CorrelationId, string? CausationId, string? IdempotencyKey);

public sealed record RegisterInboxRequest(string? TenantId, string Source, string EventType, string PayloadJson,
    string? HeadersJson, string CorrelationId, string IdempotencyKey);

public sealed record MessageRegistrationResponse(Guid MessageId, bool Duplicate, string Status);
public sealed record OutboxMessageStatusResponse(Guid MessageId, string TenantId, string EventType, string Status, int Attempts, DateTimeOffset? ProcessedAtUtc, string? LastError);

public sealed record OutboxStatusResponse(
    Guid MessageId,
    string TenantId,
    string? IdempotencyKey,
    string Status,
    int Attempts,
    DateTimeOffset CreatedAtUtc,
    DateTimeOffset? ProcessedAtUtc,
    DateTimeOffset? NextRetryAtUtc,
    string? LastError);
