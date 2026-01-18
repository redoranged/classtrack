import '../../../../core/usecase/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/attendance_repository.dart';

class GetTeacherCourses implements UseCase<List<CourseEntity>, String> {
  final AttendanceRepository repository;
  GetTeacherCourses(this.repository);

  @override
  Future<List<CourseEntity>> call(String teacherId) {
    return repository.getTeacherCourses(teacherId);
  }
}
