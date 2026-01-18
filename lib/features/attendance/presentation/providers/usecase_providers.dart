import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/attendance_supabase_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/get_teacher_courses.dart';
import '../../domain/usecases/get_student_courses.dart';
import '../../domain/usecases/get_session_attendance.dart';
import '../../domain/usecases/get_course_sessions.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/create_course.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/close_session.dart';
import '../../domain/usecases/join_course_by_code.dart';
import '../../domain/usecases/check_in.dart';
import '../../domain/entities/class_session_entity.dart';

export '../../domain/usecases/check_in.dart' show CheckInParams;
export '../../domain/usecases/start_session.dart' show StartClassSessionParams;
export '../../domain/usecases/close_session.dart' show CloseSessionParams;
export '../../domain/usecases/join_course_by_code.dart' show JoinCourseByCodeParams;

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Supabase datasource provider
final attendanceSupabaseDatasourceProvider = Provider<AttendanceSupabaseDatasource>((ref) {
  return AttendanceSupabaseDatasourceImpl(
    supabase: ref.read(supabaseClientProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    supabaseDatasource: ref.read(attendanceSupabaseDatasourceProvider),
  );
});

// Auth
final loginUserProvider = Provider((ref) => LoginUser(ref.read(attendanceRepositoryProvider)));
final registerUserProvider = Provider((ref) => RegisterUser(ref.read(attendanceRepositoryProvider)));

// Courses
final getCoursesProvider = Provider((ref) => GetCourses(ref.read(attendanceRepositoryProvider)));
final getTeacherCoursesProvider = Provider((ref) => GetTeacherCourses(ref.read(attendanceRepositoryProvider)));
final getStudentCoursesProvider = Provider((ref) => GetStudentCourses(ref.read(attendanceRepositoryProvider)));
final createCourseProvider = Provider((ref) => CreateCourse(ref.read(attendanceRepositoryProvider)));

// Sessions
final startSessionProvider = Provider((ref) => StartClassSession(ref.read(attendanceRepositoryProvider)));
final closeSessionProvider = Provider((ref) => CloseSession(ref.read(attendanceRepositoryProvider)));
final getCourseSessionsProvider = Provider((ref) => GetCourseSessions(ref.read(attendanceRepositoryProvider)));

// Enrollment
final joinCourseProvider = Provider((ref) => JoinCourseByCode(ref.read(attendanceRepositoryProvider)));

// Attendance
final checkInProvider = Provider((ref) => CheckIn(ref.read(attendanceRepositoryProvider)));
final getAttendanceHistoryProvider = Provider((ref) => GetAttendanceHistory(ref.read(attendanceRepositoryProvider)));
final getSessionAttendanceProvider = Provider((ref) => GetSessionAttendance(ref.read(attendanceRepositoryProvider)));

// Active session provider - fetches current active session for a course
final activeSessionProvider =
    FutureProvider.family<ClassSessionEntity?, String>((ref, courseId) async {
  final repository = ref.read(attendanceRepositoryProvider);
  try {
    return await repository.getActiveSession(courseId);
  } catch (e) {
    return null;
  }
});

// Course sessions provider - fetches all sessions for a course
final courseSessionsProvider =
    FutureProvider.family<List<ClassSessionEntity>, String>((ref, courseId) async {
  final getCourseSessions = ref.read(getCourseSessionsProvider);
  return await getCourseSessions(courseId);
});
