import '../../../../core/usecase/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistory implements UseCase<List<AttendanceEntity>, String> {
  final AttendanceRepository repository;

  GetAttendanceHistory(this.repository);

  @override
  Future<List<AttendanceEntity>> call(String userId) {
    return repository.getAttendanceHistory(userId);
  }
}
