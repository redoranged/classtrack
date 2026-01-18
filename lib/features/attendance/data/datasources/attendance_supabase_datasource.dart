import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';
import '../models/class_session_model.dart';

abstract class AttendanceSupabaseDatasource {
  // Auth
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel> signUp(
    String email,
    String password,
    String name,
    String studentId,
    {String role = 'student'}
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  
  // Courses
  Future<List<CourseModel>> getCourses();
  Future<List<CourseModel>> getTeacherCourses(String teacherId);
  Future<List<CourseModel>> getStudentCourses(String userId);
  Future<CourseModel> getCourseById(String courseId);
  Future<CourseModel> getCourseByCode(String classCode);
  Future<CourseModel> createCourse({
    required String name,
    required String classCode,
    required String lecturer,
    required String teacherId,
  });
  Future<void> enrollCourse(String userId, String courseId);
  
  // Sessions
  Future<ClassSessionModel> startClassSession({
    required String courseId,
    required String teacherId,
  });
  Future<ClassSessionModel?> getActiveSession(String courseId);
  Future<List<ClassSessionModel>> getCourseSessions(String courseId);
  Future<void> closeSession(String sessionId);
  
  // Attendance
  Future<void> checkIn({
    required String userId,
    required String courseId,
    required String sessionId,
  });
  Future<List<AttendanceModel>> getAttendanceByUser(String userId);
  Future<List<AttendanceModel>> getAttendanceByCourse(String courseId);
  Future<List<AttendanceModel>> getSessionAttendance(String sessionId);
}

class AttendanceSupabaseDatasourceImpl implements AttendanceSupabaseDatasource {
  final SupabaseClient supabase;

  AttendanceSupabaseDatasourceImpl({required this.supabase});

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user data from users table
        try {
          final userData = await supabase
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .single();

          return UserModel.fromJson(userData);
        } catch (e) {
          // User belum ada di tabel users, buat record baru
          final defaultUserData = {
            'id': response.user!.id,
            'name': response.user!.email ?? 'User',
            'student_id': '',
            'role': 'student',
          };
          try {
            await supabase.from('users').insert(defaultUserData);
          } catch (_) {
            // Ignore jika sudah ada
          }
          return UserModel.fromJson(defaultUserData);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String name,
    String studentId,
    {String role = 'student'}
  ) async {
    try {
      // 1. Sign up user in Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'student_id': studentId.isEmpty ? null : studentId,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Registrasi gagal: User tidak terbuat');
      }

      // 2. Insert user data to users table
      final userData = {
        'id': authResponse.user!.id,
        'name': name,
        'student_id': studentId.isEmpty ? null : studentId,
        'role': role,
      };

      try {
        await supabase.from('users').insert(userData);
      } catch (insertError) {
        // Jika insert gagal, coba update (fallback untuk duplikat)
        try {
          await supabase.from('users').update(userData).eq('id', authResponse.user!.id);
        } catch (updateError) {
          throw Exception('Gagal menyimpan data user ke database: $insertError');
        }
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await supabase.from('courses').select();

      return (response as List)
          .map((course) => CourseModel.fromJson(course))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kelas: $e');
    }
  }

  @override
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    try {
      final response = await supabase
          .from('courses')
          .select()
          .eq('teacher_id', teacherId);

      return (response as List)
          .map((course) => CourseModel.fromJson(course))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kelas pengajar: $e');
    }
  }

  @override
  Future<List<CourseModel>> getStudentCourses(String userId) async {
    try {
      final response = await supabase
          .from('enrollments')
          .select('course_id, courses(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((enrollment) => CourseModel.fromJson(enrollment['courses']))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kelas mahasiswa: $e');
    }
  }

