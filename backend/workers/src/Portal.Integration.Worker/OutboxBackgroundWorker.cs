using Microsoft.Extensions.Options;
using Portal.Integration.Application;
using Portal.Integration.Contracts;

namespace Portal.Integration.Worker;

public sealed class OutboxWorkerOptions
{
    public bool Enabled { get; init; }
    public string Transport { get; init; } = "Disabled";
    public int PollIntervalSeconds { get; init; } = 5;
    public int BatchSize { get; init; } = 50;
    public int MaxAttempts { get; init; } = 5;
    public int BaseRetrySeconds { get; init; } = 5;
    public int ProcessingLeaseSeconds { get; init; } = 60;
}

public sealed class LocalLogPublisher(IOptions<OutboxWorkerOptions> options, ILogger<LocalLogPublisher> logger) : IEventPublisher
{
    public Task PublishAsync(IntegrationEventEnvelopeV1 message, CancellationToken cancellationToken)
    {
        if (!string.Equals(options.Value.Transport, "LocalLog", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("No local event transport is configured. Use LocalLog only for PROD-local verification.");

        logger.LogInformation(
            "Local transport published {EventType} {MessageId} with tenant {TenantId}, idempotency {IdempotencyKey}, correlation {CorrelationId}",
            message.EventType,
            message.MessageId,
            message.TenantId,
            message.IdempotencyKey,
            message.CorrelationId);
        return Task.CompletedTask;
    }
}

public sealed class OutboxBackgroundWorker(IServiceProvider services, IOptions<OutboxWorkerOptions> options,
    ILogger<OutboxBackgroundWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!options.Value.Enabled) { logger.LogInformation("Outbox worker is disabled."); return; }
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await using var scope = services.CreateAsyncScope();
                var processor = scope.ServiceProvider.GetRequiredService<OutboxProcessor>();
                await processor.ProcessBatchAsync(options.Value.BatchSize, options.Value.MaxAttempts,
                    TimeSpan.FromSeconds(options.Value.BaseRetrySeconds),
                    TimeSpan.FromSeconds(Math.Max(5, options.Value.ProcessingLeaseSeconds)),
                    stoppingToken);
            }
            catch (Exception exception) when (!stoppingToken.IsCancellationRequested)
            { logger.LogError(exception, "Outbox processing cycle failed."); }
            await Task.Delay(TimeSpan.FromSeconds(Math.Max(1, options.Value.PollIntervalSeconds)), stoppingToken);
        }
    }
}
