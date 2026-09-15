using Portal.Reporting.Contracts;
using Portal.Reporting.Domain;

namespace Portal.Reporting.Application;

public sealed record ReportExecution(
    string Key,
    DateTimeOffset GeneratedAt,
    IReadOnlyCollection<IReadOnlyDictionary<string, object?>> Rows,
    string SourceMode);

public interface IReportingProvider
{
    Task<IReadOnlyCollection<ReportDefinition>> ListAsync(CancellationToken cancellationToken);
    Task<ReportDefinition?> GetAsync(string key, CancellationToken cancellationToken);
    Task<ReportExecution?> ExecuteAsync(string key, IReadOnlyDictionary<string, string> parameters, DateTimeOffset generatedAt, CancellationToken cancellationToken);
}

public sealed class ReportingService(IReportingProvider provider, TimeProvider timeProvider)
{
    public async Task<IReadOnlyCollection<ReportDefinitionDto>> ListAsync(CancellationToken cancellationToken)
        => (await provider.ListAsync(cancellationToken)).Select(Map).ToArray();

    public async Task<ReportDefinitionDto?> GetAsync(string key, CancellationToken cancellationToken)
        => (await provider.GetAsync(key, cancellationToken)) is { } definition ? Map(definition) : null;

    public async Task<ReportExecutionDto?> ExecuteAsync(string key, ExecuteReportRequest request, CancellationToken cancellationToken)
    {
        var definition = await provider.GetAsync(key, cancellationToken);
        if (definition is null) return null;

        var parameters = request.Parameters ?? new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var missing = definition.RequiredParameters.Where(required => !parameters.Keys.Any(k => k.Equals(required, StringComparison.OrdinalIgnoreCase))).ToArray();
        if (missing.Length > 0) throw new ArgumentException($"Missing required report parameters: {string.Join(", ", missing)}.", nameof(request));

        var execution = await provider.ExecuteAsync(key, parameters, timeProvider.GetUtcNow(), cancellationToken);
        return execution is null ? null : new ReportExecutionDto(execution.Key, execution.GeneratedAt, execution.Rows, execution.SourceMode);
    }

    private static ReportDefinitionDto Map(ReportDefinition definition)
        => new(definition.Key, definition.Name, definition.Description, definition.ModuleCode, definition.RequiredParameters);
}
