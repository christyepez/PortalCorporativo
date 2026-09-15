using System.Security.Cryptography;
using Portal.Content.Contracts;
using Portal.Content.Domain;

namespace Portal.Content.Application;

public sealed record StoredContent(ContentDocument Document, byte[] Bytes);

public interface IContentRepository
{
    Task<IReadOnlyCollection<ContentDocument>> ListAsync(string? moduleCode, bool? isActive, CancellationToken cancellationToken);
    Task<StoredContent?> GetAsync(Guid id, CancellationToken cancellationToken);
    Task AddAsync(StoredContent content, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}

public sealed class ContentService(IContentRepository repository, TimeProvider timeProvider)
{
    private const int MaxContentBytes = 10 * 1024 * 1024;

    public async Task<IReadOnlyCollection<ContentDocumentDto>> ListAsync(string? moduleCode, bool? isActive, CancellationToken cancellationToken)
        => (await repository.ListAsync(moduleCode, isActive, cancellationToken)).Select(Map).ToArray();

    public async Task<ContentDocumentDto?> GetAsync(Guid id, CancellationToken cancellationToken)
        => (await repository.GetAsync(id, cancellationToken)) is { } stored ? Map(stored.Document) : null;

    public Task<StoredContent?> DownloadAsync(Guid id, CancellationToken cancellationToken)
        => repository.GetAsync(id, cancellationToken);

    public async Task<ContentDocumentDto> CreateAsync(CreateContentDocumentRequest request, CancellationToken cancellationToken)
    {
        if (request.Content is null || request.Content.Length == 0) throw new ArgumentException("Content is required.", nameof(request));
        if (request.Content.Length > MaxContentBytes) throw new ArgumentException($"Content exceeds the {MaxContentBytes} byte NonProduction limit.", nameof(request));

        var hash = Convert.ToHexString(SHA256.HashData(request.Content)).ToLowerInvariant();
        var document = ContentDocument.Create(request.ModuleCode, request.FileName, request.ContentType, request.Content.LongLength, hash, timeProvider.GetUtcNow());
        await repository.AddAsync(new StoredContent(document, request.Content.ToArray()), cancellationToken);
        await repository.SaveChangesAsync(cancellationToken);
        return Map(document);
    }

    public async Task<bool> DeactivateAsync(Guid id, CancellationToken cancellationToken)
    {
        var stored = await repository.GetAsync(id, cancellationToken);
        if (stored is null) return false;
        stored.Document.Deactivate();
        await repository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static ContentDocumentDto Map(ContentDocument document) => new(document.Id, document.ModuleCode, document.FileName, document.ContentType, document.Length, document.Sha256, document.IsActive, document.CreatedAt);
}
