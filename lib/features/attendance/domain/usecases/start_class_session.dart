import '../../../../core/usecase/usecase.dart';
import '../entities/class_session_entity.dart';
import '../repositories/attendance_repository.dart';

class StartClassSession implements UseCase<ClassSessionEntity, StartSessionParams> {
  final AttendanceRepository repository;

  StartClassSession(this.repository);

  @override
  Future<ClassSessionEntity> call(StartSessionParams params) {
    return repository.startClassSession(
      courseId: params.courseId,
      teacherId: params.teacherId,
    );
  }
}

class StartSessionParams {
  final String courseId;
  final String teacherId;

  StartSessionParams({required this.courseId, required this.teacherId});
}
