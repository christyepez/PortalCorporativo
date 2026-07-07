using Portal.BuildingBlocks;
using Portal.Security.Application;
using Portal.Security.Contracts;

namespace Portal.Security.Api;

public static class SecurityEndpoints
{
    public static IEndpointRouteBuilder MapSecurityEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/security").RequireAuthorization(PortalPermissions.SecurityManage);

        group.MapPost("/users", async (CreateUserRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.CreateUserAsync(request, ct), StatusCodes.Status201Created));
        group.MapGet("/users/{id:guid}", async (Guid id, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.GetUserAsync(id, ct)));
        group.MapPost("/roles", async (CreateRoleRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.CreateRoleAsync(request, ct), StatusCodes.Status201Created));
        group.MapPost("/permissions", async (CreatePermissionRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.CreatePermissionAsync(request, ct), StatusCodes.Status201Created));
        group.MapPost("/resources", async (RegisterProtectedResourceRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.RegisterResourceAsync(request, ct), StatusCodes.Status201Created));
        group.MapPost("/users/{id:guid}/roles", async (Guid id, AssignRoleToUserRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.AssignRoleAsync(id, request.RoleId, ct)));
        group.MapPost("/roles/{id:guid}/permissions", async (Guid id, AssignPermissionToRoleRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.AssignPermissionAsync(id, request.PermissionId, ct)));
        group.MapPost("/check-permission", async (CheckPermissionRequest request, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.CheckPermissionAsync(request, ct)));
        group.MapGet("/users/{id:guid}/permissions", async (Guid id, SecurityService service, HttpContext context, CancellationToken ct) =>
            Response(context, await service.GetUserPermissionsAsync(id, ct)));

        return endpoints;
    }

    private static IResult Response<T>(HttpContext context, Result<T> result, int successStatus = StatusCodes.Status200OK)
    {
        if (result.IsSuccess)
            return Results.Json(new ApiResponse<T>(result.Value, null, context.TraceIdentifier), statusCode: successStatus);

        var status = result.Error!.Code switch
        {
            var code when code.EndsWith(".not_found", StringComparison.Ordinal) => StatusCodes.Status404NotFound,
            var code when code.EndsWith(".conflict", StringComparison.Ordinal) => StatusCodes.Status409Conflict,
            _ => StatusCodes.Status400BadRequest
        };
        return Results.Json(new ApiResponse<T>(default, result.Error, context.TraceIdentifier), statusCode: status);
    }
}
