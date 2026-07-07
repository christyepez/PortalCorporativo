using System.Text.Json;
using System.Text.Json.Nodes;

namespace Portal.Audit.Domain;

public static class AuditRedactor
{
    private static readonly HashSet<string> SensitiveKeys = new(StringComparer.OrdinalIgnoreCase)
    { "password", "passwordHash", "token", "accessToken", "refreshToken", "authorization", "secret", "apiKey", "ssn", "nationalId", "email", "phone" };

    public static string? RedactJson(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return null;
        JsonNode? node;
        try { node = JsonNode.Parse(json); }
        catch (JsonException) { throw new ArgumentException("Audit JSON fields must contain valid JSON."); }
        Redact(node);
        return node?.ToJsonString(new JsonSerializerOptions { WriteIndented = false });
    }

    private static void Redact(JsonNode? node)
    {
        if (node is JsonObject obj)
        {
            foreach (var property in obj.ToArray())
            {
                if (SensitiveKeys.Contains(property.Key)) obj[property.Key] = "[REDACTED]";
                else Redact(property.Value);
            }
        }
        else if (node is JsonArray array)
            foreach (var item in array) Redact(item);
    }
}
