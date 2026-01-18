import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  CourseModel({
    required super.id,
    required super.name,
    required super.lecturer,
  });

  factory CourseModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      name: json['name'] ?? '',
      lecturer: json['lecturer'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'lecturer': lecturer,
    };
  }
}
