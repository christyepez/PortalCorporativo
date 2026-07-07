using Portal.Notification.Domain;using Xunit;
namespace Portal.Notification.UnitTests;
public sealed class NotificationDomainTests
{
 static readonly DateTimeOffset Now=new(2026,7,6,0,0,0,TimeSpan.Zero);static NotificationTemplate Template()=>NotificationTemplate.Create("default","test.code","Hello {{name}}","Body {{name}}","[\"name\"]",NotificationChannel.LogDev,Now);static NotificationMessage Message(DateTimeOffset? scheduled=null)=>NotificationMessage.Request("default",Template(),null,"Hello Chris","Body Chris",["dev@example.test"],"corr","key",null,Now,scheduled);
 [Fact]public void Template_starts_active_at_version_one(){var t=Template();Assert.True(t.IsActive);Assert.Equal(1,t.Version);}
 [Fact]public void Template_update_increments_version(){var t=Template();t.Update("New","Body","[]",NotificationChannel.EmailDev,Now);Assert.Equal(2,t.Version);}
 [Fact]public void Template_code_is_normalized(){Assert.Equal("test.code",Template().Code);}
 [Fact]public void Template_requires_json_array(){Assert.Throws<ArgumentException>(()=>NotificationTemplate.Create("default","x","s","b","{}",NotificationChannel.LogDev,Now));}
 [Fact]public void Message_starts_pending(){Assert.Equal(NotificationStatus.Pending,Message().Status);}
 [Fact]public void Message_requires_recipient(){Assert.Throws<ArgumentException>(()=>NotificationMessage.Request("default",Template(),null,"s","b",[],"c","k",null,Now,null));}
 [Fact]public void Message_uses_template_channel(){Assert.Equal(NotificationChannel.LogDev,Message().Channel);}
 [Fact]public void Processing_then_sent_is_terminal_success(){var m=Message();m.MarkProcessing(Now);m.MarkSent(Now,"LogDev");Assert.Equal(NotificationStatus.Sent,m.Status);Assert.Single(m.Attempts);}
 [Fact]public void Failure_schedules_retry(){var m=Message();m.MarkProcessing(Now);m.MarkFailed("boom","LogDev",Now,3,TimeSpan.FromSeconds(5));Assert.Equal(NotificationStatus.Failed,m.Status);Assert.Equal(Now.AddSeconds(5),m.NextAttemptAtUtc);}
 [Fact]public void Exhausted_failure_deadletters(){var m=Message();m.MarkProcessing(Now);m.MarkFailed("boom","LogDev",Now,1,TimeSpan.Zero);Assert.Equal(NotificationStatus.DeadLetter,m.Status);}
 [Fact]public void Deadletter_can_be_retried(){var m=Message();m.MarkProcessing(Now);m.MarkFailed("boom","LogDev",Now,1,TimeSpan.Zero);m.Retry(Now);Assert.Equal(NotificationStatus.Pending,m.Status);}
 [Fact]public void Pending_message_can_be_cancelled(){var m=Message();m.Cancel();Assert.Equal(NotificationStatus.Cancelled,m.Status);}
 [Fact]public void Future_message_cannot_process_early(){var m=Message(Now.AddHours(1));Assert.Throws<InvalidOperationException>(()=>m.MarkProcessing(Now));}
 [Fact]public void Idempotency_key_is_preserved(){Assert.Equal("key",Message().IdempotencyKey);}
}
