using Portal.Audit.Application;
using Portal.Audit.Contracts;
using Portal.BuildingBlocks;

namespace Portal.Audit.Api;

public static class AuditEndpoints
{
    public static IEndpointRouteBuilder MapAuditEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/audit/events").RequireAuthorization();
        group.MapPost("/", async (CreateAuditEventRequest request, AuditService service, HttpContext context, CancellationToken ct) =>
            Respond(context, await service.CreateAsync(request, context.TraceIdentifier, ct), 201)).RequireAuthorization(PortalPermissions.AuditWrite);
        group.MapGet("/{id:guid}", async (Guid id, AuditService service, HttpContext context, CancellationToken ct) =>
            Respond(context, await service.GetAsync(id, ct))).RequireAuthorization(PortalPermissions.AuditRead);
        group.MapGet("/", async (string? tenantId, string? resource, string? action, string? actorId,
            DateTimeOffset? fromUtc, DateTimeOffset? toUtc, int? severity, int page, int pageSize,
            AuditService service, HttpContext context, CancellationToken ct) =>
            Respond(context, await service.SearchAsync(new(tenantId, resource, action, actorId, fromUtc, toUtc, severity,
                page == 0 ? 1 : page, pageSize == 0 ? 20 : pageSize), ct))).RequireAuthorization(PortalPermissions.AuditRead);
        return endpoints;
    }

    private static IResult Respond<T>(HttpContext context, Result<T> result, int status = 200) => result.IsSuccess
        ? Results.Json(new ApiResponse<T>(result.Value, null, context.TraceIdentifier), statusCode: status)
        : Results.Json(new ApiResponse<T>(default, result.Error, context.TraceIdentifier), statusCode:
            result.Error!.Code.EndsWith("not_found", StringComparison.Ordinal) ? 404 : 400);
}
