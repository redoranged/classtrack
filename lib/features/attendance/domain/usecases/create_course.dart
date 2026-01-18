import '../../../../core/usecase/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/attendance_repository.dart';

class CreateCourse implements UseCase<CourseEntity, CreateCourseParams> {
  final AttendanceRepository repository;

  CreateCourse(this.repository);

  @override
  Future<CourseEntity> call(CreateCourseParams params) {
    return repository.createCourse(
      name: params.name,
      classCode: params.classCode,
      lecturer: params.lecturer,
      teacherId: params.teacherId,
    );
  }
}

class CreateCourseParams {
  final String name;
  final String classCode;
  final String lecturer;
  final String teacherId;

  CreateCourseParams({
    required this.name,
    required this.classCode,
    required this.lecturer,
    required this.teacherId,
  });
}
