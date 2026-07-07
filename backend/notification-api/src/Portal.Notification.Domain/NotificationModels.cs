using System.Text.Json;

namespace Portal.Notification.Domain;

public enum NotificationChannel { Internal = 0, EmailDev = 1, LogDev = 2 }
public enum NotificationStatus { Pending = 0, Processing = 1, Sent = 2, Failed = 3, Cancelled = 4, DeadLetter = 5 }

public sealed class NotificationTemplate
{
    private NotificationTemplate() { }
    private NotificationTemplate(Guid id, string tenantId, string code, string subject, string body, string allowedVariablesJson, NotificationChannel channel, DateTimeOffset now)
    { Id=id; TenantId=Required(tenantId,64); Code=Required(code,160).ToLowerInvariant(); Subject=Required(subject,240); Body=Required(body,8000); ValidateJson(allowedVariablesJson); AllowedVariablesJson=allowedVariablesJson; DefaultChannel=channel; Version=1; IsActive=true; CreatedAtUtc=UpdatedAtUtc=now; }
    public Guid Id { get; private set; } public string TenantId { get; private set; }=null!; public string Code { get; private set; }=null!;
    public string Subject { get; private set; }=null!; public string Body { get; private set; }=null!; public string AllowedVariablesJson { get; private set; }="[]";
    public NotificationChannel DefaultChannel { get; private set; } public int Version { get; private set; } public bool IsActive { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; } public DateTimeOffset UpdatedAtUtc { get; private set; }
    public static NotificationTemplate Create(string tenantId,string code,string subject,string body,string allowedVariablesJson,NotificationChannel channel,DateTimeOffset now)=>new(Guid.NewGuid(),tenantId,code,subject,body,allowedVariablesJson,channel,now);
    public void Update(string subject,string body,string allowedVariablesJson,NotificationChannel channel,DateTimeOffset now){Subject=Required(subject,240);Body=Required(body,8000);ValidateJson(allowedVariablesJson);AllowedVariablesJson=allowedVariablesJson;DefaultChannel=channel;Version++;UpdatedAtUtc=now;}
    public void SetActive(bool active,DateTimeOffset now){IsActive=active;UpdatedAtUtc=now;}
    private static string Required(string value,int max){if(string.IsNullOrWhiteSpace(value)||value.Length>max)throw new ArgumentException("Required value is invalid.");return value.Trim();}
    private static void ValidateJson(string value){using var doc=JsonDocument.Parse(value);if(doc.RootElement.ValueKind!=JsonValueKind.Array)throw new ArgumentException("Allowed variables must be a JSON array.");}
}

