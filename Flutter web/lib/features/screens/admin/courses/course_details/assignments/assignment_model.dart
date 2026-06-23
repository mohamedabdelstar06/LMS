class AssignmentModel {

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.maxGrade,
    required this.allowLateSubmission,
    required this.isVisible,
    this.targetSquadronId,
    required this.files,
    this.startDate,
    this.deadlineDate,
    this.submissionsCount = 0,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      maxGrade: json['maxGrade'] ?? 100,
      allowLateSubmission: json['allowLateSubmission'] ?? false,
      isVisible: json['isVisible'] ?? true,
      targetSquadronId: json['targetSquadronId'],
      files: (json['files'] as List<dynamic>? ?? [])
          .map((f) => AssignmentFileModel.fromJson(f))
          .toList(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      deadlineDate: json['deadLineDate'] != null
          ? DateTime.tryParse(json['deadLineDate'])
          : null,
      submissionsCount: json['submissionsCount'] ?? 0,
    );
  }
  final int id;
  final int courseId;
  final String title;
  final String description;
  final String instructions;
  final int maxGrade;
  final bool allowLateSubmission;
  final bool isVisible;
  final int? targetSquadronId;
  final List<AssignmentFileModel> files;
  final DateTime? startDate;
  final DateTime? deadlineDate;
  final int submissionsCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'description': description,
    'instructions': instructions,
    'maxGrade': maxGrade,
    'allowLateSubmission': allowLateSubmission,
    'isVisible': isVisible,
    'targetSquadronId': targetSquadronId,
  };
}

class AssignmentFileModel {

  AssignmentFileModel({this.id, this.fileName, this.fileUrl});

  factory AssignmentFileModel.fromJson(Map<String, dynamic> json) {
    return AssignmentFileModel(
      id: json['id'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
    );
  }
  final int? id;
  final String? fileName;
  final String? fileUrl;
}

class SubmissionModel {

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.files,
    this.grade,
    this.feedback,
    required this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] ?? 0,
      assignmentId: json['assignmentId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      files: (json['files'] as List<dynamic>? ?? [])
          .map((f) => AssignmentFileModel.fromJson(f))
          .toList(),
      grade: json['grade'],
      feedback: json['feedback'],
      submittedAt:
          DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
  final int id;
  final int assignmentId;
  final int studentId;
  final String studentName;
  final List<AssignmentFileModel> files;
  final int? grade;
  final String? feedback;
  final DateTime submittedAt;
}

class UploadFileProgress {

  UploadFileProgress({
    required this.fileName,
    this.progress = 0.0,
    this.isCompleted = false,
    this.hasError = false,
  });
  final String fileName;
  double progress;
  bool isCompleted;
  bool hasError;

  UploadFileProgress copyWith({
    double? progress,
    bool? isCompleted,
    bool? hasError,
  }) => UploadFileProgress(
    fileName: fileName,
    progress: progress ?? this.progress,
    isCompleted: isCompleted ?? this.isCompleted,
    hasError: hasError ?? this.hasError,
  );
}
