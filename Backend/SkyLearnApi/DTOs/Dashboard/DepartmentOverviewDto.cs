namespace SkyLearnApi.Dtos.Dashboard
{
    public class DepartmentOverviewDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int CourseCount { get; set; }
        public string? ImageUrl { get; set; }
    }
}
