using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Portal.Security.Application;

namespace Portal.Security.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddSecurityInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("SecurityDb")
            ?? throw new InvalidOperationException("ConnectionStrings:SecurityDb must be configured.");

        services.AddDbContext<SecurityDbContext>(options => options.UseSqlServer(connectionString));
        services.AddScoped<ISecurityStore, EfSecurityStore>();
        services.AddScoped<SecurityService>();
        if (configuration.GetValue<bool>("Security:InitializeDatabase"))
            services.AddHostedService<SecurityDatabaseInitializer>();
        return services;
    }
}
