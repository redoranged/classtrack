import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<List<CourseEntity>> getCourses() async {
    return await remoteDataSource.getCourses();
  }

  @override
  Future<void> submitAttendance(AttendanceEntity attendance) async {
    final model = AttendanceModel(
      userId: attendance.userId,
      courseId: attendance.courseId,
      date: attendance.date,
      status: attendance.status,
    );
    await remoteDataSource.submitAttendance(model);
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(String userId) async {
    return await remoteDataSource.getAttendanceHistory(userId);
  }
}
