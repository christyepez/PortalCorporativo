using Portal.BuildingBlocks;
using Portal.Integration.Application;
using Portal.Integration.Contracts;

namespace Portal.Integration.Api;

public static class IntegrationEndpoints
{
    public static IEndpointRouteBuilder MapIntegrationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/integration").RequireAuthorization();

        group.MapPost("/outbox", async (EnqueueOutboxRequest request, ReliableMessagingService service, HttpContext httpContext, CancellationToken cancellationToken) =>
        {
            var result = await service.EnqueueAsync(request, cancellationToken);
            return Reply(httpContext, result, StatusCodes.Status202Accepted);
        }).RequireAuthorization(PortalPermissions.IntegrationManage);

        group.MapGet("/outbox/{messageId:guid}", async (Guid messageId, ReliableMessagingService service, CancellationToken cancellationToken) =>
        {
            var status = await service.GetOutboxStatusAsync(messageId, cancellationToken);
            return status is null ? Results.NotFound() : Results.Ok(status);
        }).RequireAuthorization(PortalPermissions.IntegrationRead);

        group.MapPost("/inbox", async (RegisterInboxRequest request, ReliableMessagingService service, HttpContext httpContext, CancellationToken cancellationToken) =>
        {
            var result = await service.RegisterIncomingAsync(request, cancellationToken);
            return Reply(httpContext, result, StatusCodes.Status202Accepted);
        }).RequireAuthorization(PortalPermissions.IntegrationManage);

        group.MapGet("/outbox/status", async (string? tenantId, string idempotencyKey, ReliableMessagingService service, CancellationToken cancellationToken) =>
        {
            var status = await service.GetOutboxStatusAsync(
                string.IsNullOrWhiteSpace(tenantId) ? "default" : tenantId,
                idempotencyKey,
                cancellationToken);
            return status is null ? Results.NotFound() : Results.Ok(status);
        }).RequireAuthorization(PortalPermissions.IntegrationRead);

        group.MapGet("/inbox/processed", async (string tenantId, string source, string idempotencyKey, ReliableMessagingService service, CancellationToken cancellationToken) =>
        {
            var processed = await service.CheckAlreadyProcessedAsync(tenantId, source, idempotencyKey, cancellationToken);
            return Results.Ok(new { tenantId, source, idempotencyKey, processed });
        }).RequireAuthorization(PortalPermissions.IntegrationRead);

        return endpoints;
    }

    private static IResult Reply<T>(HttpContext context, Result<T> result, int successStatus)
        => result.IsSuccess
            ? Results.Json(new ApiResponse<T>(result.Value, null, context.TraceIdentifier), statusCode: successStatus)
            : Results.BadRequest(new ApiResponse<T>(default, result.Error, context.TraceIdentifier));
}
