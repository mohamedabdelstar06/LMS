class ApiResources {
  static const apiUrl = 'https://skylearn.runasp.net/api/';
  static const loginEndPoint = 'Auth/login';
  static const logoutEndPoint = 'Auth/logout';
  static const createUserEndPoint = 'Users';
  static const getUsersEndPoint = 'Users';
  static const getProfileEndpoint = 'Auth/me';
  static const verifyUserEmailEndPoint = 'Auth/verify-account';
  static const activateUserEmailEndPoint = 'Auth/activate-account';
  static const createDepartmentEndPoint = 'Department/';
  static const getDepartmentEndPoint = 'Department';
  static const createYearEndPoint = 'years';
  static const getYearEndPoint = 'years';
  static const createCourseEndPoint = 'Course';
  static const updateCourseEndPoint = 'Course';
  static const getCourseEndPoint = 'Course';
  static const courseGradesEndPoint = 'courses/{courseId}/grades';
  static const squadronEndPoint = 'Squadron';
  static const importStudentsEndPoint = 'admin/import/students';
  static const getCourseStudentEndPoint = 'Enrollment/my-courses';
  static const addEnrollmentEndPoint = 'Enrollment';
  static const adminDashboardOverviewEndPoint = 'Dashboard/admin/overview';
  static const adminDashboardEndPoint = 'Dashboard/admin';
  static const adminDashboardAnalyticsEndPoint = 'Dashboard/admin/analytics';
  static const studentDashboardEndPoint = 'Dashboard/student';
  static const studentDashboardAnalyticsEndPoint = 'Dashboard/student/analytics';
  static const studentAnalyticsEndPoint = 'Dashboard/student/{studentId}/analytics';
}
