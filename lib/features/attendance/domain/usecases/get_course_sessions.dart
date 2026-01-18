import '../../../../core/usecase/usecase.dart';
import '../entities/class_session_entity.dart';
import '../repositories/attendance_repository.dart';

class GetCourseSessions implements UseCase<List<ClassSessionEntity>, String> {
  final AttendanceRepository repository;
  GetCourseSessions(this.repository);

  @override
  Future<List<ClassSessionEntity>> call(String courseId) {
    return repository.getCourseSessions(courseId);
  }
}
