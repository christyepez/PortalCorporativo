using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Portal.Menu.Application;
using Portal.Menu.Domain;
using Portal.Security.Contracts;

namespace Portal.Menu.Infrastructure;
public sealed class MenuDbContext(DbContextOptions<MenuDbContext> options) : DbContext(options)
{
 public DbSet<MenuDefinition> Menus=>Set<MenuDefinition>(); public DbSet<MenuItem> Items=>Set<MenuItem>(); public DbSet<MenuAction> Actions=>Set<MenuAction>();
 protected override void OnModelCreating(ModelBuilder m) { m.HasDefaultSchema("menu"); m.Entity<MenuDefinition>(e=>{e.HasKey(x=>x.Id);e.Property(x=>x.TenantId).HasMaxLength(64);e.Property(x=>x.ModuleCode).HasMaxLength(100);e.Property(x=>x.Name).HasMaxLength(160);e.HasIndex(x=>new{x.TenantId,x.ModuleCode}).IsUnique();}); m.Entity<MenuItem>(e=>{e.HasKey(x=>x.Id);e.Property(x=>x.Code).HasMaxLength(100);e.Property(x=>x.Route).HasMaxLength(300);e.Property(x=>x.ResourceKey).HasMaxLength(160);e.Property(x=>x.PermissionCode).HasMaxLength(180);e.HasIndex(x=>new{x.MenuId,x.Code}).IsUnique();e.HasOne<MenuDefinition>().WithMany().HasForeignKey(x=>x.MenuId);}); m.Entity<MenuAction>(e=>{e.HasKey(x=>x.Id);e.Property(x=>x.Code).HasMaxLength(80);e.Property(x=>x.PermissionCode).HasMaxLength(180);e.HasOne<MenuItem>().WithMany().HasForeignKey(x=>x.MenuItemId);}); Seed(m); }
 static void Seed(ModelBuilder m) { var menu=Guid.Parse("40000000-0000-0000-0000-000000000001"); m.Entity<MenuDefinition>().HasData(MenuDefinition.Seed(menu,"default","portal","Administración")); var rows=new[]{(Guid.Parse("41000000-0000-0000-0000-000000000001"),"security","Seguridad","/portal/security","shield",1,"portal.security","portal.security.manage"),(Guid.Parse("41000000-0000-0000-0000-000000000002"),"configuration","Configuración","/portal/configuration","settings",2,"portal.configuration","portal.configuration.manage"),(Guid.Parse("41000000-0000-0000-0000-000000000003"),"audit","Auditoría","/portal/audit","history",3,"portal.audit","portal.audit.read"),(Guid.Parse("41000000-0000-0000-0000-000000000004"),"notifications","Notificaciones","/portal/notifications","notifications",4,"portal.notification","portal.notification.manage")}; m.Entity<MenuItem>().HasData(rows.Select(x=>MenuItem.Seed(x.Item1,menu,null,x.Item2,x.Item3,x.Item4,x.Item5,x.Item6,x.Item7,x.Item8))); var actions=new[]{("view","Ver"),("create","Crear"),("edit","Editar"),("deactivate","Desactivar")}; var index=1; m.Entity<MenuAction>().HasData(rows.SelectMany(row=>actions.Select(a=>MenuAction.Seed(Guid.Parse($"42000000-0000-0000-0000-{index++:000000000000}"),row.Item1,a.Item1,a.Item2,row.Item8,index)))); }
}
public sealed class EfMenuStore(MenuDbContext db):IMenuStore
{ public Task<MenuDefinition?> GetMenuAsync(string tenant,Guid id,CancellationToken c)=>db.Menus.SingleOrDefaultAsync(x=>x.TenantId==tenant&&x.Id==id,c); public Task<MenuDefinition?> GetMenuByModuleAsync(string t,string m,CancellationToken c)=>db.Menus.SingleOrDefaultAsync(x=>x.TenantId==t&&x.ModuleCode==m&&x.IsActive,c); public Task<MenuItem?> GetItemAsync(string tenant,Guid id,CancellationToken c)=>db.Items.Where(x=>x.Id==id).Join(db.Menus.Where(m=>m.TenantId==tenant),x=>x.MenuId,m=>m.Id,(x,m)=>x).SingleOrDefaultAsync(c); public async Task<IReadOnlyCollection<MenuItem>> GetItemsAsync(string tenant,Guid id,CancellationToken c)=>await db.Items.AsNoTracking().Where(x=>x.MenuId==id).Join(db.Menus.AsNoTracking().Where(m=>m.TenantId==tenant),x=>x.MenuId,m=>m.Id,(x,m)=>x).ToArrayAsync(c); public Task AddAsync<T>(T v,CancellationToken c)where T:class=>db.Set<T>().AddAsync(v,c).AsTask();public Task SaveChangesAsync(CancellationToken c)=>db.SaveChangesAsync(c);}
public sealed class SecurityPermissionChecker(IHttpClientFactory clients,IHttpContextAccessor accessor):IPermissionChecker
{ public async Task<bool> HasPermissionAsync(Guid user,string resource,string action,CancellationToken ct){var client=clients.CreateClient("security");var auth=accessor.HttpContext?.Request.Headers.Authorization.ToString();if(!string.IsNullOrWhiteSpace(auth))client.DefaultRequestHeaders.Authorization=AuthenticationHeaderValue.Parse(auth);var response=await client.PostAsJsonAsync("/api/security/check-permission",new CheckPermissionRequest(user,resource,action),ct);if(!response.IsSuccessStatusCode)return false;var envelope=await response.Content.ReadFromJsonAsync<Portal.BuildingBlocks.ApiResponse<PermissionDecisionResponse>>(cancellationToken:ct);return envelope?.Data?.Allowed==true;}}
public sealed class StructuredMenuRecorder(ILogger<StructuredMenuRecorder> log):IMenuChangeRecorder{public Task RecordAsync(string a,string id,object p,string c,CancellationToken ct){log.LogInformation("Menu change {Action} {EntityId} {CorrelationId} {@Payload}",a,id,c,p);return Task.CompletedTask;}}
public static class MenuDependencyInjection
{public static IServiceCollection AddMenuFoundation(this IServiceCollection s,IConfiguration c){var db=c.GetConnectionString("MenuDb")??throw new InvalidOperationException("MenuDb is required.");s.AddDbContext<MenuDbContext>(x=>x.UseSqlServer(db));s.AddScoped<IMenuStore,EfMenuStore>();s.AddScoped<IPermissionChecker,SecurityPermissionChecker>();s.AddScoped<IMenuChangeRecorder,StructuredMenuRecorder>();s.AddScoped<MenuService>();s.AddHttpContextAccessor();s.AddHttpClient("security",x=>x.BaseAddress=new(c["Security:BaseUrl"]??"http://security-api:8080"));if(c.GetValue<bool>("Menu:InitializeDatabase"))s.AddHostedService<Initializer>();return s;}}
internal sealed class Initializer(IServiceProvider services) : IHostedService
{
    private sealed record DefaultMenu(string ModuleCode, string Name, IReadOnlyCollection<DefaultItem> Items);
    private sealed record DefaultItem(
        string Code,
        string Label,
        string Route,
        int Order,
        string ResourceKey,
        string PermissionCode,
        string? MetadataJson = null);

