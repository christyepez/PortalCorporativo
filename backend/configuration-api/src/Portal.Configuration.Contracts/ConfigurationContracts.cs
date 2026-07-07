namespace Portal.Configuration.Contracts;

public sealed record CreateConfigurationRequest(string Key, int Scope, string? ModuleCode, Guid? UserId, int Category, string ValueJson);
public sealed record UpdateConfigurationRequest(int Category, string ValueJson);
public sealed record ConfigurationResponse(Guid Id, string Key, int Scope, string TenantId, string? ModuleCode, Guid? UserId,
    int Category, string ValueJson, int Version, bool IsActive);
public sealed record EffectiveConfigurationResponse(string Key, string ValueJson, int Scope, int Version);
public sealed record ConfigurationChangedV1(Guid ItemId, string Key, int Version, string ChangeType, string CorrelationId);
