using Portal.BuildingBlocks;
using Portal.Catalog.Api;
using Portal.Catalog.Application;
using Portal.Catalog.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Catalog.Api");
builder.Services.AddCatalogFoundation(builder.Configuration);
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapCatalogEndpoints();
app.Run();
