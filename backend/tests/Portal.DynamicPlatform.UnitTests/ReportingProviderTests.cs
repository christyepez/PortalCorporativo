using System.Net;
using Portal.Reporting.Api;
using Xunit;

namespace Portal.DynamicPlatform.UnitTests;

public sealed class ReportingProviderTests
{
    [Fact]
    public async Task Portal_overview_uses_operational_readiness()
    {
        var provider = new OperationalReportingProvider(new Factory(HttpStatusCode.OK));
        var result = await provider.ExecuteAsync("tenant-a", "portal-overview", new Dictionary<string,string>(), DateTimeOffset.UtcNow, default);
        Assert.NotNull(result);
        Assert.Equal("OperationalReadiness", result!.SourceMode);
        Assert.NotEmpty(result.Rows);
        Assert.All(result.Rows, row => Assert.Equal(true, row["Ready"]));
    }

    [Fact]
    public async Task Module_status_uses_requested_module()
    {
        var provider = new OperationalReportingProvider(new Factory(HttpStatusCode.ServiceUnavailable));
        var result = await provider.ExecuteAsync("tenant-a", "module-activity",
            new Dictionary<string,string>{{"moduleCode","catalog"}}, DateTimeOffset.UtcNow, default);
        Assert.NotNull(result);
        var row = Assert.Single(result!.Rows);
        Assert.Equal("catalog", row["ModuleCode"]);
        Assert.Equal(false, row["Ready"]);
        Assert.Equal(503, row["StatusCode"]);
    }

    [Fact]
    public async Task Unknown_module_is_rejected()
    {
        var provider = new OperationalReportingProvider(new Factory(HttpStatusCode.OK));
        await Assert.ThrowsAsync<ArgumentException>(() => provider.ExecuteAsync("tenant-a", "module-activity",
            new Dictionary<string,string>{{"moduleCode","unknown-module"}}, DateTimeOffset.UtcNow, default));
    }

    private sealed class Factory(HttpStatusCode statusCode) : IHttpClientFactory
    {
        public HttpClient CreateClient(string name) => new(new Handler(statusCode), disposeHandler:true);
    }

    private sealed class Handler(HttpStatusCode statusCode) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            => Task.FromResult(new HttpResponseMessage(statusCode));
    }
}
