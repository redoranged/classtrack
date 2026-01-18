import '../entities/user_entity.dart';
import '../entities/course_entity.dart';
import '../entities/attendance_entity.dart';
import '../entities/class_session_entity.dart';

abstract class AttendanceRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? studentId,
  });
  
  // Course management
  Future<List<CourseEntity>> getCourses();
  Future<List<CourseEntity>> getTeacherCourses(String teacherId);
  Future<List<CourseEntity>> getStudentCourses(String userId);
  Future<CourseEntity> createCourse({
    required String name,
    required String classCode,
    required String lecturer,
    required String teacherId,
  });
  Future<CourseEntity> getCourseByCode(String classCode);
  Future<void> joinCourseByCode(String userId, String classCode);
  
  // Session management
  Future<ClassSessionEntity> startClassSession({
    required String courseId,
    required String teacherId,
  });
  Future<ClassSessionEntity?> getActiveSession(String courseId);
  Future<List<ClassSessionEntity>> getCourseSessions(String courseId);
  Future<void> closeSession(String sessionId);
  
  // Attendance
  Future<void> checkIn({
    required String userId,
    required String courseId,
    required String sessionId,
  });
  Future<List<AttendanceEntity>> getAttendanceHistory(String userId);
  Future<List<AttendanceEntity>> getSessionAttendance(String sessionId);
}
