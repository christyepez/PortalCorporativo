using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Portal.Integration.Application;
using Portal.Integration.Domain;

namespace Portal.Integration.Infrastructure;

public sealed class IntegrationDbContext(DbContextOptions<IntegrationDbContext> options) : DbContext(options)
{
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();
    public DbSet<InboxMessage> InboxMessages => Set<InboxMessage>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("integration");
        modelBuilder.Entity<OutboxMessage>(entity =>
        {
            entity.HasKey(x => x.MessageId);
            entity.Property(x => x.TenantId).HasMaxLength(64); entity.Property(x => x.AggregateType).HasMaxLength(160);
            entity.Property(x => x.AggregateId).HasMaxLength(160); entity.Property(x => x.EventType).HasMaxLength(200);
            entity.Property(x => x.CorrelationId).HasMaxLength(128); entity.Property(x => x.CausationId).HasMaxLength(128);
            entity.Property(x => x.IdempotencyKey).HasMaxLength(200); entity.Property(x => x.LastError).HasMaxLength(2000);
            entity.HasIndex(x => new { x.TenantId, x.IdempotencyKey }).IsUnique().HasFilter("[IdempotencyKey] IS NOT NULL");
            entity.HasIndex(x => new { x.Status, x.NextRetryAtUtc, x.CreatedAtUtc });
        });
        modelBuilder.Entity<InboxMessage>(entity =>
        {
            entity.HasKey(x => x.MessageId); entity.Property(x => x.TenantId).HasMaxLength(64);
            entity.Property(x => x.Source).HasMaxLength(160); entity.Property(x => x.EventType).HasMaxLength(200);
            entity.Property(x => x.CorrelationId).HasMaxLength(128); entity.Property(x => x.IdempotencyKey).HasMaxLength(200);
            entity.Property(x => x.LastError).HasMaxLength(2000);
            entity.HasIndex(x => new { x.TenantId, x.Source, x.IdempotencyKey }).IsUnique();
        });
    }
}

public sealed class EfReliableMessageStore(IntegrationDbContext db) : IReliableMessageStore
{
    public Task<OutboxMessage?> FindOutboxByIdempotencyKeyAsync(string tenantId, string key, CancellationToken ct) =>
        db.OutboxMessages.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.IdempotencyKey == key, ct);
    public Task<InboxMessage?> FindInboxAsync(string tenantId, string source, string key, CancellationToken ct) =>
        db.InboxMessages.SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Source == source && x.IdempotencyKey == key, ct);
    public async Task<IReadOnlyCollection<OutboxMessage>> GetPendingAsync(DateTimeOffset now, int batchSize, CancellationToken ct) =>
        await db.OutboxMessages.Where(x => (x.Status == MessageStatus.Pending || x.Status == MessageStatus.Failed)
            && (x.NextRetryAtUtc == null || x.NextRetryAtUtc <= now)).OrderBy(x => x.CreatedAtUtc).Take(batchSize).ToArrayAsync(ct);
    public Task AddAsync<T>(T entity, CancellationToken ct) where T : class => db.Set<T>().AddAsync(entity, ct).AsTask();
    public Task SaveChangesAsync(CancellationToken ct) => db.SaveChangesAsync(ct);
}

public static class IntegrationDependencyInjection
{
    public static IServiceCollection AddReliableMessaging(this IServiceCollection services, IConfiguration configuration)
    {
        var connection = configuration.GetConnectionString("IntegrationDb") ?? throw new InvalidOperationException("ConnectionStrings:IntegrationDb is required.");
        services.AddDbContext<IntegrationDbContext>(options => options.UseSqlServer(connection));
        services.AddScoped<IReliableMessageStore, EfReliableMessageStore>();
        services.AddScoped<ReliableMessagingService>();
        if (configuration.GetValue<bool>("Integration:InitializeDatabase")) services.AddHostedService<IntegrationDatabaseInitializer>();
        return services;
    }
}

internal sealed class IntegrationDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        await scope.ServiceProvider.GetRequiredService<IntegrationDbContext>().Database.EnsureCreatedAsync(cancellationToken);
    }
    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
