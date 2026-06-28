namespace SkyLearnApi.Dtos.Dashboard;

public class StudentAnalyticsDto
{
    public int StudentId { get; set; }
    public string DepartmentName { get; set; } = string.Empty;
    public string SquadronName { get; set; } = string.Empty;
    public string Segment { get; set; } = string.Empty;
    public int OverallRank { get; set; }
    public int DeptRank { get; set; }
    public int SquadronRank { get; set; }
    public double CompositeScore { get; set; }
    public double AvgQuizScore { get; set; }
    public double AvgGrade { get; set; }
    public double QuizPassRate { get; set; }
    public double CompletionRate { get; set; }
    public double RiskScore { get; set; }
    public double DropoutProbability { get; set; }
    public double AtRiskProbability { get; set; }
    public bool IsAnomaly { get; set; }
    public string AnomalyType { get; set; } = string.Empty;
    public List<ClassAverageDto> ClassAverages { get; set; } = new();
    public List<ClassAverageDto> DepartmentAverages { get; set; } = new();
    public List<ImprovementTrendDto> ImprovementTrend { get; set; } = new();
    public List<StrengthWeaknessDto> StrengthsWeaknesses { get; set; } = new();
    public List<StudentCourseProgressDto> CourseProgress { get; set; } = new();
    public List<LearningEfficiencyDto> LearningEfficiency { get; set; } = new();
    public List<StudentWorkloadDto> Workload { get; set; } = new();
}

public class ClassAverageDto
{
    public string Metric { get; set; } = string.Empty;
    public string? DepartmentName { get; set; }
    public double Average { get; set; }
}

public class ImprovementTrendDto
{
    public string Month { get; set; } = string.Empty;
    public double AvgScore { get; set; }
    public int Attempts { get; set; }
    public double PassRate { get; set; }
}

public class StrengthWeaknessDto
{
    public string QuestionType { get; set; } = string.Empty;
    public int Answered { get; set; }
    public int CorrectCount { get; set; }
    public double CorrectRate { get; set; }
}

public class StudentCourseProgressDto
{
    public int CourseId { get; set; }
    public string Title { get; set; } = string.Empty;
    public int ActivitiesTotal { get; set; }
    public int ActivitiesDone { get; set; }
    public double AvgProgress { get; set; }
    public double AvgTimeMinutes { get; set; }
    public double CompletionRate { get; set; }
}

public class LearningEfficiencyDto
{
    public double AvgEfficiency { get; set; }
    public double AvgScore { get; set; }
    public double AvgTimeMinutes { get; set; }
    public int TotalAttempts { get; set; }
    public string EfficiencyTier { get; set; } = string.Empty;
}

public class StudentWorkloadDto
{
    public double AvgSubmissionsPerWeek { get; set; }
    public int MaxSubmissionsInWeek { get; set; }
    public int ActiveWeeks { get; set; }
    public string WorkloadTier { get; set; } = string.Empty;
}
