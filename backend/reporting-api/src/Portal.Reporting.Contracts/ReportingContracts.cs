namespace Portal.Reporting.Contracts;

public sealed record ReportDefinitionDto(
    string Key,
    string Name,
    string Description,
    string ModuleCode,
    IReadOnlyCollection<string> RequiredParameters);

public sealed record ExecuteReportRequest(IReadOnlyDictionary<string, string>? Parameters);

public sealed record ReportExecutionDto(
    string Key,
    DateTimeOffset GeneratedAt,
    IReadOnlyCollection<IReadOnlyDictionary<string, object?>> Rows,
    string SourceMode);
