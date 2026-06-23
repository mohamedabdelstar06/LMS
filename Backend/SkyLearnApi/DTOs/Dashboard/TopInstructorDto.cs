namespace SkyLearnApi.Dtos.Dashboard
{
    public class TopInstructorDto
    {
        public int InstructorId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }
        public int CourseCount { get; set; }
    }
}
