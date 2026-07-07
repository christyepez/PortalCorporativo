using Portal.BuildingBlocks;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Catalog.Api");
var app = builder.Build();
app.UsePortalFoundation();
app.MapGet("/", () => Results.Ok(new { service = "Portal.Catalog.Api", status = "bootstrap" }));
app.Run();
