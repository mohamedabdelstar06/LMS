namespace SkyLearnApi.Dtos.Dashboard;

public class StudentDashboardDto
{
    public double OverallGpa { get; set; }
    public int CoursesCompleted { get; set; }
    public int CreditHours { get; set; }
    public double CourseProgressPercent { get; set; }
    public int AssignmentsCompleted { get; set; }
    public int AssignmentsTotal { get; set; }
    public double AverageGrade { get; set; }
    public double AttendanceRate { get; set; }
    public CompletionStatusDto CompletionStatus { get; set; } = new();
    public List<ProgressPointDto> ProgressOverTime { get; set; } = new();
    public List<GradePerCourseDto> GradesPerCourse { get; set; } = new();
    public List<UpcomingDeadlineDto> UpcomingDeadlines { get; set; } = new();
    public List<AchievementDto> Achievements { get; set; } = new();
    public List<EnrolledCourseDto> EnrolledCourses { get; set; } = new();
}

public class CompletionStatusDto
{
    public int Completed { get; set; }
    public int InProgress { get; set; }
    public int NotStarted { get; set; }
}

public class ProgressPointDto
{
    public string Week { get; set; } = string.Empty;
    public double YourProgress { get; set; }
    public double ClassAverage { get; set; }
}

public class GradePerCourseDto
{
    public string CourseName { get; set; } = string.Empty;
    public double Grade { get; set; }
}

public class UpcomingDeadlineDto
{
    public string Title { get; set; } = string.Empty;
    public string DueDate { get; set; } = string.Empty;
    public string CourseTitle { get; set; } = string.Empty;
}

public class AchievementDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
}

public class EnrolledCourseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public double ProgressPercent { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
}
