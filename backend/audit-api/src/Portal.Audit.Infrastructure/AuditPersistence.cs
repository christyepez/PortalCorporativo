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
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        if (ChangeTracker.Entries<AuditLog>().Any(x => x.State is EntityState.Modified or EntityState.Deleted))
            throw new InvalidOperationException("AuditLog is append-only.");
        return base.SaveChangesAsync(cancellationToken);
    }
}

public sealed class EfAuditStore(AuditDbContext db) : IAuditStore
{
    public Task AddAsync(AuditLog auditLog, CancellationToken cancellationToken) => db.AuditLogs.AddAsync(auditLog, cancellationToken).AsTask();
    public Task<AuditLog?> GetAsync(Guid id, CancellationToken cancellationToken) => db.AuditLogs.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
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
        var total = await query.LongCountAsync(cancellationToken);
        var items = await query.OrderByDescending(x => x.CreatedAtUtc).ThenBy(x => x.Id)
            .Skip((request.Page - 1) * request.PageSize).Take(request.PageSize).ToArrayAsync(cancellationToken);
        return new(items, request.Page, request.PageSize, total);
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
        if (configuration.GetValue<bool>("Audit:InitializeDatabase")) services.AddHostedService<AuditDatabaseInitializer>();
        return services;
    }
}

internal sealed class AuditDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        await scope.ServiceProvider.GetRequiredService<AuditDbContext>().Database.EnsureCreatedAsync(cancellationToken);
    }
    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