    private static readonly DefaultMenu[] ApplicationMenus =
    [
        new("crm", "CRM", new DefaultItem[]
        {
            new("home", "Inicio", "/", 10, "crm", "crm.*"),
            new("leads", "Leads", "foundation/leads", 20, "crm", "crm.*"),
            new("accounts", "Cuentas", "foundation/accounts", 30, "crm", "crm.*"),
            new("contacts", "Contactos", "foundation/contacts", 40, "crm", "crm.*"),
            new("activities", "Actividades", "foundation/activities", 50, "crm", "crm.*"),
            new("opportunities", "Oportunidades", "foundation/opportunities", 60, "crm", "crm.*"),
            new("campaigns", "Campañas", "foundation/campaigns", 70, "crm", "crm.*"),
            new("segments", "Segmentos", "foundation/segments", 80, "crm", "crm.*"),
            new("cases", "Casos", "foundation/cases", 90, "crm", "crm.*"),
            new("interactions", "Interacciones", "foundation/interactions", 100, "crm", "crm.*"),
            new("notes", "Notas", "foundation/notes", 110, "crm", "crm.*"),
            new("pipelines", "Pipelines", "foundation/pipelines", 120, "crm", "crm.*"),
            new("documents", "Documentos", "foundation/documents", 130, "crm", "crm.*"),
            new("tags", "Etiquetas", "foundation/tags", 140, "crm", "crm.*"),
            new("assignments", "Asignaciones", "foundation/assignments", 150, "crm", "crm.*"),
            new("customer360", "Customer 360", "foundation/customer360", 160, "crm", "crm.*"),
            new("insights", "Insights", "foundation/insights", 170, "crm", "crm.*"),
            new("readiness", "Readiness", "readiness", 180, "crm", "crm.*")
        }),
        new("financial", "Financiero", new DefaultItem[]
        {
            new("dashboard", "Dashboard", "dashboard", 10, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("sri-readiness", "SRI readiness", "sri-readiness", 20, "financial.electronicdocuments", "financial.electronicdocuments.manage"),
            new("ats-readiness", "ATS readiness", "ats-readiness", 30, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("external-approvals", "Aprobaciones", "external-approvals", 40, "financial.electronicdocuments", "financial.electronicdocuments.manage"),
            new("tax-catalogs", "Catálogos tributarios", "tax-catalogs", 50, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("purchases", "Compras", "purchases", 60, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("voided-documents", "Anulados", "voided-documents", 70, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("chart-of-accounts", "Plan de cuentas", "accounting/accounts", 80, "financial.chartofaccounts", "financial.chartofaccounts.read"),
            new("journal-entries", "Asientos contables", "accounting/journal-entries", 90, "financial.journalentries", "financial.journalentries.read"),
            new("fiscal-years", "Años fiscales", "accounting/fiscal-years", 100, "financial.fiscalyears", "financial.fiscalyears.read"),
            new("fiscal-periods", "Períodos fiscales", "accounting/fiscal-periods", 110, "financial.fiscalperiods", "financial.fiscalperiods.read"),
            new("electronic-documents", "Documentos electrónicos", "operations/electronic-documents", 120, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("tax-reporting", "Reporting tributario", "operations/tax-reporting", 130, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("tax-action-queue", "Cola tributaria", "operations/tax-action-queue", 140, "financial.electronicdocuments", "financial.electronicdocuments.read"),
            new("tax-legal-review", "Revisión tributaria", "operations/tax-legal-review", 150, "financial.electronicdocuments", "financial.electronicdocuments.read")
        }),
        new("hr", "Talento Humano", new DefaultItem[]
        {
            new("summary", "Resumen", "/api/hr/employees", 10, "hr.employees", "hr.employees.view", "{\"dataPath\":\"/api/hr/employees\"}"),
            new("employees", "Empleados", "/api/hr/employees", 20, "hr.employees", "hr.employees.view", "{\"dataPath\":\"/api/hr/employees\"}"),
            new("new-employee", "Nuevo empleado", "/api/hr/employees", 30, "hr.employees", "hr.employees.manage", "{\"dataPath\":\"/api/hr/employees\"}")
        }),
        new("historiaspaolin", "HistoriasPaolin", new DefaultItem[]
        {
            new("channels", "Canales", "/api/historiaspaolin/api/channels", 10, "historiaspaolin.channels", "historiaspaolin.channels.view", "{\"dataPath\":\"/api/historiaspaolin/api/channels\"}"),
            new("episodes", "Episodios", "/api/historiaspaolin/api/historiaspaolin/episodes", 20, "historiaspaolin.episodes", "historiaspaolin.episodes.view", "{\"dataPath\":\"/api/historiaspaolin/api/historiaspaolin/episodes\"}")
        })
    ];

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var scope = services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<MenuDbContext>();
        await db.Database.EnsureCreatedAsync(cancellationToken);
        await BootstrapApplicationMenusAsync(db, cancellationToken);
    }

    private static async Task BootstrapApplicationMenusAsync(MenuDbContext db, CancellationToken cancellationToken)
    {
        const string tenantId = "default";

        foreach (var definition in ApplicationMenus)
        {
            var menu = await db.Menus.SingleOrDefaultAsync(
                x => x.TenantId == tenantId && x.ModuleCode == definition.ModuleCode,
                cancellationToken);

            if (menu is null)
            {
                menu = MenuDefinition.Create(tenantId, definition.ModuleCode, definition.Name);
                db.Menus.Add(menu);
                await db.SaveChangesAsync(cancellationToken);
            }

            var existingCodes = (await db.Items
                .AsNoTracking()
                .Where(x => x.MenuId == menu.Id)
                .Select(x => x.Code)
                .ToListAsync(cancellationToken))
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            foreach (var item in definition.Items.Where(x => !existingCodes.Contains(x.Code)))
            {
                db.Items.Add(MenuItem.Create(
                    menu.Id,
                    null,
                    item.Code,
                    item.Label,
                    item.Route,
                    null,
                    item.Order,
                    item.ResourceKey,
                    item.PermissionCode,
                    item.MetadataJson));
            }

            await db.SaveChangesAsync(cancellationToken);
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
