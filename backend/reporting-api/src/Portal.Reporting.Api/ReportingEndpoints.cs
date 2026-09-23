using Portal.BuildingBlocks;
using Portal.Reporting.Application;
using Portal.Reporting.Contracts;

namespace Portal.Reporting.Api;

public static class ReportingEndpoints
{
    public static IEndpointRouteBuilder MapReportingEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/reporting").RequireAuthorization();

        group.MapGet("/reports", async (ReportingService service, CancellationToken cancellationToken)
            => Results.Ok(await service.ListAsync(cancellationToken)))
            .RequireAuthorization(PortalPermissions.ReportingRead);

        group.MapGet("/reports/{key}", async (string key, ReportingService service, CancellationToken cancellationToken)
            => await service.GetAsync(key, cancellationToken) is { } report ? Results.Ok(report) : Results.NotFound())
            .RequireAuthorization(PortalPermissions.ReportingRead);

        group.MapPost("/reports/{key}/execute", async (string key, ExecuteReportRequest request, ReportingService service, IPortalTenantContext tenantContext, CancellationToken cancellationToken) =>
        {
            try
            {
                return await service.ExecuteAsync(tenantContext.TenantId, key, request, cancellationToken) is { } result ? Results.Ok(result) : Results.NotFound();
            }
            catch (ArgumentException ex) { return Results.BadRequest(new { error = ex.Message }); }
        }).RequireAuthorization(PortalPermissions.ReportingRead);

        return endpoints;
    }
}
