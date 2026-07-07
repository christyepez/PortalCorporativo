using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Integration.Application;
using Portal.Integration.Infrastructure;
using Portal.Integration.Worker;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Integration.Worker");
builder.Services.AddReliableMessaging(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<IntegrationDbContext>("integration-db");
builder.Services.Configure<OutboxWorkerOptions>(builder.Configuration.GetSection("Worker"));
builder.Services.AddSingleton<IEventPublisher, DevelopmentLogPublisher>();
builder.Services.AddScoped<OutboxProcessor>();
builder.Services.AddHostedService<OutboxBackgroundWorker>();
var app = builder.Build();
app.UsePortalFoundation();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapGet("/", () => Results.Ok(new { service = "Portal.Integration.Worker", status = "foundation" }));
app.Run();
