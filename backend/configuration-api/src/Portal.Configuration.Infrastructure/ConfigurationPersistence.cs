using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Portal.Configuration.Application;
using Portal.Configuration.Domain;

namespace Portal.Configuration.Infrastructure;
public sealed class ConfigurationDbContext(DbContextOptions<ConfigurationDbContext> options) : DbContext(options)
{
    public DbSet<ConfigurationItem> Items => Set<ConfigurationItem>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("configuration"); modelBuilder.Entity<ConfigurationItem>(e =>
        { e.HasKey(x => x.Id); e.Property(x => x.Key).HasMaxLength(180); e.Property(x => x.TenantId).HasMaxLength(64); e.Property(x => x.ModuleCode).HasMaxLength(100); e.HasIndex(x => new { x.TenantId, x.Key, x.Scope, x.ModuleCode, x.UserId }).IsUnique(); });
    }
}
public sealed class EfConfigurationStore(ConfigurationDbContext db) : IConfigurationStore
{
    public Task<ConfigurationItem?> GetAsync(Guid id, CancellationToken ct) => db.Items.SingleOrDefaultAsync(x => x.Id == id, ct);
    public async Task<IReadOnlyCollection<ConfigurationItem>> FindCandidatesAsync(string tenant, string key, string? module, Guid? user, CancellationToken ct) => await db.Items.Where(x => x.TenantId == tenant && x.Key == key &&
        (x.Scope == ConfigurationScope.Global || x.Scope == ConfigurationScope.Tenant || (x.Scope == ConfigurationScope.Module && x.ModuleCode == module) || (x.Scope == ConfigurationScope.User && x.ModuleCode == module && x.UserId == user))).ToArrayAsync(ct);
    public async Task<IReadOnlyCollection<ConfigurationItem>> GetByScopeAsync(ConfigurationScope scope, string tenant, string? module, Guid? user, CancellationToken ct) => await db.Items.AsNoTracking().Where(x => x.TenantId == tenant && x.Scope == scope && (module == null || x.ModuleCode == module) && (user == null || x.UserId == user)).ToArrayAsync(ct);
    public Task AddAsync(ConfigurationItem item, CancellationToken ct) => db.Items.AddAsync(item, ct).AsTask(); public Task SaveChangesAsync(CancellationToken ct) => db.SaveChangesAsync(ct);
}
public sealed class StructuredConfigurationChangeRecorder(ILogger<StructuredConfigurationChangeRecorder> logger) : IPlatformChangeRecorder
{ public Task RecordAsync(string capability, string action, string entityId, object payload, string correlationId, CancellationToken ct) { logger.LogInformation("Platform change {Capability} {Action} {EntityId} {CorrelationId} {@Payload}", capability, action, entityId, correlationId, payload); return Task.CompletedTask; } }
public static class ConfigurationDependencyInjection
{
    public static IServiceCollection AddConfigurationFoundation(this IServiceCollection services, IConfiguration configuration)
    { var c = configuration.GetConnectionString("ConfigurationDb") ?? throw new InvalidOperationException("ConfigurationDb is required."); services.AddDbContext<ConfigurationDbContext>(x => x.UseSqlServer(c)); services.AddScoped<IConfigurationStore, EfConfigurationStore>(); services.AddScoped<IPlatformChangeRecorder, StructuredConfigurationChangeRecorder>(); services.AddScoped<ConfigurationService>(); if (configuration.GetValue<bool>("Configuration:InitializeDatabase")) services.AddHostedService<Initializer>(); return services; }
}
internal sealed class Initializer(IServiceProvider services) : IHostedService
{ public async Task StartAsync(CancellationToken ct) { await using var s = services.CreateAsyncScope(); await s.ServiceProvider.GetRequiredService<ConfigurationDbContext>().Database.EnsureCreatedAsync(ct); } public Task StopAsync(CancellationToken ct) => Task.CompletedTask; }
