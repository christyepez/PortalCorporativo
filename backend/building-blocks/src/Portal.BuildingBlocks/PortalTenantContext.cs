using System.Text.RegularExpressions;

namespace Portal.BuildingBlocks;

public interface IPortalTenantContext
{
    string TenantId { get; }
    bool IsExplicit { get; }
}

public sealed class PortalTenantContext : IPortalTenantContext
{
    public const string DefaultTenantId = "default";
    public const string HeaderName = "X-Tenant-ID";
    private static readonly Regex ValidTenant = new("^[a-z0-9][a-z0-9._-]{0,63}$", RegexOptions.Compiled | RegexOptions.CultureInvariant);

    public string TenantId { get; private set; } = DefaultTenantId;
    public bool IsExplicit { get; private set; }

    internal void Resolve(string? claimTenant, string? headerTenant)
    {
        var normalizedClaim = Normalize(claimTenant);
        var normalizedHeader = Normalize(headerTenant);
        var resolved = normalizedClaim ?? DefaultTenantId;

        if (normalizedHeader is not null)
        {
            if (normalizedClaim is null && normalizedHeader != DefaultTenantId)
                throw new InvalidOperationException("A non-default tenant requires a tenant_id claim.");
            if (normalizedClaim is not null && normalizedHeader != normalizedClaim)
                throw new InvalidOperationException("X-Tenant-ID does not match the authenticated tenant.");
            resolved = normalizedHeader;
        }

        TenantId = resolved;
        IsExplicit = normalizedClaim is not null;
    }

    public static string? Normalize(string? tenantId)
    {
        if (string.IsNullOrWhiteSpace(tenantId)) return null;
        var normalized = tenantId.Trim().ToLowerInvariant();
        if (!ValidTenant.IsMatch(normalized))
            throw new ArgumentException("tenantId must contain only lowercase letters, numbers, '.', '_' or '-' and be at most 64 characters.", nameof(tenantId));
        return normalized;
    }
}
