class AttendanceEntity {
  final String? id;
  final String userId;
  final String courseId;
  final String? sessionId;
  final DateTime date;
  final String status;

  AttendanceEntity({
    this.id,
    required this.userId,
    required this.courseId,
    this.sessionId,
    required this.date,
    required this.status,
  });
}
