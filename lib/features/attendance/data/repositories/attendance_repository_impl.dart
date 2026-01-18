import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/class_session_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_supabase_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceSupabaseDatasource supabaseDatasource;

  AttendanceRepositoryImpl({required this.supabaseDatasource});

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await supabaseDatasource.signIn(email, password);
    if (user == null) {
      throw Exception('Login gagal');
    }
    return user;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? studentId,
  }) async {
    final user = await supabaseDatasource.signUp(
      email,
      password,
      name,
      studentId ?? '',
      role: role,
    );
    return user;
  }

  // Course management
  @override
  Future<List<CourseEntity>> getCourses() async {
    return await supabaseDatasource.getCourses();
  }

  @override
  Future<List<CourseEntity>> getTeacherCourses(String teacherId) async {
    return await supabaseDatasource.getTeacherCourses(teacherId);
  }

  @override
  Future<List<CourseEntity>> getStudentCourses(String userId) async {
    return await supabaseDatasource.getStudentCourses(userId);
  }

  @override
  Future<CourseEntity> createCourse({
    required String name,
    required String classCode,
    required String lecturer,
    required String teacherId,
  }) {
    return supabaseDatasource.createCourse(
      name: name,
      classCode: classCode,
      lecturer: lecturer,
      teacherId: teacherId,
    );
  }

  @override
  Future<CourseEntity> getCourseByCode(String classCode) {
    return supabaseDatasource.getCourseByCode(classCode);
  }

  @override
  Future<void> joinCourseByCode(String userId, String classCode) async {
    final course = await supabaseDatasource.getCourseByCode(classCode);
    await supabaseDatasource.enrollCourse(userId, course.id);
  }

  // Session management
  @override
  Future<ClassSessionEntity> startClassSession({
    required String courseId,
    required String teacherId,
  }) {
    return supabaseDatasource.startClassSession(
      courseId: courseId,
      teacherId: teacherId,
    );
  }

  @override
  Future<ClassSessionEntity?> getActiveSession(String courseId) {
    return supabaseDatasource.getActiveSession(courseId);
  }

  @override
  Future<List<ClassSessionEntity>> getCourseSessions(String courseId) async {
    return await supabaseDatasource.getCourseSessions(courseId);
  }

  @override
  Future<void> closeSession(String sessionId) {
    return supabaseDatasource.closeSession(sessionId);
  }

  // Attendance
  @override
  Future<void> checkIn({
    required String userId,
    required String courseId,
    required String sessionId,
  }) {
    return supabaseDatasource.checkIn(
      userId: userId,
      courseId: courseId,
      sessionId: sessionId,
    );
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(String userId) async {
    return await supabaseDatasource.getAttendanceByUser(userId);
  }

  @override
  Future<List<AttendanceEntity>> getSessionAttendance(String sessionId) async {
    return await supabaseDatasource.getSessionAttendance(sessionId);
  }
}
