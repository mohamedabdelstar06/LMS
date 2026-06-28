using Microsoft.AspNetCore.Hosting;
using SkyLearnApi.Configuration;
using SkyLearnApi.Dtos.Dashboard;
using SkyLearnApi.Services.Implementations;
using SkyLearnApi.Services.Interfaces;

namespace SkyLearnApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IAnalyticsCsvReader _csvReader;
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<DashboardController> _logger;

        private int? UserId => int.TryParse(User.FindFirst("UserId")?.Value, out var id) ? id : null;

        public DashboardController(
            AppDbContext context,
            IAnalyticsCsvReader csvReader,
            IWebHostEnvironment environment,
            ILogger<DashboardController> logger)
        {
            _context = context;
            _csvReader = csvReader;
            _environment = environment;
            _logger = logger;
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
                    EnrolledStudentsCount = 0,
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
                MonthlyStudyCount = 28,
                MonthlyExamCount = 7,
                WeeklyHours = weeklyHours
            };

            return Ok(overview);
        }

        [HttpGet("admin/analytics")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> GetAdminAnalytics()
        {
            try
            {
                var analytics = new AdminAnalyticsDto
                {
                    PlatformHealth = await ReadPlatformHealthAsync(),
                    Kpis = await ReadKpisAsync(),
                    DepartmentComparison = await ReadDepartmentComparisonAsync(),
                    SquadronPerformance = await ReadSquadronPerformanceAsync(),
                    AtRiskStudents = await ReadTopRiskyStudentsAsync(),
                    AtRiskByDepartment = await ReadAtRiskByDepartmentAsync(),
                    SystemAlerts = await ReadSystemAlertsAsync(),
                    TopPopularCourses = await ReadTopPopularCoursesAsync(),
                    TopHardestCourses = await ReadTopHardestCoursesAsync(),
                    EnrollmentTrend = await ReadEnrollmentTrendAsync(),
                    WeeklyEngagement = await ReadWeeklyEngagementAsync(),
                    LearningFunnel = await ReadLearningFunnelAsync(),
                    GeneratedAt = DateTime.UtcNow
                };

                return Ok(analytics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load admin analytics");
                return StatusCode(500, new { message = "Failed to load analytics data." });
            }
        }

        [HttpGet("student")]
        [Authorize(Roles = Roles.Student)]
        public async Task<IActionResult> GetStudentDashboard()
        {
            if (!UserId.HasValue) return Unauthorized();

            var studentId = await ResolveStudentIdAsync(UserId.Value);
            if (!studentId.HasValue)
                return NotFound(new { message = "Student profile not found." });

            return await BuildStudentDashboardAsync(studentId.Value);
        }

        [HttpGet("student/analytics")]
        [Authorize(Roles = Roles.Student)]
        public async Task<IActionResult> GetStudentAnalyticsCurrent()
        {
            if (!UserId.HasValue) return Unauthorized();

            var studentId = await ResolveStudentIdAsync(UserId.Value);
            if (!studentId.HasValue)
                return NotFound(new { message = "Student profile not found." });

            return await BuildStudentAnalyticsAsync(studentId.Value);
        }

        [HttpGet("student/{studentId}/analytics")]
        [Authorize(Roles = Roles.All)]
        public async Task<IActionResult> GetStudentAnalytics(int studentId)
        {
            if (!UserId.HasValue) return Unauthorized();

            // Students can only view their own analytics
            if (User.IsInRole(Roles.Student))
            {
                var ownStudentId = await ResolveStudentIdAsync(UserId.Value);
                if (ownStudentId != studentId)
                    return Forbid();
            }

            return await BuildStudentAnalyticsAsync(studentId);
        }

        #region Admin Analytics Helpers

        private async Task<PlatformHealthDto> ReadPlatformHealthAsync()
        {
            var rows = await _csvReader.ReadAsync("admin/platform_health.csv");
            var metrics = rows.ToDictionary(
                r => r.GetString("Metric"),
                r => r.GetDouble("Value"),
                StringComparer.OrdinalIgnoreCase);

            return new PlatformHealthDto
            {
                PlatformHealthScore = metrics.GetValueOrDefault("PlatformHealthScore"),
                EnrolledStudentsPct = metrics.GetValueOrDefault("enrolled_students_pct"),
                ActiveCoursesPct = metrics.GetValueOrDefault("active_courses_pct"),
                OverallCompletionRate = metrics.GetValueOrDefault("overall_completion_rate"),
                OverallQuizPassRate = metrics.GetValueOrDefault("overall_quiz_pass_rate"),
                ActiveUsersPct = metrics.GetValueOrDefault("active_users_pct")
            };
        }

        private async Task<List<KpiDto>> ReadKpisAsync()
        {
            var rows = await _csvReader.ReadAsync("admin/kpi_summary.csv");
            return rows.Select(row => new KpiDto
            {
                Key = row.GetString("KPI"),
                Label = row.GetString("KPI"),
                Value = row.GetDouble("Value")
            }).ToList();
        }

        private async Task<List<DepartmentComparisonDto>> ReadDepartmentComparisonAsync()
        {
            return (await _csvReader.ReadAsync("admin/department_comparison.csv", row => new DepartmentComparisonDto
            {
                DepartmentName = row.GetString("DepartmentName"),
                Students = row.GetInt("Students"),
                AvgCreditLoad = row.GetDouble("AvgCreditLoad"),
                AvgQuizScore = row.GetDouble("AvgQuizScore"),
                AvgGrade = row.GetDouble("AvgGrade"),
                QuizPassRate = row.GetDouble("QuizPassRate"),
                CompletionRate = row.GetDouble("CompletionRate")
            })).ToList();
        }

        private async Task<List<SquadronPerformanceDto>> ReadSquadronPerformanceAsync()
        {
            return (await _csvReader.ReadAsync("admin/squadron_performance.csv", row => new SquadronPerformanceDto
            {
                SquadronId = row.GetInt("SquadronId"),
                SquadronName = row.GetString("SquadronName"),
                StudentCount = row.GetInt("StudentCount"),
                AvgQuizScore = row.GetDouble("AvgQuizScore"),
                QuizPassRate = row.GetDouble("QuizPassRate"),
                CompletionRate = row.GetDouble("CompletionRate"),
                OverallScore = row.GetDouble("OverallScore"),
                Rank = row.GetInt("Rank")
            })).ToList();
        }

        private async Task<List<AtRiskStudentDto>> ReadTopRiskyStudentsAsync()
        {
            // The dashboard module produces dash_top_risky_students.csv with combined risk scores.
            var rows = await _csvReader.ReadAsync("../ml/dash_top_risky_students.csv");
            if (rows.Count == 0)
            {
                rows = await _csvReader.ReadAsync("admin/at_risk_summary.csv");
            }

            return rows.Select(row => new AtRiskStudentDto
            {
                StudentId = row.GetInt("StudentId"),
                DepartmentName = row.GetString("DepartmentName"),
                ClusterLabel = row.GetString("ClusterLabel"),
                CombinedRiskScore = row.GetDouble("CombinedRiskScore"),
                DropoutProbability = row.GetDouble("Dropout_Probability"),
                AtRiskProbability = row.GetDouble("AtRisk_Probability"),
                CompletionRate = row.GetDouble("CompletionRate"),
                AvgScore = row.GetDouble("AvgScore"),
                FailureRatio = row.GetDouble("FailureRatio"),
                LateRate = row.GetDouble("LateRate"),
                IsAnomaly = row.GetBool("IsAnomaly"),
                AnomalyType = row.GetString("AnomalyType")
            }).Take(50).ToList();
        }

        private async Task<List<RiskByDepartmentDto>> ReadAtRiskByDepartmentAsync()
        {
            return (await _csvReader.ReadAsync("admin/at_risk_by_dept.csv", row => new RiskByDepartmentDto
            {
                DepartmentName = row.GetString("DepartmentName"),
                AtRiskCount = row.GetInt("AtRiskCount"),
                Total = row.GetInt("Total"),
                AtRiskPct = row.GetDouble("AtRiskPct")
            })).ToList();
        }

        private async Task<List<AlertDto>> ReadSystemAlertsAsync()
        {
            return (await _csvReader.ReadAsync("admin/system_alerts.csv", row => new AlertDto
            {
                Alert = row.GetString("Alert"),
                Count = row.GetInt("Count"),
                Severity = row.GetString("Severity")
            })).ToList();
        }

        private async Task<List<CourseRankingDto>> ReadTopPopularCoursesAsync()
        {
            return (await _csvReader.ReadAsync("admin/top_popular_courses.csv", row => new CourseRankingDto
            {
                CourseId = row.GetInt("CourseId"),
                Title = row.GetString("Title"),
                DepartmentName = row.GetString("DepartmentName"),
                EnrolledStudentsCount = row.GetInt("ActualEnrolledCount"),
                CompletionRate = row.GetDouble("CompletionRate"),
                AvgQuizScore = row.GetDouble("AvgQuizScore"),
                QuizPassRate = 0,
                TotalAttempts = 0
            })).Take(10).ToList();
        }

        private async Task<List<CourseRankingDto>> ReadTopHardestCoursesAsync()
        {
            return (await _csvReader.ReadAsync("admin/top_hardest_courses.csv", row => new CourseRankingDto
            {
                CourseId = row.GetInt("CourseId"),
                Title = row.GetString("Title"),
                DepartmentName = row.GetString("DepartmentName"),
                EnrolledStudentsCount = 0,
                CompletionRate = 0,
                AvgQuizScore = row.GetDouble("AvgQuizScore"),
                QuizPassRate = row.GetDouble("QuizPassRate"),
                TotalAttempts = row.GetInt("TotalAttempts")
            })).Take(10).ToList();
        }

        private async Task<List<EnrollmentTrendDto>> ReadEnrollmentTrendAsync()
        {
            return (await _csvReader.ReadAsync("admin/enrollment_trend.csv", row => new EnrollmentTrendDto
            {
                Year = row.GetInt("Year"),
                Month = row.GetInt("Month"),
                Enrollments = row.GetInt("Enrollments")
            })).ToList();
        }

        private async Task<List<WeeklyEngagementDto>> ReadWeeklyEngagementAsync()
        {
            return (await _csvReader.ReadAsync("admin/weekly_engagement_trend.csv", row => new WeeklyEngagementDto
            {
                Week = row.GetString("Week"),
                TotalActions = row.GetInt("TotalActions"),
                UniqueUsers = row.GetInt("UniqueUsers")
            })).ToList();
        }

        private async Task<List<LearningFunnelStageDto>> ReadLearningFunnelAsync()
        {
            return (await _csvReader.ReadAsync("admin/learning_funnel.csv", row => new LearningFunnelStageDto
            {
                Stage = row.GetString("Stage"),
                Count = row.GetInt("Count"),
                DropFromPrev = row.GetInt("DropFromPrev"),
                RetentionPct = row.GetDouble("RetentionPct")
            })).ToList();
        }

        #endregion

        #region Student Dashboard Helpers

        private async Task<IActionResult> BuildStudentDashboardAsync(int studentId)
        {
            try
            {
                // Load per-student records
                var fullProfileRows = await _csvReader.ReadAsync("../ml/dash_student_full_profile.csv");
                var profile = fullProfileRows.FirstOrDefault(r => r.GetInt("StudentId") == studentId)
                    ?? new Dictionary<string, string>();

                var courseProgressRows = await _csvReader.ReadAsync("student/course_progress.csv");
                var myCourseProgress = courseProgressRows
                    .Where(r => r.GetInt("StudentId") == studentId)
                    .ToList();

                var submissions = await _csvReader.ReadAsync("../cleaned/submissions_clean.csv");
                var mySubmissions = submissions.Where(r => r.GetInt("StudentId") == studentId).ToList();

                var attempts = await _csvReader.ReadAsync("../cleaned/attempts_clean.csv");
                var myAttempts = attempts.Where(r => r.GetInt("StudentId") == studentId).ToList();

                var students = await _csvReader.ReadAsync("../cleaned/students_clean.csv");
                var studentRow = students.FirstOrDefault(r => r.GetInt("Id") == studentId);

                var dashboard = new StudentDashboardDto
                {
                    OverallGpa = CalculateGpa(profile.GetDouble("AvgGrade")),
                    CoursesCompleted = myCourseProgress.Count(r => r.GetDouble("CompletionRate") >= 0.99),
                    CreditHours = studentRow?.GetInt("TotalCreditLoad") ?? 0,
                    CourseProgressPercent = myCourseProgress.Any()
                        ? myCourseProgress.Average(r => r.GetDouble("CompletionRate") * 100)
                        : 0,
                    AssignmentsCompleted = mySubmissions.Count(r => r.GetString("Status").Equals("Graded", StringComparison.OrdinalIgnoreCase)),
                    AssignmentsTotal = mySubmissions.Count,
                    AverageGrade = profile.GetDouble("AvgScore"),
                    AttendanceRate = Math.Min(100, myAttempts.Count > 0 ? 85 + (myAttempts.Count * 0.5) : 75),
                    CompletionStatus = new CompletionStatusDto
                    {
                        Completed = myCourseProgress.Count(r => r.GetDouble("CompletionRate") >= 0.99),
                        InProgress = myCourseProgress.Count(r => r.GetDouble("CompletionRate") > 0 && r.GetDouble("CompletionRate") < 0.99),
                        NotStarted = myCourseProgress.Count(r => r.GetDouble("CompletionRate") <= 0)
                    },
                    ProgressOverTime = await BuildProgressOverTimeAsync(studentId),
                    GradesPerCourse = myCourseProgress.Select(r => new GradePerCourseDto
                    {
                        CourseName = r.GetString("Title"),
                        Grade = r.GetDouble("AvgProgress")
                    }).ToList(),
                    UpcomingDeadlines = new List<UpcomingDeadlineDto>(),
                    Achievements = DeriveAchievements(profile, myCourseProgress),
                    EnrolledCourses = myCourseProgress.Select(r => new EnrolledCourseDto
                    {
                        Id = r.GetInt("CourseId"),
                        Title = r.GetString("Title"),
                        ProgressPercent = r.GetDouble("CompletionRate") * 100,
                        ImageUrl = ""
                    }).ToList()
                };

                return Ok(dashboard);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load student dashboard for StudentId {StudentId}", studentId);
                return StatusCode(500, new { message = "Failed to load student dashboard." });
            }
        }

        private async Task<IActionResult> BuildStudentAnalyticsAsync(int studentId)
        {
            try
            {
                var fullProfileRows = await _csvReader.ReadAsync("../ml/dash_student_full_profile.csv");
                var profile = fullProfileRows.FirstOrDefault(r => r.GetInt("StudentId") == studentId)
                    ?? new Dictionary<string, string>();

                var rankings = await _csvReader.ReadAsync("student/rankings.csv");
                var ranking = rankings.FirstOrDefault(r => r.GetInt("StudentId") == studentId);

                var segments = await _csvReader.ReadAsync("student/student_segments.csv");
                var segment = segments.FirstOrDefault(r => r.GetInt("StudentId") == studentId);

                var courseProgress = await _csvReader.ReadAsync("student/course_progress.csv");
                var myCourseProgress = courseProgress.Where(r => r.GetInt("StudentId") == studentId).ToList();

                var strengths = await _csvReader.ReadAsync("student/strengths_weaknesses.csv");
                var myStrengths = strengths.Where(r => r.GetInt("StudentId") == studentId).ToList();

                var improvementTrend = await _csvReader.ReadAsync("student/improvement_trend.csv");
                var myTrend = improvementTrend.Where(r => r.GetInt("StudentId") == studentId).ToList();

                var efficiency = await _csvReader.ReadAsync("student/learning_efficiency.csv");
                var myEfficiency = efficiency.FirstOrDefault(r => r.GetInt("StudentId") == studentId);

                var workload = await _csvReader.ReadAsync("student/student_workload.csv");
                var myWorkload = workload.FirstOrDefault(r => r.GetInt("StudentId") == studentId);

                var classAvg = await _csvReader.ReadAsync("student/class_avg.csv");
                var deptAvg = await _csvReader.ReadAsync("student/dept_avg.csv");

                var squadrons = await _csvReader.ReadAsync("../cleaned/squadrons_clean.csv");
                var students = await _csvReader.ReadAsync("../cleaned/students_clean.csv");
                var studentRow = students.FirstOrDefault(r => r.GetInt("Id") == studentId);
                var squadronName = "";
                if (studentRow != null)
                {
                    var squadronId = studentRow.GetInt("SquadronId");
                    squadronName = squadrons.FirstOrDefault(s => s.GetInt("Id") == squadronId)?.GetString("Name") ?? "";
                }

                var analytics = new StudentAnalyticsDto
                {
                    StudentId = studentId,
                    DepartmentName = profile.GetString("DepartmentName"),
                    SquadronName = squadronName,
                    Segment = segment?.GetString("Segment") ?? "Unknown",
                    OverallRank = ranking?.GetInt("OverallRank") ?? 0,
                    DeptRank = ranking?.GetInt("DeptRank") ?? 0,
                    SquadronRank = ranking?.GetInt("SquadronRank") ?? 0,
                    CompositeScore = ranking?.GetDouble("CompositeScore") ?? 0,
                    AvgQuizScore = ranking?.GetDouble("AvgQuizScore") ?? profile.GetDouble("AvgScore"),
                    AvgGrade = ranking?.GetDouble("AvgGrade") ?? profile.GetDouble("AvgGrade"),
                    QuizPassRate = ranking?.GetDouble("QuizPassRate") ?? profile.GetDouble("QuizPassRate"),
                    CompletionRate = profile.GetDouble("CompletionRate"),
                    RiskScore = profile.GetDouble("CombinedRiskScore"),
                    DropoutProbability = profile.GetDouble("Dropout_Probability"),
                    AtRiskProbability = profile.GetDouble("AtRisk_Probability"),
                    IsAnomaly = profile.GetBool("IsAnomaly"),
                    AnomalyType = profile.GetString("AnomalyType"),
                    ClassAverages = classAvg.Select(r => new ClassAverageDto
                    {
                        Metric = r.GetString("Metric"),
                        Average = r.GetDouble("ClassAvg")
                    }).ToList(),
                    DepartmentAverages = deptAvg
                        .SelectMany(r => new[]
                        {
                            new ClassAverageDto { Metric = "AvgQuizScore", DepartmentName = r.GetString("DepartmentName"), Average = r.GetDouble("AvgQuizScore") },
                            new ClassAverageDto { Metric = "AvgGrade", DepartmentName = r.GetString("DepartmentName"), Average = r.GetDouble("AvgGrade") },
                            new ClassAverageDto { Metric = "QuizPassRate", DepartmentName = r.GetString("DepartmentName"), Average = r.GetDouble("QuizPassRate") },
                            new ClassAverageDto { Metric = "CompletionRate", DepartmentName = r.GetString("DepartmentName"), Average = r.GetDouble("CompletionRate") }
                        })
                        .ToList(),
                    ImprovementTrend = myTrend.Select(r => new ImprovementTrendDto
                    {
                        Month = r.GetString("Month"),
                        AvgScore = r.GetDouble("AvgScore"),
                        Attempts = r.GetInt("Attempts"),
                        PassRate = r.GetDouble("PassRate")
                    }).ToList(),
                    StrengthsWeaknesses = myStrengths.Select(r => new StrengthWeaknessDto
                    {
                        QuestionType = r.GetString("QuestionType"),
                        Answered = r.GetInt("Answered"),
                        CorrectCount = r.GetInt("CorrectCount"),
                        CorrectRate = r.GetDouble("CorrectRate")
                    }).ToList(),
                    CourseProgress = myCourseProgress.Select(r => new StudentCourseProgressDto
                    {
                        CourseId = r.GetInt("CourseId"),
                        Title = r.GetString("Title"),
                        ActivitiesTotal = r.GetInt("ActivitiesTotal"),
                        ActivitiesDone = r.GetInt("ActivitiesDone"),
                        AvgProgress = r.GetDouble("AvgProgress"),
                        AvgTimeMinutes = r.GetDouble("AvgTimeMinutes"),
                        CompletionRate = r.GetDouble("CompletionRate")
                    }).ToList(),
                    LearningEfficiency = myEfficiency != null ? new List<LearningEfficiencyDto>
                    {
                        new()
                        {
                            AvgEfficiency = myEfficiency.GetDouble("AvgEfficiency"),
                            AvgScore = myEfficiency.GetDouble("AvgScore"),
                            AvgTimeMinutes = myEfficiency.GetDouble("AvgTimeMinutes"),
                            TotalAttempts = myEfficiency.GetInt("TotalAttempts"),
                            EfficiencyTier = myEfficiency.GetString("EfficiencyTier")
                        }
                    } : new List<LearningEfficiencyDto>(),
                    Workload = myWorkload != null ? new List<StudentWorkloadDto>
                    {
                        new()
                        {
                            AvgSubmissionsPerWeek = myWorkload.GetDouble("AvgSubmissionsPerWeek"),
                            MaxSubmissionsInWeek = myWorkload.GetInt("MaxSubmissionsInWeek"),
                            ActiveWeeks = myWorkload.GetInt("ActiveWeeks"),
                            WorkloadTier = myWorkload.GetString("WorkloadTier")
                        }
                    } : new List<StudentWorkloadDto>()
                };

                return Ok(analytics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load student analytics for StudentId {StudentId}", studentId);
                return StatusCode(500, new { message = "Failed to load student analytics." });
            }
        }

        private async Task<int?> ResolveStudentIdAsync(int userId)
        {
            var students = await _csvReader.ReadAsync("../cleaned/students_clean.csv");
            var student = students.FirstOrDefault(r => r.GetInt("UserId") == userId);
            if (student != null) return student.GetInt("Id");

            // Fallback to database if CSV is missing/stale
            var profile = await _context.StudentProfiles
                .AsNoTracking()
                .FirstOrDefaultAsync(sp => sp.UserId == userId.ToString());
            return profile?.Id;
        }

        private async Task<List<ProgressPointDto>> BuildProgressOverTimeAsync(int studentId)
        {
            var trend = await _csvReader.ReadAsync("student/improvement_trend.csv");
            var myTrend = trend
                .Where(r => r.GetInt("StudentId") == studentId)
                .OrderBy(r => r.GetString("Month"))
                .Take(6)
                .ToList();

            if (myTrend.Count == 0)
            {
                return new List<ProgressPointDto>
                {
                    new() { Week = "W1", YourProgress = 0, ClassAverage = 0 },
                    new() { Week = "W2", YourProgress = 0, ClassAverage = 0 },
                    new() { Week = "W3", YourProgress = 0, ClassAverage = 0 },
                    new() { Week = "W4", YourProgress = 0, ClassAverage = 0 }
                };
            }

            var classAvg = await _csvReader.ReadAsync("student/class_avg.csv");
            var avgQuiz = classAvg.FirstOrDefault(r => r.GetString("Metric") == "AvgQuizScore")?.GetDouble("ClassAvg") ?? 0;

            return myTrend.Select(r => new ProgressPointDto
            {
                Week = r.GetString("Month"),
                YourProgress = r.GetDouble("AvgScore"),
                ClassAverage = avgQuiz
            }).ToList();
        }

        private static List<AchievementDto> DeriveAchievements(Dictionary<string, string> profile, List<Dictionary<string, string>> courseProgress)
        {
            var achievements = new List<AchievementDto>();

            var completionRate = profile.GetDouble("CompletionRate");
            if (completionRate >= 0.9)
                achievements.Add(new AchievementDto { Title = "Completionist", Description = "Completed 90% of course content", Icon = "🏁" });

            if (profile.GetDouble("AvgScore") >= 90)
                achievements.Add(new AchievementDto { Title = "Top Scorer", Description = "Averaged 90%+ on quizzes", Icon = "🌟" });

            if (courseProgress.Any(r => r.GetDouble("CompletionRate") >= 0.99))
                achievements.Add(new AchievementDto { Title = "Course Finisher", Description = "Completed at least one course", Icon = "🎓" });

            if (profile.GetBool("IsAnomaly") == false && completionRate > 0.5)
                achievements.Add(new AchievementDto { Title = "On Track", Description = "Maintaining steady progress", Icon = "🚀" });

            return achievements;
        }

        private static double CalculateGpa(double avgGrade)
        {
            // Map 0-100 average grade to 0-4 GPA
            var gpa = avgGrade / 100.0 * 4.0;
            return Math.Round(gpa, 2);
        }

        #endregion
    }
}
