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
    public const string CookieName = "portal_local_session";
    private const string LocalAdminEmail = "superadmin@portal.local";

    private static readonly string[] ConsumerPermissions =
    [
        "crm.access",
        "financial.*",
        "hr.employees.view",
        "hr.employees.manage",
        "historiaspaolin.channels.view"
    ];

    public static IEndpointRouteBuilder MapLocalAdminSessionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/api/security/local-session", async (
            IConfiguration configuration,
            SecurityDbContext db,
            HttpContext context,
            CancellationToken ct) =>
        {
            if (!configuration.GetValue<bool>("PortalLocalAdmin:Enabled"))
                return Results.NotFound();

            var secret = configuration["Jwt:Secret"];
            var issuer = configuration["Jwt:Issuer"];
            var audience = configuration["Jwt:Audience"];
            if (string.IsNullOrWhiteSpace(secret) || string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(audience))
                return Results.Problem("Local JWT configuration is incomplete.", statusCode: StatusCodes.Status503ServiceUnavailable);

            var user = await EnsureLocalSuperAdminAsync(db, ct);
            var now = DateTimeOffset.UtcNow;
            var expires = now.AddMinutes(10);
            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
                new("tenant_id", TenantIds.Default),
                new(ClaimTypes.Name, user.Name),
                new(ClaimTypes.Email, user.Email),
                new(ClaimTypes.Role, "SuperAdmin")
            };
            claims.AddRange(PortalPermissions.All.Select(permission => new Claim(PortalPermissions.ClaimType, permission)));
            claims.AddRange(ConsumerPermissions.Select(permission => new Claim(PortalPermissions.ClaimType, permission)));

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
                user = user.Email,
                displayName = user.Name,
                role = "SuperAdmin",
                tenantId = TenantIds.Default
            });
        }).AllowAnonymous();

        endpoints.MapPost("/api/security/local-session/logout", (IConfiguration configuration, HttpContext context) =>
        {
            if (!configuration.GetValue<bool>("PortalLocalAdmin:Enabled"))
                return Results.NotFound();

            context.Response.Cookies.Delete(CookieName, new CookieOptions
            {
                HttpOnly = true,
                SameSite = SameSiteMode.Strict,
                Secure = context.Request.IsHttps,
                IsEssential = true,
                Path = "/"
            });
            context.Response.Headers.CacheControl = "no-store";
            return Results.NoContent();
        }).AllowAnonymous();

        return endpoints;
    }

    private static async Task<User> EnsureLocalSuperAdminAsync(SecurityDbContext db, CancellationToken ct)
    {
        var user = await db.Users.SingleOrDefaultAsync(
            x => x.TenantId == TenantIds.Default && x.NormalizedEmail == LocalAdminEmail.ToUpperInvariant(),
            ct);

        if (user is null)
        {
            user = User.Create(TenantIds.Default, LocalAdminEmail, "Local SuperAdmin");
            db.Users.Add(user);
            await db.SaveChangesAsync(ct);
        }

        var role = await db.Roles.SingleAsync(
            x => x.TenantId == TenantIds.Default && x.NormalizedName == "SUPERADMIN",
            ct);

        var assigned = await db.UserRoles.AnyAsync(
            x => x.TenantId == TenantIds.Default && x.UserId == user.Id && x.RoleId == role.Id,
            ct);

        if (!assigned)
        {
            db.UserRoles.Add(UserRole.Create(TenantIds.Default, user.Id, role.Id));
            await db.SaveChangesAsync(ct);
        }

        return user;
    }
}
