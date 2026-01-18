import '../../../../core/usecase/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class SubmitAttendance implements UseCase<void, AttendanceEntity> {
  final AttendanceRepository repository;

  SubmitAttendance(this.repository);

  @override
  Future<void> call(AttendanceEntity params) {
    return repository.submitAttendance(params);
  }
}
