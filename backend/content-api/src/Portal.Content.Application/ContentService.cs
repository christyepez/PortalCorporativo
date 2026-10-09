using System.Security.Cryptography;
using Portal.Content.Contracts;
using Portal.Content.Domain;

namespace Portal.Content.Application;

public sealed record StoredContent(ContentDocument Document, byte[] Bytes);

public interface IContentRepository
{
    Task<IReadOnlyCollection<ContentDocument>> ListAsync(string tenantId, string? moduleCode, bool? isActive, CancellationToken cancellationToken);
    Task<StoredContent?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken);
    Task AddAsync(StoredContent content, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}

public interface IContentChangeRecorder
{
    Task RecordAsync(string action, string entityId, object payload, string correlationId, CancellationToken cancellationToken);
}

public sealed class ContentService(IContentRepository repository, IContentChangeRecorder recorder, TimeProvider timeProvider)
{
    private const int MaxContentBytes = 10 * 1024 * 1024;

    public async Task<IReadOnlyCollection<ContentDocumentDto>> ListAsync(string tenantId, string? moduleCode, bool? isActive, CancellationToken cancellationToken)
        => (await repository.ListAsync(tenantId, moduleCode, isActive, cancellationToken)).Select(Map).ToArray();

    public async Task<ContentDocumentDto?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken)
        => (await repository.GetAsync(tenantId, id, cancellationToken)) is { } stored ? Map(stored.Document) : null;

    public Task<StoredContent?> DownloadAsync(string tenantId, Guid id, CancellationToken cancellationToken)
        => repository.GetAsync(tenantId, id, cancellationToken);

    public async Task<ContentDocumentDto> CreateAsync(string tenantId, CreateContentDocumentRequest request, string correlationId, CancellationToken cancellationToken)
    {
        if (request.Content is null || request.Content.Length == 0) throw new ArgumentException("Content is required.", nameof(request));
        if (request.Content.Length > MaxContentBytes) throw new ArgumentException($"Content exceeds the {MaxContentBytes} byte NonProduction limit.", nameof(request));

        var hash = Convert.ToHexString(SHA256.HashData(request.Content)).ToLowerInvariant();
        var document = ContentDocument.Create(tenantId, request.ModuleCode, request.FileName, request.ContentType, request.Content.LongLength, hash, timeProvider.GetUtcNow());
        await repository.AddAsync(new StoredContent(document, request.Content.ToArray()), cancellationToken);
        await repository.SaveChangesAsync(cancellationToken);
        await recorder.RecordAsync("created", document.Id.ToString(), new { document.TenantId, document.ModuleCode, document.FileName, document.ContentType, document.Length, document.Sha256 }, correlationId, cancellationToken);
        return Map(document);
    }

    public async Task<ContentDocumentDto?> UpdateMetadataAsync(string tenantId, Guid id, UpdateContentMetadataRequest request, string correlationId, CancellationToken cancellationToken)
    {
        var stored = await repository.GetAsync(tenantId, id, cancellationToken);
        if (stored is null) return null;
        stored.Document.UpdateMetadata(request.ModuleCode, request.FileName, request.ContentType);
        await repository.SaveChangesAsync(cancellationToken);
        await recorder.RecordAsync("metadata_updated", stored.Document.Id.ToString(), new { stored.Document.TenantId, stored.Document.ModuleCode, stored.Document.FileName, stored.Document.ContentType, stored.Document.Length, stored.Document.Sha256 }, correlationId, cancellationToken);
        return Map(stored.Document);
    }

    public async Task<ContentDocumentDto?> SetActiveAsync(string tenantId, Guid id, bool active, string correlationId, CancellationToken cancellationToken)
    {
        var stored = await repository.GetAsync(tenantId, id, cancellationToken);
        if (stored is null) return null;
        if (active) stored.Document.Activate(); else stored.Document.Deactivate();
        await repository.SaveChangesAsync(cancellationToken);
        await recorder.RecordAsync(active ? "activated" : "deactivated", stored.Document.Id.ToString(), new { stored.Document.TenantId, stored.Document.ModuleCode, stored.Document.FileName, stored.Document.IsActive, stored.Document.Sha256 }, correlationId, cancellationToken);
        return Map(stored.Document);
    }

    private static ContentDocumentDto Map(ContentDocument document) => new(document.Id, document.ModuleCode, document.FileName, document.ContentType, document.Length, document.Sha256, document.IsActive, document.CreatedAt);
}
