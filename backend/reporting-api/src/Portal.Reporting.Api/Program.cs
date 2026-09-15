using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Reporting.Api;
using Portal.Reporting.Application;
using Portal.Reporting.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Reporting.Api");

builder.Services.AddSingleton<IReportingProvider, InMemoryReportingProvider>();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<ReportingService>();

var secret = builder.Configuration["Jwt:Secret"] ?? "portal-local-placeholder-secret-change-me";
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "portal-local",
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"] ?? "portal-local",
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
        ValidateLifetime = true
    });
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapReportingEndpoints();
app.Run();
