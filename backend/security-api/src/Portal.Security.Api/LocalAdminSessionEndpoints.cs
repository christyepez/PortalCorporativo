using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Security.Domain;
using Portal.Security.Infrastructure;

namespace Portal.Security.Api;

public static class LocalAdminSessionEndpoints
{
    public static IEndpointRouteBuilder MapLocalAdminSessionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/api/security/local-session", async (
            IConfiguration configuration,
            SecurityDbContext dbContext,
            HttpContext context,
            CancellationToken cancellationToken) =>
        {
            if (!configuration.GetValue<bool>("PortalLocalAdmin:Enabled"))
            {
                return Results.NotFound();
            }

            var secret = configuration["Jwt:Secret"];
            var issuer = configuration["Jwt:Issuer"];
            var audience = configuration["Jwt:Audience"];
            if (string.IsNullOrWhiteSpace(secret) || string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(audience))
            {
                return Results.Problem(
                    "Local JWT configuration is incomplete.",
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }

            var superAdminRoleId = await dbContext.Roles
                .AsNoTracking()
                .Where(role =>
                    role.TenantId == TenantIds.Default &&
                    role.NormalizedName == "SUPERADMIN")
                .Select(role => role.Id)
                .SingleOrDefaultAsync(cancellationToken);

            if (superAdminRoleId == Guid.Empty)
            {
                return Results.Problem(
                    "SuperAdmin role is not initialized.",
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }

            var permissionCodes = await (
                from assignment in dbContext.RolePermissions.AsNoTracking()
                join permission in dbContext.Permissions.AsNoTracking()
                    on assignment.PermissionId equals permission.Id
                where assignment.TenantId == TenantIds.Default &&
                      assignment.RoleId == superAdminRoleId &&
                      permission.TenantId == TenantIds.Default
                orderby permission.Code
                select permission.Code)
                .Distinct()
                .ToListAsync(cancellationToken);

            if (permissionCodes.Count == 0)
            {
                return Results.Problem(
                    "SuperAdmin has no permissions assigned.",
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }

            var now = DateTimeOffset.UtcNow;
            var expires = now.AddMinutes(10);
            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, "portal-local-superadmin"),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
                new("tenant_id", TenantIds.Default),
                new(ClaimTypes.Name, "Local SuperAdmin"),
                new(ClaimTypes.Role, "SuperAdmin")
            };
            claims.AddRange(permissionCodes.Select(permission =>
                new Claim(PortalPermissions.ClaimType, permission)));

            var credentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer,
                audience,
                claims,
                now.UtcDateTime,
                expires.UtcDateTime,
                credentials);

            context.Response.Headers.CacheControl = "no-store";
            context.Response.Headers.Pragma = "no-cache";

            return Results.Ok(new
            {
                accessToken = new JwtSecurityTokenHandler().WriteToken(token),
                expiresAtUtc = expires,
                user = "superadmin@portal.local",
                displayName = "Local SuperAdmin",
                role = "SuperAdmin",
                tenantId = TenantIds.Default,
                permissions = permissionCodes
            });
        }).AllowAnonymous();

        return endpoints;
    }
}
