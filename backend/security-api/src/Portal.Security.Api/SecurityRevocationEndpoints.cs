using Portal.BuildingBlocks;
using Portal.Security.Application;

namespace Portal.Security.Api;

public static class SecurityRevocationEndpoints
{
    public static IEndpointRouteBuilder MapSecurityRevocationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/security").RequireAuthorization(PortalPermissions.SecurityManage);

        group.MapDelete("/users/{userId:guid}/roles/{roleId:guid}", async (
            Guid userId,
            Guid roleId,
            SecurityRevocationService service,
            HttpContext context,
            CancellationToken cancellationToken) =>
        {
            var result = await service.RevokeRoleFromUserAsync(userId, roleId, cancellationToken);
            return Reply(context, result);
        });

        group.MapDelete("/roles/{roleId:guid}/permissions/{permissionId:guid}", async (
            Guid roleId,
            Guid permissionId,
            SecurityRevocationService service,
            HttpContext context,
            CancellationToken cancellationToken) =>
        {
            var result = await service.RevokePermissionFromRoleAsync(roleId, permissionId, cancellationToken);
            return Reply(context, result);
        });

        endpoints.MapPost("/api/security/sessions/current/revoke", async (
            IPortalTokenRevocationStore revocations,
            HttpContext context,
            CancellationToken cancellationToken) =>
        {
            var jti = context.User.FindFirst("jti")?.Value;
            var exp = context.User.FindFirst("exp")?.Value;
            if (string.IsNullOrWhiteSpace(jti) || !long.TryParse(exp, out var expSeconds))
                return Results.BadRequest(new ApiResponse<bool>(false,
                    new ApiError("security.session.invalid_token", "JWT must contain jti and exp claims to support revocation."),
                    context.TraceIdentifier));

            await revocations.RevokeAsync(jti, DateTimeOffset.FromUnixTimeSeconds(expSeconds), cancellationToken);
            return Results.Ok(new ApiResponse<bool>(true, null, context.TraceIdentifier));
        }).RequireAuthorization();

        return endpoints;
    }

    private static IResult Reply(HttpContext context, Result<bool> result)
    {
        if (result.IsSuccess)
            return Results.Ok(new ApiResponse<bool>(true, null, context.TraceIdentifier));

        var status = result.Error!.Code.EndsWith(".not_found", StringComparison.Ordinal)
            ? StatusCodes.Status404NotFound
            : StatusCodes.Status400BadRequest;
        return Results.Json(new ApiResponse<bool>(false, result.Error, context.TraceIdentifier), statusCode: status);
    }
}
