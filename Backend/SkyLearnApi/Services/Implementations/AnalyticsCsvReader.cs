using System.Globalization;
using Microsoft.Extensions.Options;
using SkyLearnApi.Configuration;

namespace SkyLearnApi.Services.Implementations;

public class AnalyticsCsvReader : IAnalyticsCsvReader
{
    private readonly string _basePath;
    private readonly ILogger<AnalyticsCsvReader> _logger;

    public AnalyticsCsvReader(IOptions<AnalyticsOptions> options, IWebHostEnvironment environment, ILogger<AnalyticsCsvReader> logger)
    {
        _logger = logger;
        var configuredPath = options.Value.OutputPath;

        _basePath = Path.IsPathRooted(configuredPath)
            ? configuredPath
            : Path.GetFullPath(Path.Combine(environment.ContentRootPath, configuredPath));
    }

    public async Task<IReadOnlyList<Dictionary<string, string>>> ReadAsync(string fileName, CancellationToken cancellationToken = default)
    {
        var path = Path.Combine(_basePath, fileName);
        if (!File.Exists(path))
        {
            _logger.LogWarning("Analytics file not found: {Path}", path);
            return Array.Empty<Dictionary<string, string>>();
        }

        try
        {
            await using var stream = File.Open(path, FileMode.Open, FileAccess.Read, FileShare.Read);
            using var reader = new StreamReader(stream, System.Text.Encoding.UTF8);
            var headers = ParseLine(await reader.ReadLineAsync(cancellationToken) ?? "");
            if (headers.Count == 0)
            {
                return Array.Empty<Dictionary<string, string>>();
            }

            var rows = new List<Dictionary<string, string>>();
            string? line;
            while ((line = await reader.ReadLineAsync(cancellationToken)) != null)
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                var values = ParseLine(line);
                var row = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                for (int i = 0; i < headers.Count && i < values.Count; i++)
                {
                    row[headers[i]] = values[i];
                }
                rows.Add(row);
            }

            return rows;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to read analytics file {FileName}", fileName);
            return Array.Empty<Dictionary<string, string>>();
        }
    }

    public async Task<IReadOnlyList<T>> ReadAsync<T>(string fileName, Func<Dictionary<string, string>, T> mapper, CancellationToken cancellationToken = default)
    {
        var rows = await ReadAsync(fileName, cancellationToken);
        return rows.Select(mapper).Where(x => x is not null).Cast<T>().ToList();
    }

    private static List<string> ParseLine(string line)
    {
        var result = new List<string>();
        var current = new System.Text.StringBuilder();
        bool inQuotes = false;

        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];
            if (c == '"')
            {
                if (inQuotes && i + 1 < line.Length && line[i + 1] == '"')
                {
                    current.Append('"');
                    i++;
                }
                else
                {
                    inQuotes = !inQuotes;
                }
            }
            else if (c == ',' && !inQuotes)
            {
                result.Add(current.ToString().Trim());
                current.Clear();
            }
            else
            {
                current.Append(c);
            }
        }

        result.Add(current.ToString().Trim());
        return result;
    }
}

public static class CsvRowExtensions
{
    public static string GetString(this Dictionary<string, string> row, string key, string defaultValue = "")
    {
        return row.TryGetValue(key, out var value) ? value : defaultValue;
    }

    public static int GetInt(this Dictionary<string, string> row, string key, int defaultValue = 0)
    {
        if (row.TryGetValue(key, out var value) && int.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out var result))
        {
            return result;
        }
        return defaultValue;
    }

    public static double GetDouble(this Dictionary<string, string> row, string key, double defaultValue = 0)
    {
        if (row.TryGetValue(key, out var value) && double.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out var result))
        {
            return result;
        }
        return defaultValue;
    }

    public static bool GetBool(this Dictionary<string, string> row, string key, bool defaultValue = false)
    {
        if (row.TryGetValue(key, out var value))
        {
            if (int.TryParse(value, out var intValue)) return intValue != 0;
            return bool.TryParse(value, out var boolValue) ? boolValue : defaultValue;
        }
        return defaultValue;
    }
}
