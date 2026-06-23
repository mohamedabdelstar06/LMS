
class ImportStudentsResponseModel {

  ImportStudentsResponseModel({
    required this.totalRows,
    required this.successCount,
    required this.createdCount,
    required this.updatedCount,
    required this.failedCount,
    required this.errors,
  });

  factory ImportStudentsResponseModel.fromJson(Map<String, dynamic> json) {
    return ImportStudentsResponseModel(
      totalRows: json['totalRows'] ?? 0,
      successCount: json['successCount'] ?? 0,
      createdCount: json['createdCount'] ?? 0,
      updatedCount: json['updatedCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => ImportError.fromJson(e))
          .toList() ??
          [],
    );
  }
  final int totalRows;
  final int successCount;
  final int createdCount;
  final int updatedCount;
  final int failedCount;
  final List<ImportError> errors;
}

class ImportError {

  ImportError({
    required this.rowNumber,
    required this.email,
    required this.error,
  });

  factory ImportError.fromJson(Map<String, dynamic> json) {
    return ImportError(
      rowNumber: json['rowNumber'] ?? 0,
      email: json['email'] ?? '',
      error: json['error'] ?? '',
    );
  }
  final int rowNumber;
  final String email;
  final String error;
}