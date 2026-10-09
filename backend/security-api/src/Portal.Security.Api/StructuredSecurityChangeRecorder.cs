using Portal.Security.Application;

namespace Portal.Security.Api;

public sealed class StructuredSecurityChangeRecorder(
    ILogger<StructuredSecurityChangeRecorder> logger,
    IHttpContextAccessor httpContextAccessor) : ISecurityChangeRecorder
{
    public Task RecordAsync(string action, string entityId, object payload, CancellationToken cancellationToken)
    {
        var correlationId = httpContextAccessor.HttpContext?.TraceIdentifier ?? string.Empty;
        logger.LogInformation("Security change {Action} {EntityId} {CorrelationId} {@Payload}",
            action, entityId, correlationId, payload);
        return Task.CompletedTask;
    }
}
