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

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
        {
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
