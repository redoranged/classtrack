import '../../../../core/usecase/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/attendance_repository.dart';

class GetStudentCourses implements UseCase<List<CourseEntity>, String> {
  final AttendanceRepository repository;
  GetStudentCourses(this.repository);

  @override
  Future<List<CourseEntity>> call(String userId) {
    return repository.getStudentCourses(userId);
  }
}
