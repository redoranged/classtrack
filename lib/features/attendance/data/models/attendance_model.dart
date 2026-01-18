import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  AttendanceModel({
    super.id,
    required super.userId,
    required super.courseId,
    super.sessionId,
    required super.date,
    required super.status,
  });

  factory AttendanceModel.fromFirestore(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      sessionId: json['sessionId'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? '',
      sessionId: json['session_id'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'courseId': courseId,
      if (sessionId != null) 'sessionId': sessionId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'course_id': courseId,
      if (sessionId != null) 'session_id': sessionId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