public sealed class NotificationMessage
{
    private NotificationMessage() { }
    private readonly List<NotificationRecipient> _recipients=[]; private readonly List<DeliveryAttempt> _attempts=[];
    public Guid Id { get; private set; } public string TenantId { get; private set; }=null!; public Guid TemplateId { get; private set; }
    public string TemplateCode { get; private set; }=null!; public int TemplateVersion { get; private set; } public NotificationChannel Channel { get; private set; }
    public NotificationStatus Status { get; private set; } public string Subject { get; private set; }=null!; public string Body { get; private set; }=null!;
    public string CorrelationId { get; private set; }=null!; public string IdempotencyKey { get; private set; }=null!; public string? MetadataJson { get; private set; }
    public DateTimeOffset CreatedAtUtc { get; private set; } public DateTimeOffset? ScheduledAtUtc { get; private set; } public DateTimeOffset? SentAtUtc { get; private set; }
    public DateTimeOffset? FailedAtUtc { get; private set; } public DateTimeOffset? NextAttemptAtUtc { get; private set; } public int AttemptCount { get; private set; } public string? LastError { get; private set; }
    public IReadOnlyCollection<NotificationRecipient> Recipients=>_recipients; public IReadOnlyCollection<DeliveryAttempt> Attempts=>_attempts;
    public static NotificationMessage Request(string tenantId,NotificationTemplate template,NotificationChannel? channel,string subject,string body,IEnumerable<string> recipients,string correlationId,string idempotencyKey,string? metadata,DateTimeOffset now,DateTimeOffset? scheduled)
    { if(!template.IsActive)throw new InvalidOperationException("Template is inactive."); var values=recipients.Where(x=>!string.IsNullOrWhiteSpace(x)).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();if(values.Length==0)throw new ArgumentException("At least one recipient is required.");
      var m=new NotificationMessage{Id=Guid.NewGuid(),TenantId=Required(tenantId,64),TemplateId=template.Id,TemplateCode=template.Code,TemplateVersion=template.Version,Channel=channel??template.DefaultChannel,Status=NotificationStatus.Pending,Subject=Required(subject,240),Body=Required(body,8000),CorrelationId=Required(correlationId,128),IdempotencyKey=Required(idempotencyKey,200),MetadataJson=OptionalJson(metadata),CreatedAtUtc=now,ScheduledAtUtc=scheduled,NextAttemptAtUtc=scheduled??now};
      foreach(var value in values)m._recipients.Add(NotificationRecipient.Create(m.Id,value));return m; }
    public void MarkProcessing(DateTimeOffset now){if(Status is not(NotificationStatus.Pending or NotificationStatus.Failed))throw new InvalidOperationException("Message cannot be processed.");if(NextAttemptAtUtc>now)throw new InvalidOperationException("Message is not due.");Status=NotificationStatus.Processing;AttemptCount++;}
    public void MarkSent(DateTimeOffset now,string provider){if(Status!=NotificationStatus.Processing)throw new InvalidOperationException("Message is not processing.");Status=NotificationStatus.Sent;SentAtUtc=now;NextAttemptAtUtc=null;LastError=null;_attempts.Add(DeliveryAttempt.Success(Id,AttemptCount,provider,now));}
    public void MarkFailed(string error,string provider,DateTimeOffset now,int maxAttempts,TimeSpan delay){if(Status!=NotificationStatus.Processing)throw new InvalidOperationException("Message is not processing.");LastError=Required(error,1000);FailedAtUtc=now;_attempts.Add(DeliveryAttempt.Failure(Id,AttemptCount,provider,LastError,now));if(AttemptCount>=maxAttempts){Status=NotificationStatus.DeadLetter;NextAttemptAtUtc=null;}else{Status=NotificationStatus.Failed;NextAttemptAtUtc=now+delay;}}
    public void Retry(DateTimeOffset now){if(Status is not(NotificationStatus.Failed or NotificationStatus.DeadLetter))throw new InvalidOperationException("Only failed messages can be retried.");Status=NotificationStatus.Pending;NextAttemptAtUtc=now;LastError=null;}
    public void Cancel(){if(Status is NotificationStatus.Sent or NotificationStatus.Cancelled)throw new InvalidOperationException("Message cannot be cancelled.");Status=NotificationStatus.Cancelled;NextAttemptAtUtc=null;}
    private static string Required(string value,int max){if(string.IsNullOrWhiteSpace(value)||value.Length>max)throw new ArgumentException("Required value is invalid.");return value.Trim();}
    private static string? OptionalJson(string? value){if(string.IsNullOrWhiteSpace(value))return null;using var _=JsonDocument.Parse(value);return value;}
}
public sealed class NotificationRecipient { private NotificationRecipient(){} public Guid Id{get;private set;} public Guid MessageId{get;private set;} public string Address{get;private set;}=null!; internal static NotificationRecipient Create(Guid messageId,string address)=>new(){Id=Guid.NewGuid(),MessageId=messageId,Address=address.Trim()}; }
public sealed class DeliveryAttempt { private DeliveryAttempt(){} public Guid Id{get;private set;} public Guid MessageId{get;private set;} public int AttemptNumber{get;private set;} public string Provider{get;private set;}=null!; public bool Succeeded{get;private set;} public string? Error{get;private set;} public DateTimeOffset AttemptedAtUtc{get;private set;} internal static DeliveryAttempt Success(Guid id,int n,string p,DateTimeOffset at)=>New(id,n,p,true,null,at); internal static DeliveryAttempt Failure(Guid id,int n,string p,string e,DateTimeOffset at)=>New(id,n,p,false,e,at); private static DeliveryAttempt New(Guid id,int n,string p,bool ok,string? e,DateTimeOffset at)=>new(){Id=Guid.NewGuid(),MessageId=id,AttemptNumber=n,Provider=p,Succeeded=ok,Error=e,AttemptedAtUtc=at}; }
