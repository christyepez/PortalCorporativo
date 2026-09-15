namespace Portal.Content.Domain;

public sealed class ContentDocument
{
    public Guid Id { get; private set; }
    public string ModuleCode { get; private set; }
    public string FileName { get; private set; }
    public string ContentType { get; private set; }
    public long Length { get; private set; }
    public string Sha256 { get; private set; }
    public bool IsActive { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }

    private ContentDocument(Guid id, string moduleCode, string fileName, string contentType, long length, string sha256, bool isActive, DateTimeOffset createdAt)
    {
        Id = id;
        ModuleCode = moduleCode;
        FileName = fileName;
        ContentType = contentType;
        Length = length;
        Sha256 = sha256;
        IsActive = isActive;
        CreatedAt = createdAt;
    }

    public static ContentDocument Create(string moduleCode, string fileName, string contentType, long length, string sha256, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(moduleCode) || moduleCode.Trim().Length > 80) throw new ArgumentException("ModuleCode is required and must be <= 80 characters.", nameof(moduleCode));
        if (string.IsNullOrWhiteSpace(fileName) || fileName.Trim().Length > 255) throw new ArgumentException("FileName is required and must be <= 255 characters.", nameof(fileName));
        if (string.IsNullOrWhiteSpace(contentType) || contentType.Trim().Length > 120) throw new ArgumentException("ContentType is required and must be <= 120 characters.", nameof(contentType));
        if (length < 0) throw new ArgumentOutOfRangeException(nameof(length));
        if (string.IsNullOrWhiteSpace(sha256) || sha256.Length != 64) throw new ArgumentException("Sha256 must contain 64 hexadecimal characters.", nameof(sha256));
        return new ContentDocument(Guid.NewGuid(), moduleCode.Trim(), fileName.Trim(), contentType.Trim(), length, sha256.ToLowerInvariant(), true, now);
    }

    public void Deactivate() => IsActive = false;
}
