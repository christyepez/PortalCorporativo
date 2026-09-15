using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Catalog.Api;
using Portal.Catalog.Application;
using Portal.Catalog.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Catalog.Api");

builder.Services.AddSingleton<ICatalogRepository, InMemoryCatalogRepository>();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<CatalogService>();

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
app.MapCatalogEndpoints();
app.Run();
