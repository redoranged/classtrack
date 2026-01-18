class ClassSessionEntity {
  final String id;
  final String courseId;
  final String teacherId;
  final DateTime startedAt;
  final DateTime? closedAt;
  final bool isActive;

  ClassSessionEntity({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.startedAt,
    this.closedAt,
    required this.isActive,
  });
}
