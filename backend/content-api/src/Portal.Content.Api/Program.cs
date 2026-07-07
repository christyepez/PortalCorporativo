using Portal.BuildingBlocks;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Content.Api");
var app = builder.Build();
app.UsePortalFoundation();
app.MapGet("/", () => Results.Ok(new { service = "Portal.Content.Api", status = "bootstrap" }));
app.Run();
