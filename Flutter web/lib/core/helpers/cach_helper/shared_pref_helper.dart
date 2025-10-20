import 'package:lms/features/screens/login/user_model/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("tokenKey");
  }

  static Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id");
  }

  static Future<String?> getAcademicLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("academicLevel");
  }

  static Future<String?> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("city");
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("firstName");
  }

  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("lastName");
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("gender");
  }

  static Future<String?> getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("profileImageUrl");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<String?> getMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("message");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("tokenKey");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("tokenKey");
  }

  static Future<void> saveLoginData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tokenKey", user.token!);
    await prefs.setInt("id", user.user!.id!);
    await prefs.setString("academicLevel", user.user!.academicLevel!);
    await prefs.setString("city", user.user!.city!);
    await prefs.setString("email", user.user!.email!);
    await prefs.setString("firstName", user.user!.firstName!);
    await prefs.setString("lastName ", user.user!.lastName!);
    await prefs.setString("gender", user.user!.gender!);
    // await prefs.setString("profileImageUrl", user.user!.profileImageUrl);
    await prefs.setString("role", user.user!.role!);
    await prefs.setString("message", user.message!);
  }
}
