using Portal.BuildingBlocks;

var builder = WebApplication.CreateBuilder(args);
builder.AddPortalFoundation("Portal.ApiGateway");
builder.Services.AddPortalJwtAuthentication(builder.Configuration);
builder.Services.AddAuthorization();
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();
app.UsePortalFoundation();

app.Use(async (context, next) =>
{
    if (!context.Request.Headers.ContainsKey("Authorization") &&
        context.Request.Cookies.TryGetValue("portal_local_session", out var localSessionToken) &&
        !string.IsNullOrWhiteSpace(localSessionToken))
    {
        context.Request.Headers.Authorization = $"Bearer {localSessionToken}";
    }

    await next();
});

app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/", () => Results.Ok(new { service = "Portal.ApiGateway", status = "ready" }));
app.MapReverseProxy();
app.Run();