  @override
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      final response = await supabase
          .from('courses')
          .select()
          .eq('id', courseId)
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil data kelas: $e');
    }
  }

  @override
  Future<CourseModel> getCourseByCode(String classCode) async {
    try {
      final response = await supabase
          .from('courses')
          .select()
          .eq('class_code', classCode)
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Kode kelas tidak ditemukan: $e');
    }
  }

  @override
  Future<void> enrollCourse(String userId, String courseId) async {
    try {
      await supabase.from('enrollments').insert({
        'user_id': userId,
        'course_id': courseId,
      });
    } catch (e) {
      throw Exception('Gagal mendaftar kelas: $e');
    }
  }

  @override
  Future<CourseModel> createCourse({
    required String name,
    required String classCode,
    required String lecturer,
    required String teacherId,
  }) async {
    try {
      final response = await supabase
          .from('courses')
          .insert({
            'name': name,
            'class_code': classCode,
            'lecturer': lecturer,
            'teacher_id': teacherId,
          })
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat kelas: $e');
    }
  }

  @override
  Future<ClassSessionModel> startClassSession({
    required String courseId,
    required String teacherId,
  }) async {
    try {
      // Check if there's already an active session
      final existing = await getActiveSession(courseId);
      if (existing != null) {
        throw Exception('Sesi kelas masih aktif');
      }

      final response = await supabase
          .from('class_sessions')
          .insert({
            'course_id': courseId,
            'teacher_id': teacherId,
            'started_at': DateTime.now().toIso8601String(),
            'is_active': true,
          })
          .select()
          .single();

      return ClassSessionModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memulai sesi: $e');
    }
  }

  @override
  Future<ClassSessionModel?> getActiveSession(String courseId) async {
    try {
      final response = await supabase
          .from('class_sessions')
          .select()
          .eq('course_id', courseId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return ClassSessionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ClassSessionModel>> getCourseSessions(String courseId) async {
    try {
      final response = await supabase
          .from('class_sessions')
          .select()
          .eq('course_id', courseId)
          .order('started_at', ascending: false);

      return (response as List)
          .map((session) => ClassSessionModel.fromJson(session))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar sesi: $e');
    }
  }

  @override
  Future<void> closeSession(String sessionId) async {
    try {
      // Get session details first
      final session = await supabase
          .from('class_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      // Close the session
      await supabase.from('class_sessions').update({
        'is_active': false,
        'closed_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      // Get all enrolled students for this course
      final enrollments = await supabase
          .from('enrollments')
          .select('user_id')
          .eq('course_id', session['course_id']);

      // Get students who already checked in
      final checkedIn = await supabase
          .from('attendances')
          .select('user_id')
          .eq('session_id', sessionId);

      final checkedInUserIds = (checkedIn as List)
          .map((a) => a['user_id'] as String)
          .toSet();

      // Mark absent for students who didn't check in
      final absentRecords = (enrollments as List)
          .where((e) => !checkedInUserIds.contains(e['user_id']))
          .map((e) => {
                'user_id': e['user_id'],
                'course_id': session['course_id'],
                'session_id': sessionId,
                'date': DateTime.now().toIso8601String(),
                'status': 'absent',
              })
          .toList();

      if (absentRecords.isNotEmpty) {
        await supabase.from('attendances').insert(absentRecords);
      }
    } catch (e) {
      throw Exception('Gagal menutup sesi: $e');
    }
  }

  @override
  Future<void> checkIn({
    required String userId,
    required String courseId,
    required String sessionId,
  }) async {
    try {
      // Check if session is active
      final session = await supabase
          .from('class_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      if (session['is_active'] != true) {
        throw Exception('Sesi kelas tidak aktif');
      }

      // Check for existing attendance
      final existing = await supabase
          .from('attendances')
          .select()
          .eq('user_id', userId)
          .eq('session_id', sessionId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Anda sudah absen untuk sesi ini');
      }

      // Record attendance
      await supabase.from('attendances').insert({
        'user_id': userId,
        'course_id': courseId,
        'session_id': sessionId,
        'date': DateTime.now().toIso8601String(),
        'status': 'present',
      });
    } catch (e) {
      throw Exception('Gagal check-in: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceByUser(String userId) async {
    try {
      final response = await supabase
          .from('attendances')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((attendance) => AttendanceModel.fromJson(attendance))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data absensi: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceByCourse(String courseId) async {
    try {
      final response = await supabase
          .from('attendances')
          .select()
          .eq('course_id', courseId)
          .order('date', ascending: false);

      return (response as List)
          .map((attendance) => AttendanceModel.fromJson(attendance))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data absensi: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getSessionAttendance(String sessionId) async {
    try {
      final response = await supabase
          .from('attendances')
          .select()
          .eq('session_id', sessionId);

      return (response as List)
          .map((attendance) => AttendanceModel.fromJson(attendance))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data absensi sesi: $e');
    }
  }
}
