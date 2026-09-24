using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Portal.Audit.Application;
using Portal.Audit.Contracts;
using Portal.Audit.Domain;
using Portal.BuildingBlocks;

namespace Portal.Audit.Infrastructure;

public sealed class AuditDbContext(DbContextOptions<AuditDbContext> options) : DbContext(options)
{
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<ArchivedAuditLog> ArchivedAuditLogs => Set<ArchivedAuditLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("audit");
        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ActorId).HasMaxLength(160).IsRequired();
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Resource).HasMaxLength(160).IsRequired();
            entity.Property(x => x.Action).HasMaxLength(80).IsRequired();
            entity.Property(x => x.EntityName).HasMaxLength(160).IsRequired();
            entity.Property(x => x.EntityId).HasMaxLength(160);
            entity.Property(x => x.CorrelationId).HasMaxLength(128).IsRequired();
            entity.Property(x => x.CausationId).HasMaxLength(128);
            entity.Property(x => x.RequestId).HasMaxLength(128);
            entity.Property(x => x.IpAddress).HasMaxLength(64);
            entity.Property(x => x.UserAgent).HasMaxLength(512);
            entity.HasIndex(x => new { x.TenantId, x.CreatedAtUtc });
            entity.HasIndex(x => new { x.TenantId, x.Resource, x.Action });
            entity.HasIndex(x => x.CorrelationId);
        });
        modelBuilder.Entity<ArchivedAuditLog>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.SnapshotJson).IsRequired();
            entity.HasIndex(x => x.OriginalAuditLogId).IsUnique();
            entity.HasIndex(x => new { x.TenantId, x.OriginalCreatedAtUtc });
        });
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        if (ChangeTracker.Entries<AuditLog>().Any(x => x.State is EntityState.Modified or EntityState.Deleted))
            throw new InvalidOperationException("AuditLog is append-only; retention must use the transactional archive service.");
        return base.SaveChangesAsync(cancellationToken);
    }
}

public sealed class EfAuditStore(AuditDbContext db) : IAuditStore
{
    public Task AddAsync(AuditLog auditLog, CancellationToken cancellationToken) => db.AuditLogs.AddAsync(auditLog, cancellationToken).AsTask();
    public Task<AuditLog?> GetAsync(string tenantId, Guid id, CancellationToken cancellationToken) => db.AuditLogs.AsNoTracking().SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Id == id, cancellationToken);
    public async Task<PagedResult<AuditLog>> SearchAsync(AuditSearchRequest request, CancellationToken cancellationToken)
    {
        var query = db.AuditLogs.AsNoTracking().AsQueryable();
        if (!string.IsNullOrWhiteSpace(request.TenantId)) query = query.Where(x => x.TenantId == request.TenantId.ToLower());
        if (!string.IsNullOrWhiteSpace(request.Resource)) query = query.Where(x => x.Resource == request.Resource.ToLower());
        if (!string.IsNullOrWhiteSpace(request.Action)) query = query.Where(x => x.Action == request.Action.ToLower());
        if (!string.IsNullOrWhiteSpace(request.ActorId)) query = query.Where(x => x.ActorId == request.ActorId);
        if (request.FromUtc.HasValue) query = query.Where(x => x.CreatedAtUtc >= request.FromUtc);
        if (request.ToUtc.HasValue) query = query.Where(x => x.CreatedAtUtc <= request.ToUtc);
        if (request.Severity.HasValue) query = query.Where(x => (int)x.Severity == request.Severity);
        if (!string.IsNullOrWhiteSpace(request.CorrelationId)) query = query.Where(x => x.CorrelationId == request.CorrelationId.Trim());
        var total = await query.LongCountAsync(cancellationToken);
        var items = await query.OrderByDescending(x => x.CreatedAtUtc).ThenBy(x => x.Id)
            .Skip((request.Page - 1) * request.PageSize).Take(request.PageSize).ToArrayAsync(cancellationToken);
        return new(items, request.Page, request.PageSize, total);
    }

    public async Task<AuditSummaryResponse> SummaryAsync(
        string tenantId,
        DateTimeOffset fromUtc,
        DateTimeOffset toUtc,
        CancellationToken cancellationToken)
    {
        var query = db.AuditLogs.AsNoTracking()
            .Where(x => x.TenantId == tenantId && x.CreatedAtUtc >= fromUtc && x.CreatedAtUtc <= toUtc);

        var total = await query.LongCountAsync(cancellationToken);
        var warningOrHigher = await query.LongCountAsync(x => (int)x.Severity >= (int)AuditSeverity.Warning, cancellationToken);
        var errorOrHigher = await query.LongCountAsync(x => (int)x.Severity >= (int)AuditSeverity.Error, cancellationToken);

        var resourceCounts = await query
            .GroupBy(x => x.Resource)
            .Select(group => new { Key = group.Key, Count = group.LongCount() })
            .OrderByDescending(x => x.Count)
            .ThenBy(x => x.Key)
            .Take(10)
            .ToArrayAsync(cancellationToken);

        var actionCounts = await query
            .GroupBy(x => x.Action)
            .Select(group => new { Key = group.Key, Count = group.LongCount() })
            .OrderByDescending(x => x.Count)
            .ThenBy(x => x.Key)
            .Take(10)
            .ToArrayAsync(cancellationToken);

        var topResources = resourceCounts.Select(x => new AuditMetricResponse(x.Key, x.Count)).ToArray();
        var topActions = actionCounts.Select(x => new AuditMetricResponse(x.Key, x.Count)).ToArray();

        return new AuditSummaryResponse(tenantId, fromUtc, toUtc, total, warningOrHigher, errorOrHigher, topResources, topActions);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);
}

