using Portal.BuildingBlocks;
using Portal.Reporting.Api;
using Portal.Reporting.Application;
using Portal.Reporting.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Reporting.Api");
builder.Services.AddSingleton<IReportingProvider, InMemoryReportingProvider>();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<ReportingService>();
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapReportingEndpoints();
app.Run();
