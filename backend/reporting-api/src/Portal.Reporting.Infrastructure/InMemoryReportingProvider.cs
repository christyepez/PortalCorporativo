using Portal.Reporting.Application;
using Portal.Reporting.Domain;

namespace Portal.Reporting.Infrastructure;

public sealed class InMemoryReportingProvider : IReportingProvider
{
    private readonly IReadOnlyDictionary<string, ReportDefinition> _definitions = new Dictionary<string, ReportDefinition>(StringComparer.OrdinalIgnoreCase)
    {
        ["portal-overview"] = ReportDefinition.Create("portal-overview", "Portal Overview", "Synthetic NonProduction platform overview.", "PORTAL"),
        ["module-activity"] = ReportDefinition.Create("module-activity", "Module Activity", "Synthetic NonProduction activity by module.", "PORTAL", "moduleCode")
    };

    public Task<IReadOnlyCollection<ReportDefinition>> ListAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.FromResult<IReadOnlyCollection<ReportDefinition>>(_definitions.Values.OrderBy(x => x.Name).ToArray());
    }

    public Task<ReportDefinition?> GetAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        _definitions.TryGetValue(key, out var definition);
        return Task.FromResult(definition);
    }

    public Task<ReportExecution?> ExecuteAsync(string tenantId, string key, IReadOnlyDictionary<string, string> parameters, DateTimeOffset generatedAt, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!_definitions.ContainsKey(key)) return Task.FromResult<ReportExecution?>(null);

        IReadOnlyCollection<IReadOnlyDictionary<string, object?>> rows = key.ToLowerInvariant() switch
        {
            "portal-overview" => new[]
            {
                Row(("TenantId", tenantId), ("Metric", "ServicesHealthy"), ("Value", 9)),
                Row(("TenantId", tenantId), ("Metric", "ActiveModules"), ("Value", 4)),
                Row(("TenantId", tenantId), ("Metric", "PendingOperationalGates"), ("Value", 3))
            },
            "module-activity" => new[]
            {
                Row(("TenantId", tenantId), ("ModuleCode", GetParameter(parameters, "moduleCode")), ("Events", 12), ("Mode", "SyntheticNonProduction"))
            },
            _ => Array.Empty<IReadOnlyDictionary<string, object?>>()
        };

        return Task.FromResult<ReportExecution?>(new ReportExecution(key, generatedAt, rows, "SyntheticNonProduction"));
    }

    private static IReadOnlyDictionary<string, object?> Row(params (string Key, object? Value)[] values)
        => values.ToDictionary(x => x.Key, x => x.Value, StringComparer.OrdinalIgnoreCase);

    private static string GetParameter(IReadOnlyDictionary<string, string> parameters, string name)
        => parameters.First(x => x.Key.Equals(name, StringComparison.OrdinalIgnoreCase)).Value;
}
