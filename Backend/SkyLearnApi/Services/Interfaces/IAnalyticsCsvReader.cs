namespace SkyLearnApi.Services.Interfaces;

public interface IAnalyticsCsvReader
{
    /// <summary>
    /// Reads a CSV file from the analytics output folder and returns each row as a dictionary.
    /// Returns an empty list if the file does not exist or is empty.
    /// </summary>
    Task<IReadOnlyList<Dictionary<string, string>>> ReadAsync(string fileName, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads a CSV file and maps each row using the provided mapper.
    /// </summary>
    Task<IReadOnlyList<T>> ReadAsync<T>(string fileName, Func<Dictionary<string, string>, T> mapper, CancellationToken cancellationToken = default);
}
