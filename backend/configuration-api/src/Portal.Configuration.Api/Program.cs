using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Configuration.Api;
using Portal.Configuration.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Configuration.Api");
builder.Services.AddConfigurationFoundation(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<ConfigurationDbContext>();
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapConfigurationEndpoints();
app.Run();
