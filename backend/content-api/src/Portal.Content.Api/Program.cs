using Portal.BuildingBlocks;
using Portal.Content.Api;
using Portal.Content.Application;
using Portal.Content.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Content.Api");
builder.Services.AddContentFoundation(builder.Configuration);
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddPortalPermissionAuthorization();

var app = builder.Build();
app.UsePortalFoundation();
app.UseAuthentication();
app.UseAuthorization();
app.MapContentEndpoints();
app.Run();
