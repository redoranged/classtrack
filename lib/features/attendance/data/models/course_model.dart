import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  CourseModel({
    required super.id,
    required super.name,
    required super.classCode,
    required super.lecturer,
    super.teacherId,
  });

  factory CourseModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      name: json['name'] ?? '',
      classCode: json['classCode'] ?? '',
      lecturer: json['lecturer'] ?? '',
      teacherId: json['teacherId'],
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      classCode: json['class_code'] ?? '',
      lecturer: json['lecturer'] ?? '',
      teacherId: json['teacher_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'classCode': classCode,
      'lecturer': lecturer,
      if (teacherId != null) 'teacherId': teacherId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_code': classCode,
      'lecturer': lecturer,
      if (teacherId != null) 'teacher_id': teacherId,
    };
  }
}
