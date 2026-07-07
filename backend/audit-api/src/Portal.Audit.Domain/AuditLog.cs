namespace Portal.Audit.Domain;

public enum AuditSeverity { Information = 0, Warning = 1, Error = 2, Critical = 3 }

public sealed class AuditLog
{
    private AuditLog() { }
    private AuditLog(Guid id, string actorId, string tenantId, string resource, string action,
        string entityName, string? entityId, string? beforeJson, string? afterJson, string? metadataJson,
        string correlationId, string? causationId, string? requestId, string? ipAddress, string? userAgent,
        AuditSeverity severity, DateTimeOffset createdAtUtc)
    {
        Id = id;
        ActorId = Required(actorId, nameof(actorId), 160);
        TenantId = Required(tenantId, nameof(tenantId), 64).ToLowerInvariant();
        Resource = Required(resource, nameof(resource), 160).ToLowerInvariant();
        Action = Required(action, nameof(action), 80).ToLowerInvariant();
        EntityName = Required(entityName, nameof(entityName), 160);
        EntityId = Optional(entityId, 160);
        BeforeJson = AuditRedactor.RedactJson(beforeJson);
        AfterJson = AuditRedactor.RedactJson(afterJson);
        MetadataJson = AuditRedactor.RedactJson(metadataJson);
        CorrelationId = Required(correlationId, nameof(correlationId), 128);
        CausationId = Optional(causationId, 128);
        RequestId = Optional(requestId, 128);
        IpAddress = Optional(ipAddress, 64);
        UserAgent = Optional(userAgent, 512);
        Severity = severity;
        CreatedAtUtc = createdAtUtc;
    }

    public Guid Id { get; private set; }
    public string ActorId { get; private set; } = null!;
    public string TenantId { get; private set; } = null!;
    public string Resource { get; private set; } = null!;
    public string Action { get; private set; } = null!;
    public string EntityName { get; private set; } = null!;
    public string? EntityId { get; private set; }
    public string? BeforeJson { get; private set; }
    public string? AfterJson { get; private set; }
    public string? MetadataJson { get; private set; }
    public string CorrelationId { get; private set; } = null!;
    public string? CausationId { get; private set; }
    public string? RequestId { get; private set; }
    public string? IpAddress { get; private set; }
    public string? UserAgent { get; private set; }
    public AuditSeverity Severity { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; }

    public static AuditLog Create(string actorId, string tenantId, string resource, string action,
        string entityName, string? entityId, string? beforeJson, string? afterJson, string? metadataJson,
        string correlationId, string? causationId, string? requestId, string? ipAddress, string? userAgent,
        AuditSeverity severity, DateTimeOffset createdAtUtc) =>
        new(Guid.NewGuid(), actorId, tenantId, resource, action, entityName, entityId, beforeJson, afterJson,
            metadataJson, correlationId, causationId, requestId, ipAddress, userAgent, severity, createdAtUtc);

    private static string Required(string value, string field, int max) =>
        string.IsNullOrWhiteSpace(value) ? throw new ArgumentException($"{field} is required.", field) :
        value.Trim().Length > max ? throw new ArgumentException($"{field} is too long.", field) : value.Trim();
    private static string? Optional(string? value, int max) => string.IsNullOrWhiteSpace(value) ? null :
        value.Trim().Length > max ? throw new ArgumentException("Optional value is too long.") : value.Trim();
}
