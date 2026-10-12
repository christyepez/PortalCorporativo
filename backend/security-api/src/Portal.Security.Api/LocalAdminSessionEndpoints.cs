using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Security.Domain;
using Portal.Security.Infrastructure;

namespace Portal.Security.Api;

public static class LocalAdminSessionEndpoints
{
    public const string CookieName = "portal_local_session";

    public static IEndpointRouteBuilder MapLocalAdminSessionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/api/security/local-session", async (
            LocalAdminLoginRequest request,
            IConfiguration configuration,
            SecurityDbContext dbContext,
            HttpContext context,
            CancellationToken cancellationToken) =>
        {
            if (!configuration.GetValue<bool>("PortalLocalAdmin:Enabled"))
            {
                return Results.NotFound();
            }

            var configuredEmail = configuration["PortalLocalAdmin:Email"]?.Trim().ToLowerInvariant();
            var configuredPassword = configuration["PortalLocalAdmin:Password"];
            if (string.IsNullOrWhiteSpace(configuredEmail) || string.IsNullOrWhiteSpace(configuredPassword))
            {
                return Results.Problem(
                    "Local administrator credentials are not configured.",
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }

            if (!CredentialEquals(request.Email?.Trim().ToLowerInvariant(), configuredEmail) ||
                !CredentialEquals(request.Password, configuredPassword))
            {
                context.Response.Headers.CacheControl = "no-store";
                return Results.Unauthorized();
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

            var localAdmin = await EnsureLocalSuperAdminAsync(dbContext, configuredEmail, cancellationToken);
            var superAdminRoleId = await dbContext.Roles
                .AsNoTracking()
                .Where(role =>
                    role.TenantId == TenantIds.Default &&
                    role.NormalizedName == "SUPERADMIN")
                .Select(role => role.Id)
                .SingleAsync(cancellationToken);

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
                new(JwtRegisteredClaimNames.Sub, localAdmin.Id.ToString()),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
                new("tenant_id", TenantIds.Default),
                new(ClaimTypes.Name, localAdmin.Name),
                new(ClaimTypes.Email, localAdmin.Email),
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

            var encoded = new JwtSecurityTokenHandler().WriteToken(token);
            context.Response.Cookies.Append(CookieName, encoded, new CookieOptions
            {
                HttpOnly = true,
                SameSite = SameSiteMode.Strict,
                Secure = context.Request.IsHttps,
                IsEssential = true,
                Path = "/",
                MaxAge = TimeSpan.FromMinutes(10)
            });
            context.Response.Headers.CacheControl = "no-store";
            context.Response.Headers.Pragma = "no-cache";

            return Results.Ok(new
            {
                accessToken = encoded,
                expiresAtUtc = expires,
                user = localAdmin.Email,
                displayName = localAdmin.Name,
                role = "SuperAdmin",
                tenantId = TenantIds.Default,
                permissions = permissionCodes
            });
        }).AllowAnonymous();

        endpoints.MapPost("/api/security/local-session/logout", (IConfiguration configuration, HttpContext context) =>
        {
            if (!configuration.GetValue<bool>("PortalLocalAdmin:Enabled"))
            {
                return Results.NotFound();
            }

            context.Response.Cookies.Delete(CookieName, new CookieOptions
            {
                HttpOnly = true,
                SameSite = SameSiteMode.Strict,
                Secure = context.Request.IsHttps,
                IsEssential = true,
                Path = "/"
            });
            context.Response.Headers.CacheControl = "no-store";
            context.Response.Headers.Pragma = "no-cache";
            return Results.NoContent();
        }).AllowAnonymous();

        return endpoints;
    }

    private static async Task<User> EnsureLocalSuperAdminAsync(SecurityDbContext dbContext, string localAdminEmail, CancellationToken cancellationToken)
    {
        var user = await dbContext.Users.SingleOrDefaultAsync(
            user => user.TenantId == TenantIds.Default &&
                    user.NormalizedEmail == localAdminEmail.ToUpperInvariant(),
            cancellationToken);

        if (user is null)
        {
            user = User.Create(TenantIds.Default, localAdminEmail, "Local SuperAdmin");
            dbContext.Users.Add(user);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var role = await dbContext.Roles.SingleAsync(
            role => role.TenantId == TenantIds.Default &&
                    role.NormalizedName == "SUPERADMIN",
            cancellationToken);

        var assigned = await dbContext.UserRoles.AnyAsync(
            assignment => assignment.TenantId == TenantIds.Default &&
                          assignment.UserId == user.Id &&
                          assignment.RoleId == role.Id,
            cancellationToken);

        if (!assigned)
        {
            dbContext.UserRoles.Add(UserRole.Create(TenantIds.Default, user.Id, role.Id));
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return user;
    }

    private static bool CredentialEquals(string? provided, string expected)
    {
        if (string.IsNullOrEmpty(provided)) return false;
        var providedBytes = Encoding.UTF8.GetBytes(provided);
        var expectedBytes = Encoding.UTF8.GetBytes(expected);
        return providedBytes.Length == expectedBytes.Length &&
               CryptographicOperations.FixedTimeEquals(providedBytes, expectedBytes);
    }
}

public sealed record LocalAdminLoginRequest(string? Email, string? Password);
