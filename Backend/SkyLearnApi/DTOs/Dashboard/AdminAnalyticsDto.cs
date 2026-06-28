namespace SkyLearnApi.Dtos.Dashboard;

public class AdminAnalyticsDto
{
    public PlatformHealthDto PlatformHealth { get; set; } = new();
    public List<KpiDto> Kpis { get; set; } = new();
    public List<DepartmentComparisonDto> DepartmentComparison { get; set; } = new();
    public List<SquadronPerformanceDto> SquadronPerformance { get; set; } = new();
    public List<AtRiskStudentDto> AtRiskStudents { get; set; } = new();
    public List<RiskByDepartmentDto> AtRiskByDepartment { get; set; } = new();
    public List<AlertDto> SystemAlerts { get; set; } = new();
    public List<CourseRankingDto> TopPopularCourses { get; set; } = new();
    public List<CourseRankingDto> TopHardestCourses { get; set; } = new();
    public List<EnrollmentTrendDto> EnrollmentTrend { get; set; } = new();
    public List<WeeklyEngagementDto> WeeklyEngagement { get; set; } = new();
    public List<LearningFunnelStageDto> LearningFunnel { get; set; } = new();
    public DateTime? GeneratedAt { get; set; }
}

public class PlatformHealthDto
{
    public double PlatformHealthScore { get; set; }
    public double EnrolledStudentsPct { get; set; }
    public double ActiveCoursesPct { get; set; }
    public double OverallCompletionRate { get; set; }
    public double OverallQuizPassRate { get; set; }
    public double ActiveUsersPct { get; set; }
}

public class KpiDto
{
    public string Key { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public double Value { get; set; }
}

public class DepartmentComparisonDto
{
    public string DepartmentName { get; set; } = string.Empty;
    public int Students { get; set; }
    public double AvgCreditLoad { get; set; }
    public double AvgQuizScore { get; set; }
    public double AvgGrade { get; set; }
    public double QuizPassRate { get; set; }
    public double CompletionRate { get; set; }
}

public class SquadronPerformanceDto
{
    public int SquadronId { get; set; }
    public string SquadronName { get; set; } = string.Empty;
    public int StudentCount { get; set; }
    public double AvgQuizScore { get; set; }
    public double QuizPassRate { get; set; }
    public double CompletionRate { get; set; }
    public double OverallScore { get; set; }
    public int Rank { get; set; }
}

public class AtRiskStudentDto
{
    public int StudentId { get; set; }
    public string DepartmentName { get; set; } = string.Empty;
    public string ClusterLabel { get; set; } = string.Empty;
    public double CombinedRiskScore { get; set; }
    public double DropoutProbability { get; set; }
    public double AtRiskProbability { get; set; }
    public double CompletionRate { get; set; }
    public double AvgScore { get; set; }
    public double FailureRatio { get; set; }
    public double LateRate { get; set; }
    public bool IsAnomaly { get; set; }
    public string AnomalyType { get; set; } = string.Empty;
}

public class RiskByDepartmentDto
{
    public string DepartmentName { get; set; } = string.Empty;
    public int AtRiskCount { get; set; }
    public int Total { get; set; }
    public double AtRiskPct { get; set; }
}

public class AlertDto
{
    public string Alert { get; set; } = string.Empty;
    public int Count { get; set; }
    public string Severity { get; set; } = string.Empty;
}

public class CourseRankingDto
{
    public int CourseId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string DepartmentName { get; set; } = string.Empty;
    public int EnrolledStudentsCount { get; set; }
    public double CompletionRate { get; set; }
    public double AvgQuizScore { get; set; }
    public double QuizPassRate { get; set; }
    public int TotalAttempts { get; set; }
}

public class EnrollmentTrendDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public int Enrollments { get; set; }
}

public class WeeklyEngagementDto
{
    public string Week { get; set; } = string.Empty;
    public int TotalActions { get; set; }
    public int UniqueUsers { get; set; }
}

public class LearningFunnelStageDto
{
    public string Stage { get; set; } = string.Empty;
    public int Count { get; set; }
    public int DropFromPrev { get; set; }
    public double RetentionPct { get; set; }
}
