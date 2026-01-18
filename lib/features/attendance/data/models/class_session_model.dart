import '../../domain/entities/class_session_entity.dart';

class ClassSessionModel extends ClassSessionEntity {
  ClassSessionModel({
    required super.id,
    required super.courseId,
    required super.teacherId,
    required super.startedAt,
    super.closedAt,
    required super.isActive,
  });

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) {
    return ClassSessionModel(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'teacher_id': teacherId,
      'started_at': startedAt.toIso8601String(),
      if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
      'is_active': isActive,
    };
  }
}
