namespace Portal.Content.Contracts;

public sealed record ContentDocumentDto(
    Guid Id,
    string ModuleCode,
    string FileName,
    string ContentType,
    long Length,
    string Sha256,
    bool IsActive,
    DateTimeOffset CreatedAt);

public sealed record CreateContentDocumentRequest(
    string ModuleCode,
    string FileName,
    string ContentType,
    byte[] Content);
