namespace SkyLearnApi.Dtos.Dashboard
{
    public class WeeklyHourDto
    {
        public string Day { get; set; } = string.Empty;
        public int Study { get; set; }
        public int Exams { get; set; }
    }
}
