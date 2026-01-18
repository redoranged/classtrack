import '../../../../core/usecase/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/attendance_repository.dart';

class GetCourses implements UseCase<List<CourseEntity>, NoParams> {
  final AttendanceRepository repository;

  GetCourses(this.repository);

  @override
  Future<List<CourseEntity>> call(NoParams params) {
    return repository.getCourses();
  }
}
