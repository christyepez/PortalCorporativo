namespace Portal.Audit.Contracts;

public sealed record CreateAuditEventRequest(string ActorId, string? TenantId, string Resource, string Action,
    string EntityName, string? EntityId, string? BeforeJson, string? AfterJson, string? MetadataJson,
    string? CorrelationId, string? CausationId, string? RequestId, string? IpAddress, string? UserAgent, int Severity);

public sealed record AuditEventResponse(Guid Id, string ActorId, string TenantId, string Resource, string Action,
    string EntityName, string? EntityId, string? BeforeJson, string? AfterJson, string? MetadataJson,
    string CorrelationId, string? CausationId, string? RequestId, string? IpAddress, string? UserAgent,
    int Severity, DateTimeOffset CreatedAtUtc);

public sealed record AuditSearchRequest(string? TenantId, string? Resource, string? Action, string? ActorId,
    DateTimeOffset? FromUtc, DateTimeOffset? ToUtc, int? Severity, int Page = 1, int PageSize = 20,
    string? CorrelationId = null);

public sealed record AuditMetricResponse(string Key, long Count);

public sealed record AuditSummaryResponse(
    string TenantId,
    DateTimeOffset FromUtc,
    DateTimeOffset ToUtc,
    long Total,
    long WarningOrHigher,
    long ErrorOrHigher,
    IReadOnlyCollection<AuditMetricResponse> TopResources,
    IReadOnlyCollection<AuditMetricResponse> TopActions);
