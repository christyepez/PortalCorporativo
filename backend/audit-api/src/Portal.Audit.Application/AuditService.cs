using Portal.Audit.Contracts;
using Portal.Audit.Domain;
using Portal.BuildingBlocks;

namespace Portal.Audit.Application;

public interface IAuditStore
{
    Task AddAsync(AuditLog auditLog, CancellationToken cancellationToken);
    Task<AuditLog?> GetAsync(Guid id, CancellationToken cancellationToken);
    Task<PagedResult<AuditLog>> SearchAsync(AuditSearchRequest request, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}

public sealed class AuditService(IAuditStore store, IClock clock)
{
    public async Task<Result<AuditEventResponse>> CreateAsync(CreateAuditEventRequest request, string fallbackCorrelationId, CancellationToken ct)
    {
        AuditLog audit;
        try
        {
            audit = AuditLog.Create(request.ActorId, request.TenantId ?? "default", request.Resource, request.Action,
                request.EntityName, request.EntityId, request.BeforeJson, request.AfterJson, request.MetadataJson,
                request.CorrelationId ?? fallbackCorrelationId, request.CausationId, request.RequestId,
                request.IpAddress, request.UserAgent, Enum.IsDefined(typeof(AuditSeverity), request.Severity)
                    ? (AuditSeverity)request.Severity : throw new ArgumentException("severity is invalid."), clock.UtcNow);
        }
        catch (ArgumentException exception) { return Result<AuditEventResponse>.Failure("audit.validation", exception.Message); }

        await store.AddAsync(audit, ct);
        await store.SaveChangesAsync(ct);
        return Result<AuditEventResponse>.Success(Map(audit));
    }

    public async Task<Result<AuditEventResponse>> GetAsync(Guid id, CancellationToken ct)
    {
        var audit = await store.GetAsync(id, ct);
        return audit is null ? Result<AuditEventResponse>.Failure("audit.not_found", "Audit event was not found.") :
            Result<AuditEventResponse>.Success(Map(audit));
    }

    public async Task<Result<PagedResult<AuditEventResponse>>> SearchAsync(AuditSearchRequest request, CancellationToken ct)
    {
        if (request.FromUtc > request.ToUtc) return Result<PagedResult<AuditEventResponse>>.Failure("audit.validation", "fromUtc must be before toUtc.");
        var page = await store.SearchAsync(request with { Page = Math.Max(1, request.Page), PageSize = Math.Clamp(request.PageSize, 1, 200) }, ct);
        return Result<PagedResult<AuditEventResponse>>.Success(new(page.Items.Select(Map).ToArray(), page.Page, page.PageSize, page.Total));
    }

    private static AuditEventResponse Map(AuditLog x) => new(x.Id, x.ActorId, x.TenantId, x.Resource, x.Action,
        x.EntityName, x.EntityId, x.BeforeJson, x.AfterJson, x.MetadataJson, x.CorrelationId, x.CausationId,
        x.RequestId, x.IpAddress, x.UserAgent, (int)x.Severity, x.CreatedAtUtc);
}
