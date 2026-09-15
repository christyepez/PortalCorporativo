using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Menu.Api;
using Portal.Menu.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Menu.Api");
builder.Services.AddMenuFoundation(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<MenuDbContext>();
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapMenuEndpoints();
app.Run();
