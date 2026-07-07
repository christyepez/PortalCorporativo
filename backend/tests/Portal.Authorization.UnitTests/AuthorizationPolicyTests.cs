using System.Security.Claims;using Microsoft.AspNetCore.Authorization;using Microsoft.Extensions.DependencyInjection;using Portal.BuildingBlocks;using Xunit;
namespace Portal.Authorization.UnitTests;
public sealed class AuthorizationPolicyTests
{
 static IAuthorizationService Service(){var services=new ServiceCollection();services.AddLogging();services.AddPortalPermissionAuthorization();return services.BuildServiceProvider().GetRequiredService<IAuthorizationService>();}
 static ClaimsPrincipal User(params string[] permissions){var claims=new List<Claim>{new(ClaimTypes.NameIdentifier,"test-user")};claims.AddRange(permissions.Select(x=>new Claim(PortalPermissions.ClaimType,x)));return new(new ClaimsIdentity(claims,"test"));}
 [Fact]public async Task Anonymous_user_is_denied()=>Assert.False((await Service().AuthorizeAsync(new ClaimsPrincipal(),null,PortalPermissions.SecurityManage)).Succeeded);
 [Fact]public async Task Authenticated_user_without_permission_is_denied()=>Assert.False((await Service().AuthorizeAsync(User(),null,PortalPermissions.SecurityManage)).Succeeded);
 [Fact]public async Task Wrong_permission_is_denied()=>Assert.False((await Service().AuthorizeAsync(User(PortalPermissions.MenuRead),null,PortalPermissions.SecurityManage)).Succeeded);
 [Theory]
 [InlineData(PortalPermissions.SecurityManage)][InlineData(PortalPermissions.ConfigurationManage)][InlineData(PortalPermissions.ConfigurationRead)]
 [InlineData(PortalPermissions.MenuManage)][InlineData(PortalPermissions.MenuRead)][InlineData(PortalPermissions.AuditRead)]
 [InlineData(PortalPermissions.AuditWrite)][InlineData(PortalPermissions.NotificationManage)][InlineData(PortalPermissions.NotificationSend)]
 [InlineData(PortalPermissions.NotificationRead)]
 public async Task Correct_permission_is_granted(string permission)=>Assert.True((await Service().AuthorizeAsync(User(permission),null,permission)).Succeeded);
 [Fact]public void Permission_names_are_unique()=>Assert.Equal(PortalPermissions.All.Length,PortalPermissions.All.Distinct().Count());
}
