class CourseEntity {
  final String id;
  final String name;
  final String classCode;
  final String lecturer;
  final String? teacherId;

  CourseEntity({
    required this.id,
    required this.name,
    required this.classCode,
    required this.lecturer,
    this.teacherId,
  });
}
