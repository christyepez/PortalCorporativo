using System.Net;
using Portal.Reporting.Application;
using Portal.Reporting.Domain;

namespace Portal.Reporting.Api;

public sealed class OperationalReportingProvider(IHttpClientFactory httpClientFactory) : IReportingProvider
{
    private static readonly IReadOnlyDictionary<string, string> Services =
        new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["security"] = "http://security-api:8080/health/ready",
            ["configuration"] = "http://configuration-api:8080/health/ready",
            ["menu"] = "http://menu-api:8080/health/ready",
            ["audit"] = "http://audit-api:8080/health/ready",
            ["notification"] = "http://notification-api:8080/health/ready",
            ["catalog"] = "http://catalog-api:8080/health/ready",
            ["content"] = "http://content-api:8080/health/ready",
            ["integration"] = "http://integration-api:8080/health/ready",
            ["reporting"] = "http://reporting-api:8080/health/ready",
            ["crm"] = "http://crm-api:8080/health/ready",
            ["financial"] = "http://financial-api:8080/health/ready",
            ["hr"] = "http://hr-api:8080/health/ready",
            ["historiaspaolin"] = "http://historiaspaolin-api:8080/health/ready"
        };

    private readonly IReadOnlyDictionary<string, ReportDefinition> definitions =
        new Dictionary<string, ReportDefinition>(StringComparer.OrdinalIgnoreCase)
        {
            ["portal-overview"] = ReportDefinition.Create(
                "portal-overview",
                "Portal Overview",
                "Operational readiness of Portal core and integrated application services.",
                "PORTAL"),
            ["module-activity"] = ReportDefinition.Create(
                "module-activity",
                "Module Operational Status",
                "Live readiness status for a Portal or integrated application module.",
                "PORTAL",
                "moduleCode")
        };

    public Task<IReadOnlyCollection<ReportDefinition>> ListAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.FromResult<IReadOnlyCollection<ReportDefinition>>(definitions.Values.OrderBy(x => x.Name).ToArray());
    }

    public Task<ReportDefinition?> GetAsync(string key, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        definitions.TryGetValue(key, out var definition);
        return Task.FromResult(definition);
    }

    public async Task<ReportExecution?> ExecuteAsync(
        string tenantId,
        string key,
        IReadOnlyDictionary<string, string> parameters,
        DateTimeOffset generatedAt,
        CancellationToken cancellationToken)
    {
        if (!definitions.ContainsKey(key)) return null;

        if (key.Equals("portal-overview", StringComparison.OrdinalIgnoreCase))
        {
            var probes = await Task.WhenAll(Services.Select(x => ProbeAsync(x.Key, x.Value, cancellationToken)));
            var rows = probes
                .OrderBy(x => x.Module)
                .Select(x => Row(
                    ("TenantId", tenantId),
                    ("ModuleCode", x.Module),
                    ("Ready", x.Ready),
                    ("StatusCode", x.StatusCode),
                    ("CheckedAtUtc", generatedAt)))
                .ToArray();
            return new ReportExecution(key, generatedAt, rows, "OperationalReadiness");
        }

        var moduleCode = parameters.First(x => x.Key.Equals("moduleCode", StringComparison.OrdinalIgnoreCase)).Value.Trim();
        var normalized = NormalizeModule(moduleCode);
        if (!Services.TryGetValue(normalized, out var url))
            throw new ArgumentException($"Unknown moduleCode '{moduleCode}'.", nameof(parameters));

        var probe = await ProbeAsync(normalized, url, cancellationToken);
        return new ReportExecution(
            key,
            generatedAt,
            new[]
            {
                Row(
                    ("TenantId", tenantId),
                    ("ModuleCode", probe.Module),
                    ("Ready", probe.Ready),
                    ("StatusCode", probe.StatusCode),
                    ("CheckedAtUtc", generatedAt))
            },
            "OperationalReadiness");
    }

    private async Task<(string Module, bool Ready, int StatusCode)> ProbeAsync(string module, string url, CancellationToken cancellationToken)
    {
        try
        {
            using var client = httpClientFactory.CreateClient("operational-reporting");
            using var response = await client.GetAsync(url, cancellationToken);
            return (module, response.StatusCode == HttpStatusCode.OK, (int)response.StatusCode);
        }
        catch (HttpRequestException)
        {
            return (module, false, 0);
        }
        catch (TaskCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return (module, false, 0);
        }
    }

    private static string NormalizeModule(string moduleCode)
        => moduleCode.Trim().ToLowerInvariant() switch
        {
            "portal" => "reporting",
            "notifications" => "notification",
            "financiero" => "financial",
            "tthh" => "hr",
            "talento-humano" => "hr",
            _ => moduleCode.Trim().ToLowerInvariant()
        };

    private static IReadOnlyDictionary<string, object?> Row(params (string Key, object? Value)[] values)
        => values.ToDictionary(x => x.Key, x => x.Value, StringComparer.OrdinalIgnoreCase);
}
