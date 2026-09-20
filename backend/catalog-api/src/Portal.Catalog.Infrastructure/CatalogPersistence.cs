using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Portal.Catalog.Application;
using Portal.Catalog.Domain;

namespace Portal.Catalog.Infrastructure;

public sealed class CatalogDbContext(DbContextOptions<CatalogDbContext> options) : DbContext(options)
{
    public DbSet<CatalogEntry> Entries => Set<CatalogEntry>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("catalog");
        modelBuilder.Entity<CatalogEntry>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Catalog).HasMaxLength(80).IsRequired();
            entity.Property(x => x.Code).HasMaxLength(80).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(160).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(500);
            entity.HasIndex(x => new { x.Catalog, x.Code }).IsUnique();
        });
    }
}

public sealed class EfCatalogRepository(CatalogDbContext db) : ICatalogRepository
{
    public async Task<IReadOnlyCollection<CatalogEntry>> ListAsync(string? catalog, bool? isActive, CancellationToken cancellationToken)
    {
        IQueryable<CatalogEntry> query = db.Entries.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(catalog)) query = query.Where(x => x.Catalog == catalog.Trim());
        if (isActive.HasValue) query = query.Where(x => x.IsActive == isActive.Value);
        return await query.OrderBy(x => x.Catalog).ThenBy(x => x.SortOrder).ThenBy(x => x.Name).ToArrayAsync(cancellationToken);
    }

    public Task<CatalogEntry?> GetAsync(Guid id, CancellationToken cancellationToken) =>
        db.Entries.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

    public Task<CatalogEntry?> FindByCodeAsync(string catalog, string code, CancellationToken cancellationToken)
    {
        var normalizedCatalog = catalog.Trim();
        var normalizedCode = code.Trim();
        return db.Entries.AsNoTracking().SingleOrDefaultAsync(
            x => x.Catalog == normalizedCatalog && x.Code == normalizedCode,
            cancellationToken);
    }

    public Task AddAsync(CatalogEntry entry, CancellationToken cancellationToken) =>
        db.Entries.AddAsync(entry, cancellationToken).AsTask();

    public Task SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);
}

public static class CatalogDependencyInjection
{
    public static IServiceCollection AddCatalogFoundation(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("CatalogDb")
            ?? throw new InvalidOperationException("CatalogDb is required.");
        services.AddDbContext<CatalogDbContext>(options => options.UseSqlServer(connectionString));
        services.AddScoped<ICatalogRepository, EfCatalogRepository>();
        services.AddScoped<CatalogService>();
        if (string.Equals(configuration["Catalog:InitializeDatabase"], "true", StringComparison.OrdinalIgnoreCase))
            services.AddHostedService<CatalogDatabaseInitializer>();
        return services;
    }
}

internal sealed class CatalogDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        await scope.ServiceProvider.GetRequiredService<CatalogDbContext>().Database.EnsureCreatedAsync(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
