import '../../../../core/usecase/usecase.dart';
import '../repositories/attendance_repository.dart';

class CloseSession implements UseCase<void, CloseSessionParams> {
  final AttendanceRepository repository;

  CloseSession(this.repository);

  @override
  Future<void> call(CloseSessionParams params) {
    return repository.closeSession(params.sessionId);
  }
}

class CloseSessionParams {
  final String sessionId;

  CloseSessionParams({required this.sessionId});
}
