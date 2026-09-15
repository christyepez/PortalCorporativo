using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Content.Api;
using Portal.Content.Application;
using Portal.Content.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Content.Api");

builder.Services.AddSingleton<IContentRepository, InMemoryContentRepository>();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<ContentService>();

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
app.MapContentEndpoints();
app.Run();
