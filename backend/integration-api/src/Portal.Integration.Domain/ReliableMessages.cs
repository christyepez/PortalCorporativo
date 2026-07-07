namespace Portal.Integration.Domain;

public enum MessageStatus { Pending = 0, Processing = 1, Processed = 2, Failed = 3, DeadLetter = 4 }

public sealed class OutboxMessage
{
    private OutboxMessage() { }
    private OutboxMessage(Guid messageId, string tenantId, string aggregateType, string aggregateId, string eventType,
        string payloadJson, string? headersJson, string correlationId, string? causationId, string? idempotencyKey, DateTimeOffset now)
    {
        MessageId = messageId;
        TenantId = Required(tenantId, nameof(tenantId), 64);
        AggregateType = Required(aggregateType, nameof(aggregateType), 160);
        AggregateId = Required(aggregateId, nameof(aggregateId), 160);
        EventType = Required(eventType, nameof(eventType), 200);
        PayloadJson = RequiredJson(payloadJson, nameof(payloadJson));
        HeadersJson = OptionalJson(headersJson, nameof(headersJson));
        CorrelationId = Required(correlationId, nameof(correlationId), 128);
        CausationId = Optional(causationId, 128);
        IdempotencyKey = Optional(idempotencyKey, 200);
        Status = MessageStatus.Pending;
        CreatedAtUtc = now;
        NextRetryAtUtc = now;
    }

    public Guid MessageId { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string AggregateType { get; private set; } = null!;
    public string AggregateId { get; private set; } = null!;
    public string EventType { get; private set; } = null!;
    public string PayloadJson { get; private set; } = null!;
    public string? HeadersJson { get; private set; }
    public string CorrelationId { get; private set; } = null!;
    public string? CausationId { get; private set; }
    public string? IdempotencyKey { get; private set; }
    public MessageStatus Status { get; private set; }
    public int Attempts { get; private set; }
    public DateTimeOffset? NextRetryAtUtc { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; }
    public DateTimeOffset? ProcessedAtUtc { get; private set; }
    public string? LastError { get; private set; }

    public static OutboxMessage Enqueue(string tenantId, string aggregateType, string aggregateId, string eventType,
        string payloadJson, string? headersJson, string correlationId, string? causationId, string? idempotencyKey, DateTimeOffset now) =>
        new(Guid.NewGuid(), tenantId, aggregateType, aggregateId, eventType, payloadJson, headersJson, correlationId, causationId, idempotencyKey, now);

    public void MarkProcessing() { if (Status is not (MessageStatus.Pending or MessageStatus.Failed)) throw new InvalidOperationException("Message cannot be claimed."); Status = MessageStatus.Processing; Attempts++; }
    public void MarkProcessed(DateTimeOffset now) { if (Status != MessageStatus.Processing) throw new InvalidOperationException("Message is not processing."); Status = MessageStatus.Processed; ProcessedAtUtc = now; NextRetryAtUtc = null; LastError = null; }
    public void MarkFailed(string error, DateTimeOffset now, int maxAttempts, TimeSpan retryDelay)
    {
        if (Status != MessageStatus.Processing) throw new InvalidOperationException("Message is not processing.");
        LastError = Required(error, nameof(error), 2000);
        if (Attempts >= maxAttempts) { Status = MessageStatus.DeadLetter; NextRetryAtUtc = null; }
        else { Status = MessageStatus.Failed; NextRetryAtUtc = now.Add(retryDelay); }
    }
    public void MoveToDeadLetter(string error) { LastError = Required(error, nameof(error), 2000); Status = MessageStatus.DeadLetter; NextRetryAtUtc = null; }

    internal static string Required(string value, string field, int max) => string.IsNullOrWhiteSpace(value)
        ? throw new ArgumentException($"{field} is required.", field) : value.Trim().Length > max
        ? throw new ArgumentException($"{field} is too long.", field) : value.Trim();
    internal static string? Optional(string? value, int max) => string.IsNullOrWhiteSpace(value) ? null : value.Trim().Length > max ? throw new ArgumentException("Value is too long.") : value.Trim();
    internal static string RequiredJson(string value, string field) { System.Text.Json.JsonDocument.Parse(value); return Required(value, field, int.MaxValue); }
    internal static string? OptionalJson(string? value, string field) { if (string.IsNullOrWhiteSpace(value)) return null; System.Text.Json.JsonDocument.Parse(value); return value; }
}

public sealed class InboxMessage
{
    private InboxMessage() { }
    private InboxMessage(Guid messageId, string tenantId, string source, string eventType, string payloadJson,
        string? headersJson, string correlationId, string idempotencyKey, DateTimeOffset now)
    {
        MessageId = messageId; TenantId = OutboxMessage.Required(tenantId, nameof(tenantId), 64);
        Source = OutboxMessage.Required(source, nameof(source), 160); EventType = OutboxMessage.Required(eventType, nameof(eventType), 200);
        PayloadJson = OutboxMessage.RequiredJson(payloadJson, nameof(payloadJson)); HeadersJson = OutboxMessage.OptionalJson(headersJson, nameof(headersJson));
        CorrelationId = OutboxMessage.Required(correlationId, nameof(correlationId), 128);
        IdempotencyKey = OutboxMessage.Required(idempotencyKey, nameof(idempotencyKey), 200);
        Status = MessageStatus.Pending; ReceivedAtUtc = now;
    }
    public Guid MessageId { get; private set; }
    public string TenantId { get; private set; } = null!;
    public string Source { get; private set; } = null!;
    public string EventType { get; private set; } = null!;
    public string PayloadJson { get; private set; } = null!;
    public string? HeadersJson { get; private set; }
    public string CorrelationId { get; private set; } = null!;
    public string IdempotencyKey { get; private set; } = null!;
    public MessageStatus Status { get; private set; }
    public DateTimeOffset ReceivedAtUtc { get; private set; }
    public DateTimeOffset? ProcessedAtUtc { get; private set; }
    public string? LastError { get; private set; }
    public static InboxMessage Register(string tenantId, string source, string eventType, string payloadJson, string? headersJson,
        string correlationId, string idempotencyKey, DateTimeOffset now) => new(Guid.NewGuid(), tenantId, source, eventType, payloadJson, headersJson, correlationId, idempotencyKey, now);
    public void MarkProcessed(DateTimeOffset now) { Status = MessageStatus.Processed; ProcessedAtUtc = now; LastError = null; }
    public void MarkFailed(string error) { Status = MessageStatus.Failed; LastError = OutboxMessage.Required(error, nameof(error), 2000); }
}
