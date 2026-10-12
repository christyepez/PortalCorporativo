using Microsoft.EntityFrameworkCore;
using Portal.Security.Domain;

namespace Portal.Security.Infrastructure;

public sealed class SecurityDbContext(DbContextOptions<SecurityDbContext> options) : DbContext(options)
{
    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<Permission> Permissions => Set<Permission>();
    public DbSet<Resource> Resources => Set<Resource>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<RolePermission> RolePermissions => Set<RolePermission>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("security");

        modelBuilder.Entity<Tenant>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasMaxLength(64);
            entity.Property(x => x.Name).HasMaxLength(160).IsRequired();
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Email).HasMaxLength(320).IsRequired();
            entity.Property(x => x.NormalizedEmail).HasMaxLength(320).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(160).IsRequired();
            entity.HasIndex(x => new { x.TenantId, x.NormalizedEmail }).IsUnique();
            entity.HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(120).IsRequired();
            entity.Property(x => x.NormalizedName).HasMaxLength(120).IsRequired();
            entity.HasIndex(x => new { x.TenantId, x.NormalizedName }).IsUnique();
            entity.HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Resource>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Key).HasMaxLength(160).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(160).IsRequired();
            entity.HasIndex(x => new { x.TenantId, x.Key }).IsUnique();
            entity.HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Permission>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TenantId).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Code).HasMaxLength(180).IsRequired();
            entity.Property(x => x.ResourceKey).HasMaxLength(160).IsRequired();
            entity.Property(x => x.Action).HasMaxLength(80).IsRequired();
            entity.HasIndex(x => new { x.TenantId, x.Code }).IsUnique();
            entity.HasIndex(x => new { x.TenantId, x.ResourceKey, x.Action }).IsUnique();
            entity.HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(x => new { x.TenantId, x.UserId, x.RoleId });
            entity.Property(x => x.TenantId).HasMaxLength(64);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Role>().WithMany().HasForeignKey(x => x.RoleId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<RolePermission>(entity =>
        {
            entity.HasKey(x => new { x.TenantId, x.RoleId, x.PermissionId });
            entity.Property(x => x.TenantId).HasMaxLength(64);
            entity.HasOne<Role>().WithMany().HasForeignKey(x => x.RoleId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Permission>().WithMany().HasForeignKey(x => x.PermissionId).OnDelete(DeleteBehavior.Cascade);
        });

        Seed(modelBuilder);
    }

    private static void Seed(ModelBuilder modelBuilder)
    {
        var permissions = SecuritySeedCatalog.Permissions
            .Select(definition => Permission.Seed(
                definition.Id,
                TenantIds.Default,
                definition.Code,
                definition.ResourceKey,
                definition.Action))
            .ToArray();

        modelBuilder.Entity<Tenant>().HasData(new Tenant(TenantIds.Default, "Default Tenant"));
        modelBuilder.Entity<Role>().HasData(
            Role.Seed(SecuritySeedCatalog.SuperAdminRoleId, TenantIds.Default, "SuperAdmin"),
            Role.Seed(SecuritySeedCatalog.PortalAdminRoleId, TenantIds.Default, "PortalAdmin"));
        modelBuilder.Entity<Resource>().HasData(
            SecuritySeedCatalog.Resources.Select(definition =>
                Resource.Seed(definition.Id, TenantIds.Default, definition.Key, definition.Name)));
        modelBuilder.Entity<Permission>().HasData(permissions);

        var assignments = SecuritySeedCatalog.Permissions
            .SelectMany(definition =>
            {
                var rolePermissions = new List<RolePermission>
                {
                    RolePermission.Seed(TenantIds.Default, SecuritySeedCatalog.SuperAdminRoleId, definition.Id)
                };
                if (definition.GrantToPortalAdmin)
                {
                    rolePermissions.Add(RolePermission.Seed(TenantIds.Default, SecuritySeedCatalog.PortalAdminRoleId, definition.Id));
                }

                return rolePermissions;
            })
            .ToArray();

        modelBuilder.Entity<RolePermission>().HasData(assignments);
    }
}
