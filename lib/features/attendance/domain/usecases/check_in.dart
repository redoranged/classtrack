import '../../../../core/usecase/usecase.dart';
import '../repositories/attendance_repository.dart';

class CheckIn implements UseCase<void, CheckInParams> {
  final AttendanceRepository repository;

  CheckIn(this.repository);

  @override
  Future<void> call(CheckInParams params) {
    return repository.checkIn(
      userId: params.userId,
      courseId: params.courseId,
      sessionId: params.sessionId,
    );
  }
}

class CheckInParams {
  final String userId;
  final String courseId;
  final String sessionId;

  CheckInParams({
    required this.userId,
    required this.courseId,
    required this.sessionId,
  });
}
