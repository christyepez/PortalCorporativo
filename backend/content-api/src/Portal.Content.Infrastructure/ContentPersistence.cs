using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Portal.Content.Application;
using Portal.Content.Domain;

namespace Portal.Content.Infrastructure;

public sealed class ContentBlob
{
    public Guid DocumentId { get; set; }
    public byte[] Bytes { get; set; } = [];
}

public sealed class ContentDbContext(DbContextOptions<ContentDbContext> options) : DbContext(options)
{
    public DbSet<ContentDocument> Documents => Set<ContentDocument>();
    public DbSet<ContentBlob> Blobs => Set<ContentBlob>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("content");

        modelBuilder.Entity<ContentDocument>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ModuleCode).HasMaxLength(80).IsRequired();
            entity.Property(x => x.FileName).HasMaxLength(255).IsRequired();
            entity.Property(x => x.ContentType).HasMaxLength(120).IsRequired();
            entity.Property(x => x.Sha256).HasMaxLength(64).IsRequired();
            entity.HasIndex(x => new { x.ModuleCode, x.CreatedAt });
        });

        modelBuilder.Entity<ContentBlob>(entity =>
        {
            entity.HasKey(x => x.DocumentId);
            entity.Property(x => x.Bytes).IsRequired();
            entity.HasOne<ContentDocument>()
                .WithOne()
                .HasForeignKey<ContentBlob>(x => x.DocumentId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}

public sealed class EfContentRepository(ContentDbContext db) : IContentRepository
{
    public async Task<IReadOnlyCollection<ContentDocument>> ListAsync(string? moduleCode, bool? isActive, CancellationToken cancellationToken)
    {
        IQueryable<ContentDocument> query = db.Documents.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(moduleCode)) query = query.Where(x => x.ModuleCode == moduleCode.Trim());
        if (isActive.HasValue) query = query.Where(x => x.IsActive == isActive.Value);
        return await query.OrderByDescending(x => x.CreatedAt).ToArrayAsync(cancellationToken);
    }

    public async Task<StoredContent?> GetAsync(Guid id, CancellationToken cancellationToken)
    {
        var document = await db.Documents.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (document is null) return null;

        var blob = await db.Blobs.AsNoTracking().SingleOrDefaultAsync(x => x.DocumentId == id, cancellationToken);
        return blob is null ? null : new StoredContent(document, blob.Bytes);
    }

    public async Task AddAsync(StoredContent content, CancellationToken cancellationToken)
    {
        await db.Documents.AddAsync(content.Document, cancellationToken);
        await db.Blobs.AddAsync(new ContentBlob
        {
            DocumentId = content.Document.Id,
            Bytes = content.Bytes
        }, cancellationToken);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken) => db.SaveChangesAsync(cancellationToken);
}

public static class ContentDependencyInjection
{
    public static IServiceCollection AddContentFoundation(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("ContentDb")
            ?? throw new InvalidOperationException("ContentDb is required.");
        services.AddDbContext<ContentDbContext>(options => options.UseSqlServer(connectionString));
        services.AddScoped<IContentRepository, EfContentRepository>();
        services.AddScoped<ContentService>();
        if (string.Equals(configuration["Content:InitializeDatabase"], "true", StringComparison.OrdinalIgnoreCase))
            services.AddHostedService<ContentDatabaseInitializer>();
        return services;
    }
}

internal sealed class ContentDatabaseInitializer(IServiceProvider services) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        await scope.ServiceProvider.GetRequiredService<ContentDbContext>().Database.EnsureCreatedAsync(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
