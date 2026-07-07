namespace Portal.BuildingBlocks;

public sealed record ApiError(string Code, string Message, IReadOnlyDictionary<string, string[]>? Details = null);

public sealed record ApiResponse<T>(T? Data, ApiError? Error, string CorrelationId)
{
    public bool IsSuccess => Error is null;
}

public sealed record PageRequest(int Page = 1, int PageSize = 20)
{
    public int SafePage => Math.Max(Page, 1);
    public int SafePageSize => Math.Clamp(PageSize, 1, 200);
}

public sealed record PagedResult<T>(IReadOnlyCollection<T> Items, int Page, int PageSize, long Total);

public readonly record struct Result<T>(T? Value, ApiError? Error)
{
    public bool IsSuccess => Error is null;

    public static Result<T> Success(T value) => new(value, null);
    public static Result<T> Failure(string code, string message) => new(default, new ApiError(code, message));
}
