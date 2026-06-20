import 'dart:convert';

/// Student-side assignment detail.
///
/// IMPORTANT: the real API response differs from the admin `AssignmentModel`:
///  - `submissionCount` (singular "submission"), not `submissionsCount`
///  - `assignmentFileUrls` is a JSON-ENCODED STRING (e.g. "[\"/uploads/...\"]"),
///    not a list of file objects — so it must be decoded manually.
///  - includes `targetSquadronName`, `createdByName`, `startDate` as plain fields.
class StudentAssignmentModel {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final String instructions;
  final int maxGrade;
  final bool allowLateSubmission;
  final DateTime? startDate;
  final DateTime? deadlineDate;
  final int? targetSquadronId;
  final String? targetSquadronName;
  final int submissionCount;
  final bool isVisible;
  final int createdById;
  final String createdByName;
  final DateTime? createdAt;
  final List<String> fileUrls;

  StudentAssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.maxGrade,
    required this.allowLateSubmission,
    this.startDate,
    this.deadlineDate,
    this.targetSquadronId,
    this.targetSquadronName,
    required this.submissionCount,
    required this.isVisible,
    required this.createdById,
    required this.createdByName,
    this.createdAt,
    required this.fileUrls,
  });

  factory StudentAssignmentModel.fromJson(Map<String, dynamic> json) {
    return StudentAssignmentModel(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      maxGrade: json['maxGrade'] ?? 100,
      allowLateSubmission: json['allowLateSubmission'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      deadlineDate: json['deadLineDate'] != null
          ? DateTime.tryParse(json['deadLineDate'])
          : null,
      targetSquadronId: json['targetSquadronId'],
      targetSquadronName: json['targetSquadronName'],
      submissionCount: json['submissionCount'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      createdById: json['createdById'] ?? 0,
      createdByName: json['createdByName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      fileUrls: _parseFileUrls(json['assignmentFileUrls']),
    );
  }

  static List<String> _parseFileUrls(dynamic raw) {
    if (raw == null) return [];
    // Already a list (defensive — in case backend changes shape later)
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // not valid JSON — ignore
      }
    }
    return [];
  }

  bool get hasDeadlinePassed {
    if (deadlineDate == null) return false;
    return DateTime.now().isAfter(deadlineDate!);
  }

  bool get isSubmitted => submissionCount > 0;

  Duration? get timeRemaining {
    if (deadlineDate == null) return null;
    final diff = deadlineDate!.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  String get statusLabel {
    if (isSubmitted) return 'Submitted';
    if (hasDeadlinePassed) {
      return allowLateSubmission ? 'Late submission allowed' : 'Deadline passed';
    }
    return 'Pending';
  }
}

/// Lightweight item for the assignments list screen.
/// The list endpoint (`GET /courses/{id}/assignments`) is assumed to return
/// objects with at least these fields — same contract as the detail object,
/// so we reuse [StudentAssignmentModel] directly.
typedef AssignmentListItem = StudentAssignmentModel;
