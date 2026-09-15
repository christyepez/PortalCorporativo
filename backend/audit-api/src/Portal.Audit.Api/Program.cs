using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.Audit.Api;
using Portal.Audit.Infrastructure;
using Portal.BuildingBlocks;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Audit.Api");
builder.Services.AddAuditFoundation(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<AuditDbContext>("audit-db");
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapAuditEndpoints();
app.Run();
public partial class Program;
