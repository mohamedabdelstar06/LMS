import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which assignments the student has submitted.
/// Uses SharedPreferences for persistence across sessions.
/// This ensures the UI reflects "Submitted" status immediately after
/// a successful submission, even before the backend updates.
class SubmissionTracker {
  static const _key = 'submitted_assignment_ids';

  static Future<void> markSubmitted(int assignmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (!ids.contains(assignmentId.toString())) {
      ids.add(assignmentId.toString());
      await prefs.setStringList(_key, ids);
    }
  }

  static Future<bool> isSubmitted(int assignmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.contains(assignmentId.toString());
  }

  static Future<Set<int>> getSubmittedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
