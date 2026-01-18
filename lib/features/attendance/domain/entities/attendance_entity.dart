class AttendanceEntity {
  final String userId;
  final String courseId;
  final DateTime date;
  final String status;

  AttendanceEntity({
    required this.userId,
    required this.courseId,
    required this.date,
    required this.status,
  });
}
