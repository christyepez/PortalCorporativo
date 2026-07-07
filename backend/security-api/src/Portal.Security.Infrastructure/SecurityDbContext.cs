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
        var superAdmin = Guid.Parse("10000000-0000-0000-0000-000000000001");
        var portalAdmin = Guid.Parse("10000000-0000-0000-0000-000000000002");
        var definitions = new[]
        {
            (Id: Guid.Parse("20000000-0000-0000-0000-000000000001"), Key: "portal.security", Name: "Portal Security"),
            (Id: Guid.Parse("20000000-0000-0000-0000-000000000002"), Key: "portal.menu", Name: "Portal Menu"),
            (Id: Guid.Parse("20000000-0000-0000-0000-000000000003"), Key: "portal.configuration", Name: "Portal Configuration"),
            (Id: Guid.Parse("20000000-0000-0000-0000-000000000004"), Key: "portal.audit", Name: "Portal Audit"),
            (Id: Guid.Parse("20000000-0000-0000-0000-000000000005"), Key: "portal.notification", Name: "Portal Notification")
        };
        var permissions = new[]
        {
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000001"), TenantIds.Default, "portal.security.manage", "portal.security", "manage"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000002"), TenantIds.Default, "portal.menu.manage", "portal.menu", "manage"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000003"), TenantIds.Default, "portal.configuration.manage", "portal.configuration", "manage"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000004"), TenantIds.Default, "portal.audit.read", "portal.audit", "read"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000005"), TenantIds.Default, "portal.notification.manage", "portal.notification", "manage"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000006"), TenantIds.Default, "portal.notification.send", "portal.notification", "send"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000007"), TenantIds.Default, "portal.notification.read", "portal.notification", "read"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000008"), TenantIds.Default, "portal.configuration.read", "portal.configuration", "read"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000009"), TenantIds.Default, "portal.menu.read", "portal.menu", "read"),
            Permission.Seed(Guid.Parse("30000000-0000-0000-0000-000000000010"), TenantIds.Default, "portal.audit.write", "portal.audit", "write")
        };

        modelBuilder.Entity<Tenant>().HasData(new Tenant(TenantIds.Default, "Default Tenant"));
        modelBuilder.Entity<Role>().HasData(
            Role.Seed(superAdmin, TenantIds.Default, "SuperAdmin"),
            Role.Seed(portalAdmin, TenantIds.Default, "PortalAdmin"));
        modelBuilder.Entity<Resource>().HasData(definitions.Select(x => Resource.Seed(x.Id, TenantIds.Default, x.Key, x.Name)));
        modelBuilder.Entity<Permission>().HasData(permissions);
        modelBuilder.Entity<RolePermission>().HasData(
            permissions.SelectMany(permission => new[]
            {
                RolePermission.Seed(TenantIds.Default, superAdmin, permission.Id),
                RolePermission.Seed(TenantIds.Default, portalAdmin, permission.Id)
            }));
    }
}
