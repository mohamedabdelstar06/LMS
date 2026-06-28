namespace SkyLearnApi.Configuration;

public class AnalyticsOptions
{
    public const string SectionName = "Analytics";

    /// <summary>
    /// Path to the DataScience analytics output folder.
    /// May be absolute or relative to the application content root.
    /// Default assumes repository layout: ../../DataScience/pipeline_output/analysis
    /// </summary>
    public string OutputPath { get; set; } = "../../DataScience/pipeline_output/analysis";
}
