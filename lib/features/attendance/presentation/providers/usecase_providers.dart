import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/attendance_mock_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/submit_attendance.dart';

// Use mock datasource - no Firebase needed
final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>((ref) {
  return AttendanceMockDataSourceImpl();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    remoteDataSource: ref.read(attendanceRemoteDataSourceProvider),
  );
});

final loginUserProvider = Provider((ref) => LoginUser(ref.read(attendanceRepositoryProvider)));
final getCoursesProvider = Provider((ref) => GetCourses(ref.read(attendanceRepositoryProvider)));
final submitAttendanceProvider = Provider((ref) => SubmitAttendance(ref.read(attendanceRepositoryProvider)));
final getAttendanceHistoryProvider = Provider((ref) => GetAttendanceHistory(ref.read(attendanceRepositoryProvider)));
