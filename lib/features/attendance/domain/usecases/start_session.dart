import '../../../../core/usecase/usecase.dart';
import '../entities/class_session_entity.dart';
import '../repositories/attendance_repository.dart';

class StartClassSession implements UseCase<ClassSessionEntity, StartClassSessionParams> {
  final AttendanceRepository repository;

  StartClassSession(this.repository);

  @override
  Future<ClassSessionEntity> call(StartClassSessionParams params) {
    return repository.startClassSession(
      courseId: params.courseId,
      teacherId: params.teacherId,
    );
  }
}

class StartClassSessionParams {
  final String courseId;
  final String teacherId;

  StartClassSessionParams({
    required this.courseId,
    required this.teacherId,
  });
}
