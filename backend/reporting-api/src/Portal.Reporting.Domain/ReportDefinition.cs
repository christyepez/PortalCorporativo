namespace Portal.Reporting.Domain;

public sealed record ReportDefinition(
    string Key,
    string Name,
    string Description,
    string ModuleCode,
    IReadOnlyCollection<string> RequiredParameters)
{
    public static ReportDefinition Create(string key, string name, string description, string moduleCode, params string[] requiredParameters)
    {
        if (string.IsNullOrWhiteSpace(key) || key.Trim().Length > 100) throw new ArgumentException("Key is required and must be <= 100 characters.", nameof(key));
        if (string.IsNullOrWhiteSpace(name) || name.Trim().Length > 160) throw new ArgumentException("Name is required and must be <= 160 characters.", nameof(name));
        if (string.IsNullOrWhiteSpace(moduleCode) || moduleCode.Trim().Length > 80) throw new ArgumentException("ModuleCode is required and must be <= 80 characters.", nameof(moduleCode));
        var parameters = requiredParameters.Where(x => !string.IsNullOrWhiteSpace(x)).Select(x => x.Trim()).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        return new ReportDefinition(key.Trim(), name.Trim(), description.Trim(), moduleCode.Trim(), parameters);
    }
}
