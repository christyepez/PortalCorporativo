using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace Portal.BuildingBlocks;

public static class PortalAuthenticationExtensions
{
    public static IServiceCollection AddPortalJwtAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        var authority = configuration["Jwt:Authority"]?.Trim();
        var audience = configuration["Jwt:Audience"]?.Trim();

        services.AddPortalTokenRevocation(configuration);
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
        {
            options.Events = new JwtBearerEvents
            {
                OnTokenValidated = async context =>
                {
                    var jti = context.Principal?.FindFirst("jti")?.Value;
                    if (string.IsNullOrWhiteSpace(jti)) return;

                    var revocations = context.HttpContext.RequestServices.GetService<IPortalTokenRevocationStore>();
                    if (revocations is not null && await revocations.IsRevokedAsync(jti, context.HttpContext.RequestAborted))
                        context.Fail("JWT session has been revoked.");
                }
            };
            if (!string.IsNullOrWhiteSpace(authority))
            {
                options.Authority = authority;
                options.Audience = audience;
                options.RequireHttpsMetadata = configuration.GetValue("Jwt:RequireHttpsMetadata", true);
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidAudience = audience,
                    ValidateIssuerSigningKey = true,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromMinutes(1)
                };
                return;
            }

            var secret = configuration["Jwt:Secret"]
                ?? throw new InvalidOperationException("Configure Jwt:Authority for OIDC or provide Jwt:Secret from secret storage for the local JWT mode.");
            var issuer = configuration["Jwt:Issuer"]
                ?? throw new InvalidOperationException("Jwt:Issuer is required in local JWT mode.");
            if (string.IsNullOrWhiteSpace(audience))
                throw new InvalidOperationException("Jwt:Audience is required.");

            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = issuer,
                ValidateAudience = true,
                ValidAudience = audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(1)
            };
        });

        return services;
    }
}
