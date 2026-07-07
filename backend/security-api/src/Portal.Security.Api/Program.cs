using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Portal.BuildingBlocks;
using Portal.Security.Api;
using Portal.Security.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Security.Api");
builder.Services.AddSecurityInfrastructure(builder.Configuration);
builder.Services.AddHealthChecks().AddDbContextCheck<SecurityDbContext>("security-db");

var jwtSecret = builder.Configuration["Jwt:Secret"]
    ?? throw new InvalidOperationException("Jwt:Secret must be supplied through environment or secret storage.");
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health", new HealthCheckOptions());
app.MapSecurityEndpoints();
app.Run();

public partial class Program;
