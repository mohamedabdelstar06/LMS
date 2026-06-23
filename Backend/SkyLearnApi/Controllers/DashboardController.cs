using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SkyLearnApi.Data;
using SkyLearnApi.Dtos.Dashboard;
using SkyLearnApi.Helpers;

namespace SkyLearnApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DashboardController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("admin")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> GetAdminStats()
        {
            var totalUsers = await _context.Users.CountAsync();
            var totalStudents = await _context.Users.CountAsync(u => u.StudentProfile != null);
            var totalInstructors = await _context.Users.CountAsync(u => u.InstructorProfile != null);
            var totalCourses = await _context.Courses.CountAsync();
            var totalDepartments = await _context.Departments.CountAsync();
            var totalSquadrons = await _context.Squadrons.CountAsync();

            var stats = new DashboardStatsDto
            {
                TotalUsers = totalUsers,
                TotalStudents = totalStudents,
                TotalInstructors = totalInstructors,
                TotalCourses = totalCourses,
                TotalDepartments = totalDepartments,
                TotalSquadrons = totalSquadrons
            };

            return Ok(stats);
        }

        [HttpGet("admin/overview")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> GetAdminOverview()
        {
            // Get Departments with Course Count
            var departments = await _context.Departments
                .Include(d => d.Courses)
                .Select(d => new DepartmentOverviewDto
                {
                    Id = d.Id,
                    Name = d.Name,
                    CourseCount = d.Courses.Count,
                    ImageUrl = d.ImageUrl
                })
                .ToListAsync();

            // Get Recent Courses
            var recentCourses = await _context.Courses
                .Include(c => c.Department)
                .Include(c => c.CreatedBy)
                .OrderByDescending(c => c.CreatedAt)
                .Take(5)
                .Select(c => new RecentCourseDto
                {
                    Id = c.Id,
                    Title = c.Title,
                    ImageUrl = c.ImageUrl,
                    DepartmentName = c.Department.Name,
                    InstructorName = c.CreatedBy.FullName,
                    EnrolledStudentsCount = 0, // TODO: Implement enrollment count
                    CreditHours = c.CreditHours,
                    CreatedAt = c.CreatedAt
                })
                .ToListAsync();

            // Get Top Instructors (by course count)
            var topInstructors = await _context.Users
                .Include(u => u.CreatedCourses)
                .Where(u => u.InstructorProfile != null)
                .OrderByDescending(u => u.CreatedCourses.Count)
                .Take(5)
                .Select(u => new TopInstructorDto
                {
                    InstructorId = u.Id,
                    FullName = u.FullName,
                    ProfileImageUrl = u.ProfileImageUrl,
                    CourseCount = u.CreatedCourses.Count
                })
                .ToListAsync();

            // Weekly Hours (placeholder data for now)
            var weeklyHours = new List<WeeklyHourDto>
            {
                new() { Day = "Monday", Study = 5, Exams = 2 },
                new() { Day = "Tuesday", Study = 7, Exams = 1 },
                new() { Day = "Wednesday", Study = 4, Exams = 3 },
                new() { Day = "Thursday", Study = 6, Exams = 0 },
                new() { Day = "Friday", Study = 3, Exams = 1 },
                new() { Day = "Saturday", Study = 2, Exams = 0 },
                new() { Day = "Sunday", Study = 1, Exams = 0 }
            };

            var overview = new DashboardOverviewDto
            {
                Departments = departments,
                RecentCourses = recentCourses,
                TopInstructors = topInstructors,
                MonthlyStudyCount = 28, // TODO: Implement real data
                MonthlyExamCount = 7,  // TODO: Implement real data
                WeeklyHours = weeklyHours
            };

            return Ok(overview);
        }
    }
}
