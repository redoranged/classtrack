import '../../../../core/usecase/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetSessionAttendance implements UseCase<List<AttendanceEntity>, String> {
  final AttendanceRepository repository;
  GetSessionAttendance(this.repository);

  @override
  Future<List<AttendanceEntity>> call(String sessionId) {
    return repository.getSessionAttendance(sessionId);
  }
}
