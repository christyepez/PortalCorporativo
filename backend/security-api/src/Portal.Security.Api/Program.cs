using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Portal.BuildingBlocks;
using Portal.Security.Api;
using Portal.Security.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Security.Api");
builder.Services.AddSecurityInfrastructure(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<SecurityDbContext>("security-db");
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapSecurityEndpoints();
app.MapSecurityRevocationEndpoints();
app.Run();

public partial class Program;
