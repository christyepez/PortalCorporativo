using Portal.Audit.Contracts;
using Portal.Audit.Domain;
using Portal.BuildingBlocks;

namespace Portal.Audit.Application;

public interface IAuditStore
{
    Task AddAsync(AuditLog auditLog, CancellationToken cancellationToken);
    Task<AuditLog?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task<PagedResult<AuditLog>> SearchAsync(AuditSearchRequest request, CancellationToken cancellationToken);
    Task<AuditSummaryResponse> SummaryAsync(string tenantId, DateTimeOffset fromUtc, DateTimeOffset toUtc, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}

public sealed class AuditService(IAuditStore store, IClock clock, IPortalTenantContext tenantContext)
{
    public async Task<Result<AuditEventResponse>> CreateAsync(CreateAuditEventRequest request, string fallbackCorrelationId, CancellationToken ct)
    {
        AuditLog audit;
        try
        {
            if (!string.IsNullOrWhiteSpace(request.TenantId) && !string.Equals(request.TenantId.Trim(), tenantContext.TenantId, StringComparison.OrdinalIgnoreCase))
                return Result<AuditEventResponse>.Failure("audit.tenant_mismatch", "Request tenant does not match the authenticated tenant.");
            audit = AuditLog.Create(request.ActorId, tenantContext.TenantId, request.Resource, request.Action,
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
        var audit = await store.GetAsync(tenantContext.TenantId, id, ct);
        return audit is null ? Result<AuditEventResponse>.Failure("audit.not_found", "Audit event was not found.") :
            Result<AuditEventResponse>.Success(Map(audit));
    }

    public async Task<Result<PagedResult<AuditEventResponse>>> SearchAsync(AuditSearchRequest request, CancellationToken ct)
    {
        if (request.FromUtc > request.ToUtc) return Result<PagedResult<AuditEventResponse>>.Failure("audit.validation", "fromUtc must be before toUtc.");
        if (!string.IsNullOrWhiteSpace(request.TenantId) && !string.Equals(request.TenantId.Trim(), tenantContext.TenantId, StringComparison.OrdinalIgnoreCase))
            return Result<PagedResult<AuditEventResponse>>.Failure("audit.tenant_mismatch", "Request tenant does not match the authenticated tenant.");
        var page = await store.SearchAsync(request with { TenantId = tenantContext.TenantId, Page = Math.Max(1, request.Page), PageSize = Math.Clamp(request.PageSize, 1, 200) }, ct);
        return Result<PagedResult<AuditEventResponse>>.Success(new(page.Items.Select(Map).ToArray(), page.Page, page.PageSize, page.Total));
    }

    public async Task<Result<AuditSummaryResponse>> SummaryAsync(string? tenantId, int hours, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(tenantId) && !string.Equals(tenantId.Trim(), tenantContext.TenantId, StringComparison.OrdinalIgnoreCase))
            return Result<AuditSummaryResponse>.Failure("audit.tenant_mismatch", "Request tenant does not match the authenticated tenant.");
        var normalizedTenant = tenantContext.TenantId;

        hours = Math.Clamp(hours, 1, 24 * 30);
        var toUtc = clock.UtcNow;
        var fromUtc = toUtc.AddHours(-hours);
        return Result<AuditSummaryResponse>.Success(await store.SummaryAsync(normalizedTenant, fromUtc, toUtc, ct));
    }

    private static AuditEventResponse Map(AuditLog x) => new(x.Id, x.ActorId, x.TenantId, x.Resource, x.Action,
        x.EntityName, x.EntityId, x.BeforeJson, x.AfterJson, x.MetadataJson, x.CorrelationId, x.CausationId,
        x.RequestId, x.IpAddress, x.UserAgent, (int)x.Severity, x.CreatedAtUtc);
}
