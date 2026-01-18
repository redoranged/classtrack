import '../../../../core/usecase/usecase.dart';
import '../repositories/attendance_repository.dart';

class JoinCourseByCode implements UseCase<void, JoinCourseByCodeParams> {
  final AttendanceRepository repository;

  JoinCourseByCode(this.repository);

  @override
  Future<void> call(JoinCourseByCodeParams params) {
    return repository.joinCourseByCode(params.userId, params.classCode);
  }
}

class JoinCourseByCodeParams {
  final String userId;
  final String classCode;

  JoinCourseByCodeParams({
    required this.userId,
    required this.classCode,
  });
}
