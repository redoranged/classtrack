class UserEntity {
  final String id;
  final String name;
  final String? studentId;
  final String role; // 'teacher' or 'student'
  final DateTime? createdAt;

  UserEntity({
    required this.id,
    required this.name,
    this.studentId,
    this.role = 'student',
    this.createdAt,
  });
}
