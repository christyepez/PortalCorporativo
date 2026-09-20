using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Portal.BuildingBlocks;

public interface IPortalTokenRevocationStore
{
    Task RevokeAsync(string jti, DateTimeOffset expiresAtUtc, CancellationToken cancellationToken);
    Task<bool> IsRevokedAsync(string jti, CancellationToken cancellationToken);
}

internal sealed class DistributedPortalTokenRevocationStore(IDistributedCache cache) : IPortalTokenRevocationStore
{
    private const string Prefix = "portal:jwt:revoked:";

    public async Task RevokeAsync(string jti, DateTimeOffset expiresAtUtc, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(jti))
            throw new ArgumentException("Token jti is required.", nameof(jti));

        var ttl = expiresAtUtc - DateTimeOffset.UtcNow;
        if (ttl <= TimeSpan.Zero)
            ttl = TimeSpan.FromMinutes(1);

        await cache.SetStringAsync(
            Prefix + jti.Trim(),
            "1",
            new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = ttl },
            cancellationToken);
    }

    public async Task<bool> IsRevokedAsync(string jti, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(jti))
            return false;

        return await cache.GetStringAsync(Prefix + jti.Trim(), cancellationToken) is not null;
    }
}

public static class PortalTokenRevocationExtensions
{
    public static IServiceCollection AddPortalTokenRevocation(this IServiceCollection services, IConfiguration configuration)
    {
        var redis = configuration.GetConnectionString("Redis")?.Trim();
        if (string.IsNullOrWhiteSpace(redis))
            return services;

        services.AddStackExchangeRedisCache(options => options.Configuration = redis);
        services.AddSingleton<IPortalTokenRevocationStore, DistributedPortalTokenRevocationStore>();
        return services;
    }
}
