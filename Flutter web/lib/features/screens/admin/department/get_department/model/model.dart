class GetDepartmentModel {

  GetDepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.headId,
    required this.headName,
    required this.createdAt,
    required this.updatedAt,
    required this.years,
  });

  factory GetDepartmentModel.fromJson(Map<String, dynamic> json) {
    try {
      return GetDepartmentModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'],
        headId: json['headId'] ?? 0,
        headName: json['headName'] ?? '',
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] is String
            ? DateTime.parse(json['createdAt'])
            : json['createdAt'].toDate())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] is String
            ? DateTime.parse(json['updatedAt'])
            : json['updatedAt'].toDate())
            : DateTime.now(),
        years: json['years'] != null
            ? List<YearModel>.from(
          json['years'].map((e) => YearModel.fromJson(e)).where((year) => year != null),
        )
            : [],
      );
    } catch (e) {
      print('Error parsing department: $e');
      return GetDepartmentModel(
        id: 0,
        name: 'Unknown Department',
        description: '',
        headId: 0,
        headName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        years: [],
      );
    }
  }
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int headId;
  final String headName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<YearModel> years;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'headId': headId,
      'headName': headName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'years': years.map((e) => e.toJson()).toList(),
    };
  }
  GetDepartmentModel copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    int? headId,
    String? headName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<YearModel>? years,


  })
  {
    return
      GetDepartmentModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        headId: headId ?? this.headId,
        headName: headName ?? this.headName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        years: years ?? this.years,
      );
  }


}

class YearModel {

  YearModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate, this.departmentId,

  });

  factory YearModel.fromJson(Map<String, dynamic> json) {
    try {
      return YearModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        startDate: json['startDate'] != null
            ? (json['startDate'] is String
            ? DateTime.parse(json['startDate'])
            : json['startDate'].toDate())
            : DateTime.now(),
        endDate: json['endDate'] != null
            ? (json['endDate'] is String
            ? DateTime.parse(json['endDate'])
            : json['endDate'].toDate())
            : DateTime.now(),
        departmentId: json['departmentId'] ?? 0,
      );
    } catch (e) {
      print('Error parsing year: $e');
      return YearModel(
        id: 0,
        name: 'Unknown Year',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    }
  }
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int? departmentId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'departmentId': departmentId,
    };
  }
}

