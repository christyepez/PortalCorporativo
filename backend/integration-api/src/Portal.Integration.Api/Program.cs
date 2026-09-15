using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Integration.Api;
using Portal.Integration.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Integration.Api");
builder.Services.AddReliableMessaging(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<IntegrationDbContext>("integration-db");
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapIntegrationEndpoints();
app.Run();
