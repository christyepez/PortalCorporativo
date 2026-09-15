using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Portal.Audit.Domain;

namespace Portal.Audit.Infrastructure;

public sealed class ArchivedAuditLog
{
    public Guid Id { get; set; }
    public Guid OriginalAuditLogId { get; set; }
    public string TenantId { get; set; } = null!;
    public DateTimeOffset OriginalCreatedAtUtc { get; set; }
    public DateTimeOffset ArchivedAtUtc { get; set; }
    public string SnapshotJson { get; set; } = null!;
}

public sealed record AuditRetentionOptions(
    bool Enabled = false,
    int RetentionDays = 365,
    int BatchSize = 500,
    int PollIntervalMinutes = 60);

public sealed class AuditRetentionService(AuditDbContext db, TimeProvider timeProvider)
{
    public async Task<int> ArchiveAndPurgeAsync(int retentionDays, int batchSize, CancellationToken cancellationToken)
    {
        if (retentionDays < 365) throw new ArgumentOutOfRangeException(nameof(retentionDays), "Audit retention cannot be shorter than 365 days.");
        batchSize = Math.Clamp(batchSize, 1, 2000);
        var cutoff = timeProvider.GetUtcNow().AddDays(-retentionDays);

        var candidates = await db.AuditLogs.AsNoTracking()
            .Where(x => x.CreatedAtUtc < cutoff)
            .OrderBy(x => x.CreatedAtUtc)
            .ThenBy(x => x.Id)
            .Take(batchSize)
            .ToArrayAsync(cancellationToken);

        if (candidates.Length == 0) return 0;

        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
        var archivedAt = timeProvider.GetUtcNow();
        foreach (var auditLog in candidates)
        {
            db.ArchivedAuditLogs.Add(new ArchivedAuditLog
            {
                Id = Guid.NewGuid(),
                OriginalAuditLogId = auditLog.Id,
                TenantId = auditLog.TenantId,
                OriginalCreatedAtUtc = auditLog.CreatedAtUtc,
                ArchivedAtUtc = archivedAt,
                SnapshotJson = JsonSerializer.Serialize(auditLog)
            });
        }

        await db.SaveChangesAsync(cancellationToken);
        var ids = candidates.Select(x => x.Id).ToArray();
        var deleted = await db.AuditLogs.Where(x => ids.Contains(x.Id)).ExecuteDeleteAsync(cancellationToken);
        if (deleted != candidates.Length)
            throw new InvalidOperationException("Audit purge count did not match archived count; transaction will be rolled back.");

        await transaction.CommitAsync(cancellationToken);
        return deleted;
    }
}

public sealed class AuditRetentionWorker(
    IServiceProvider services,
    IConfiguration configuration,
    ILogger<AuditRetentionWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var options = configuration.GetSection("Audit:Retention").Get<AuditRetentionOptions>() ?? new AuditRetentionOptions();
        if (!options.Enabled)
        {
            logger.LogInformation("Audit retention worker is disabled.");
            return;
        }

        var interval = TimeSpan.FromMinutes(Math.Clamp(options.PollIntervalMinutes, 5, 1440));
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await using var scope = services.CreateAsyncScope();
                var retention = scope.ServiceProvider.GetRequiredService<AuditRetentionService>();
                var processed = await retention.ArchiveAndPurgeAsync(options.RetentionDays, options.BatchSize, stoppingToken);
                logger.LogInformation("Audit retention processed {Count} records.", processed);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { break; }
            catch (Exception ex) { logger.LogError(ex, "Audit retention iteration failed; no unarchived records are purged."); }

            await Task.Delay(interval, stoppingToken);
        }
    }
}
