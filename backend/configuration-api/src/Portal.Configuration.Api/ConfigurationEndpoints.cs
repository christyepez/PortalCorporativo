using Portal.BuildingBlocks; using Portal.Configuration.Application; using Portal.Configuration.Contracts;
namespace Portal.Configuration.Api;
public static class ConfigurationEndpoints
{
 public static IEndpointRouteBuilder MapConfigurationEndpoints(this IEndpointRouteBuilder e) { var g=e.MapGroup("/api/configuration").RequireAuthorization();
 g.MapPost("/items", async(CreateConfigurationRequest r,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.CreateAsync(r,h.TraceIdentifier,c),201)).RequireAuthorization(PortalPermissions.ConfigurationManage);
 g.MapPut("/items/{id:guid}",async(Guid id,UpdateConfigurationRequest r,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.UpdateAsync(id,r,h.TraceIdentifier,c))).RequireAuthorization(PortalPermissions.ConfigurationManage);
 g.MapGet("/effective",async(string key,string? moduleCode,Guid? userId,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.ResolveAsync(key,moduleCode,userId,c))).RequireAuthorization(PortalPermissions.ConfigurationRead);
 g.MapGet("/scopes/{scope:int}",async(int scope,string? moduleCode,Guid? userId,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.GetScopeAsync(scope,moduleCode,userId,c))).RequireAuthorization(PortalPermissions.ConfigurationRead);
 g.MapPost("/items/{id:guid}/activate",async(Guid id,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.SetActiveAsync(id,true,h.TraceIdentifier,c))).RequireAuthorization(PortalPermissions.ConfigurationManage);
 g.MapPost("/items/{id:guid}/deactivate",async(Guid id,ConfigurationService s,HttpContext h,CancellationToken c)=>Reply(h,await s.SetActiveAsync(id,false,h.TraceIdentifier,c))).RequireAuthorization(PortalPermissions.ConfigurationManage); return e; }
 static IResult Reply<T>(HttpContext h,Result<T> r,int status=200)=>r.IsSuccess?Results.Json(new ApiResponse<T>(r.Value,null,h.TraceIdentifier),statusCode:status):Results.Json(new ApiResponse<T>(default,r.Error,h.TraceIdentifier),statusCode:r.Error!.Code.EndsWith("not_found")?404:400);
}
