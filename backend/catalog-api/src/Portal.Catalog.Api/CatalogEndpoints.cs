using Portal.BuildingBlocks;
using Portal.Catalog.Application;
using Portal.Catalog.Contracts;

namespace Portal.Catalog.Api;

public static class CatalogEndpoints
{
    public static IEndpointRouteBuilder MapCatalogEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/catalog").RequireAuthorization();

        group.MapGet("/entries", async (string? catalog, bool? isActive, CatalogService service, IPortalTenantContext tenantContext, CancellationToken cancellationToken)
            => Results.Ok(await service.ListAsync(tenantContext.TenantId, catalog, isActive, cancellationToken)))
            .RequireAuthorization(PortalPermissions.CatalogRead);

        group.MapGet("/entries/{id:guid}", async (Guid id, CatalogService service, IPortalTenantContext tenantContext, CancellationToken cancellationToken)
            => await service.GetAsync(tenantContext.TenantId, id, cancellationToken) is { } entry ? Results.Ok(entry) : Results.NotFound())
            .RequireAuthorization(PortalPermissions.CatalogRead);

        group.MapPost("/entries", async (CreateCatalogEntryRequest request, CatalogService service, IPortalTenantContext tenantContext, CancellationToken cancellationToken) =>
        {
            try
            {
                var entry = await service.CreateAsync(tenantContext.TenantId, request, cancellationToken);
                return Results.Created($"/api/catalog/entries/{entry.Id}", entry);
            }
            catch (ArgumentException ex) { return Results.BadRequest(new { error = ex.Message }); }
            catch (InvalidOperationException ex) { return Results.Conflict(new { error = ex.Message }); }
        }).RequireAuthorization(PortalPermissions.CatalogManage);

        group.MapPut("/entries/{id:guid}", async (Guid id, UpdateCatalogEntryRequest request, CatalogService service, IPortalTenantContext tenantContext, CancellationToken cancellationToken) =>
        {
            try
            {
                return await service.UpdateAsync(tenantContext.TenantId, id, request, cancellationToken) is { } entry ? Results.Ok(entry) : Results.NotFound();
            }
            catch (ArgumentException ex) { return Results.BadRequest(new { error = ex.Message }); }
        }).RequireAuthorization(PortalPermissions.CatalogManage);

        return endpoints;
    }
}
