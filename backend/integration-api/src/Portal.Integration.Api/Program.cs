using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Integration.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Integration.Api");
builder.Services.AddReliableMessaging(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<IntegrationDbContext>("integration-db");
var app = builder.Build();
app.UsePortalFoundation();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapGet("/", () => Results.Ok(new { service = "Portal.Integration.Api", status = "foundation", note = "No public enqueue endpoint; use application adapters." }));
app.Run();
