namespace SkyLearnApi.Dtos.Dashboard
{
    public class DashboardOverviewDto
    {
        public List<DepartmentOverviewDto> Departments { get; set; } = new();
        public List<RecentCourseDto> RecentCourses { get; set; } = new();
        public List<TopInstructorDto> TopInstructors { get; set; } = new();
        public int MonthlyStudyCount { get; set; }
        public int MonthlyExamCount { get; set; }
        public List<WeeklyHourDto> WeeklyHours { get; set; } = new();
    }
}
