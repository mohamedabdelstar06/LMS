namespace SkyLearnApi.Dtos.Dashboard
{
    public class RecentCourseDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public string DepartmentName { get; set; } = string.Empty;
        public string InstructorName { get; set; } = string.Empty;
        public int EnrolledStudentsCount { get; set; }
        public int CreditHours { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
