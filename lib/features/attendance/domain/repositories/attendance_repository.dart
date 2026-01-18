import '../entities/user_entity.dart';
import '../entities/course_entity.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<UserEntity> login(String email, String password);
  Future<List<CourseEntity>> getCourses();
  Future<void> submitAttendance(AttendanceEntity attendance);
  Future<List<AttendanceEntity>> getAttendanceHistory(String userId);
}
