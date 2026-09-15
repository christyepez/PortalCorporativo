using Portal.BuildingBlocks;
using Portal.Content.Application;
using Portal.Content.Contracts;

namespace Portal.Content.Api;

public static class ContentEndpoints
{
    public static IEndpointRouteBuilder MapContentEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/content").RequireAuthorization();

        group.MapGet("/documents", async (string? moduleCode, bool? isActive, ContentService service, CancellationToken cancellationToken)
            => Results.Ok(await service.ListAsync(moduleCode, isActive, cancellationToken)))
            .RequireAuthorization(PortalPermissions.ContentRead);

        group.MapGet("/documents/{id:guid}", async (Guid id, ContentService service, CancellationToken cancellationToken)
            => await service.GetAsync(id, cancellationToken) is { } document ? Results.Ok(document) : Results.NotFound())
            .RequireAuthorization(PortalPermissions.ContentRead);

        group.MapGet("/documents/{id:guid}/download", async (Guid id, ContentService service, CancellationToken cancellationToken) =>
        {
            var stored = await service.DownloadAsync(id, cancellationToken);
            return stored is null || !stored.Document.IsActive
                ? Results.NotFound()
                : Results.File(stored.Bytes, stored.Document.ContentType, stored.Document.FileName);
        }).RequireAuthorization(PortalPermissions.ContentRead);

        group.MapPost("/documents", async (CreateContentDocumentRequest request, ContentService service, CancellationToken cancellationToken) =>
        {
            try
            {
                var document = await service.CreateAsync(request, cancellationToken);
                return Results.Created($"/api/content/documents/{document.Id}", document);
            }
            catch (ArgumentException ex) { return Results.BadRequest(new { error = ex.Message }); }
        }).RequireAuthorization(PortalPermissions.ContentManage);

        group.MapPost("/documents/{id:guid}/deactivate", async (Guid id, ContentService service, CancellationToken cancellationToken)
            => await service.DeactivateAsync(id, cancellationToken) ? Results.NoContent() : Results.NotFound())
            .RequireAuthorization(PortalPermissions.ContentManage);

        return endpoints;
    }
}
