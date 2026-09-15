using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection;
using Portal.BuildingBlocks;
using Xunit;

namespace Portal.Authorization.UnitTests;

public sealed class AuthorizationPolicyTests
{
    private static IAuthorizationService Service()
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddPortalPermissionAuthorization();
        return services.BuildServiceProvider().GetRequiredService<IAuthorizationService>();
    }

    private static ClaimsPrincipal User(params string[] permissions)
    {
        var claims = new List<Claim> { new(ClaimTypes.NameIdentifier, "test-user") };
        claims.AddRange(permissions.Select(x => new Claim(PortalPermissions.ClaimType, x)));
        return new ClaimsPrincipal(new ClaimsIdentity(claims, "jwt-test"));
    }

    [Fact]
    public async Task Anonymous_user_is_denied()
        => Assert.False((await Service().AuthorizeAsync(new ClaimsPrincipal(), null, PortalPermissions.SecurityManage)).Succeeded);

    [Fact]
    public async Task Authenticated_user_without_permission_is_denied()
        => Assert.False((await Service().AuthorizeAsync(User(), null, PortalPermissions.SecurityManage)).Succeeded);

    [Fact]
    public async Task Wrong_permission_is_denied()
        => Assert.False((await Service().AuthorizeAsync(User(PortalPermissions.MenuRead), null, PortalPermissions.SecurityManage)).Succeeded);

    [Theory]
    [InlineData(PortalPermissions.SecurityManage)]
    [InlineData(PortalPermissions.ConfigurationManage)]
    [InlineData(PortalPermissions.ConfigurationRead)]
    [InlineData(PortalPermissions.MenuManage)]
    [InlineData(PortalPermissions.MenuRead)]
    [InlineData(PortalPermissions.AuditRead)]
    [InlineData(PortalPermissions.AuditWrite)]
    [InlineData(PortalPermissions.NotificationManage)]
    [InlineData(PortalPermissions.NotificationSend)]
    [InlineData(PortalPermissions.NotificationRead)]
    [InlineData(PortalPermissions.CatalogManage)]
    [InlineData(PortalPermissions.CatalogRead)]
    [InlineData(PortalPermissions.ContentManage)]
    [InlineData(PortalPermissions.ContentRead)]
    [InlineData(PortalPermissions.ReportingRead)]
    [InlineData(PortalPermissions.IntegrationManage)]
    [InlineData(PortalPermissions.IntegrationRead)]
    public async Task Correct_permission_is_granted(string permission)
        => Assert.True((await Service().AuthorizeAsync(User(permission), null, permission)).Succeeded);

    [Fact]
    public async Task Reissued_jwt_without_revoked_permission_is_denied()
    {
        var authorization = Service();
        var beforeRevocation = User(PortalPermissions.CatalogManage);
        var afterRevocation = User();

        Assert.True((await authorization.AuthorizeAsync(beforeRevocation, null, PortalPermissions.CatalogManage)).Succeeded);
        Assert.False((await authorization.AuthorizeAsync(afterRevocation, null, PortalPermissions.CatalogManage)).Succeeded);
    }

    [Fact]
    public void Permission_names_are_unique()
        => Assert.Equal(PortalPermissions.All.Length, PortalPermissions.All.Distinct().Count());
}