public static class AuditDependencyInjection
{
    public static IServiceCollection AddAuditFoundation(this IServiceCollection services, IConfiguration configuration)
    {
        var connection = configuration.GetConnectionString("AuditDb") ?? throw new InvalidOperationException("ConnectionStrings:AuditDb is required.");
        services.AddDbContext<AuditDbContext>(options => options.UseSqlServer(connection));
        services.AddScoped<IAuditStore, EfAuditStore>();
        services.AddScoped<AuditService>();
        services.AddScoped<AuditRetentionService>();
        services.AddSingleton(TimeProvider.System);
        if (configuration.GetValue<bool>("Audit:InitializeDatabase")) services.AddHostedService<AuditDatabaseInitializer>();
        if (configuration.GetValue<bool>("Audit:Retention:Enabled")) services.AddHostedService<AuditRetentionWorker>();
        return services;
    }
}

internal sealed class AuditDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AuditDbContext>();
        await db.Database.EnsureCreatedAsync(cancellationToken);
        await db.Database.ExecuteSqlRawAsync("""
            IF OBJECT_ID(N'[audit].[ArchivedAuditLogs]', N'U') IS NULL
            BEGIN
                CREATE TABLE [audit].[ArchivedAuditLogs] (
                    [Id] uniqueidentifier NOT NULL,
                    [OriginalAuditLogId] uniqueidentifier NOT NULL,
                    [TenantId] nvarchar(64) NOT NULL,
                    [OriginalCreatedAtUtc] datetimeoffset NOT NULL,
                    [ArchivedAtUtc] datetimeoffset NOT NULL,
                    [SnapshotJson] nvarchar(max) NOT NULL,
                    CONSTRAINT [PK_ArchivedAuditLogs] PRIMARY KEY ([Id])
                );
                CREATE UNIQUE INDEX [IX_ArchivedAuditLogs_OriginalAuditLogId]
                    ON [audit].[ArchivedAuditLogs] ([OriginalAuditLogId]);
                CREATE INDEX [IX_ArchivedAuditLogs_TenantId_OriginalCreatedAtUtc]
                    ON [audit].[ArchivedAuditLogs] ([TenantId], [OriginalCreatedAtUtc]);
            END
            """, cancellationToken);
    }
    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
