using Portal.BuildingBlocks;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.Reporting.Api");
var app = builder.Build();
app.UsePortalFoundation();
app.MapGet("/", () => Results.Ok(new { service = "Portal.Reporting.Api", status = "bootstrap" }));
app.Run();
