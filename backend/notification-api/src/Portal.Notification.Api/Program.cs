using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Portal.BuildingBlocks;
using Portal.Notification.Api;
using Portal.Notification.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Notification.Api");
builder.Services.AddNotificationFoundation(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<NotificationDbContext>();
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapNotificationEndpoints();
app.Run();
public partial class Program;
