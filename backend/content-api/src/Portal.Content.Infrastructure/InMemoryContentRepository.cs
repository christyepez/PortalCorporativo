using System.Collections.Concurrent;
using Portal.Content.Application;
using Portal.Content.Domain;

namespace Portal.Content.Infrastructure;

public sealed class InMemoryContentRepository : IContentRepository
{
    private readonly ConcurrentDictionary<Guid, StoredContent> _items = new();

    public Task<IReadOnlyCollection<ContentDocument>> ListAsync(string? moduleCode, bool? isActive, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        IEnumerable<StoredContent> query = _items.Values;
        if (!string.IsNullOrWhiteSpace(moduleCode)) query = query.Where(x => x.Document.ModuleCode.Equals(moduleCode.Trim(), StringComparison.OrdinalIgnoreCase));
        if (isActive.HasValue) query = query.Where(x => x.Document.IsActive == isActive.Value);
        return Task.FromResult<IReadOnlyCollection<ContentDocument>>(query.Select(x => x.Document).OrderByDescending(x => x.CreatedAt).ToArray());
    }

    public Task<StoredContent?> GetAsync(Guid id, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        _items.TryGetValue(id, out var content);
        return Task.FromResult(content);
    }

    public Task AddAsync(StoredContent content, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!_items.TryAdd(content.Document.Id, content)) throw new InvalidOperationException("Content could not be added.");
        return Task.CompletedTask;
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.CompletedTask;
    }
}
