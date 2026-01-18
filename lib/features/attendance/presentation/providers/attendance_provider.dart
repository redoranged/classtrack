import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import 'usecase_providers.dart';
import 'dart:async';

// Session Provider untuk tracking active session
final sessionProvider = NotifierProvider<SessionNotifier, bool>(() {
  return SessionNotifier();
});

class SessionNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setSession(bool isActive) {
    state = isActive;
  }
  
  void logout() {
    state = false;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserEntity?>(() {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() => null;
  
  void setUser(UserEntity user) {
    state = user;
  }
  
  void clearUser() {
    state = null;
  }
}

final coursesProvider = FutureProvider<List<CourseEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Strict role-based course listing
  if (user.role == 'teacher') {
    final getTeacherCourses = ref.watch(getTeacherCoursesProvider);
    return await getTeacherCourses(user.id);
  } else {
    final getStudentCourses = ref.watch(getStudentCoursesProvider);
    return await getStudentCourses(user.id);
  }
});

final attendanceHistoryProvider = FutureProvider.family<List<AttendanceEntity>, String>((ref, userId) async {
  final getAttendanceHistory = ref.watch(getAttendanceHistoryProvider);
  return await getAttendanceHistory(userId);
});

// Polling stream for session attendance to approximate real-time updates
final sessionAttendanceStreamProvider = StreamProvider.family<List<AttendanceEntity>, String>((ref, sessionId) {
  final getSessionAttendance = ref.read(getSessionAttendanceProvider);
  // Poll every 3 seconds; cancel on dispose
  final controller = StreamController<List<AttendanceEntity>>();
  Timer? timer;
  Future<void> fetch() async {
    try {
      final list = await getSessionAttendance(sessionId);
      controller.add(list);
    } catch (e) {
      // ignore errors in polling
    }
  }
  // initial fetch
  fetch();
  timer = Timer.periodic(const Duration(seconds: 3), (_) => fetch());
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

// Attendance counts per session (present/absent)
final sessionAttendanceCountsProvider = FutureProvider.family<Map<String, int>, String>((ref, sessionId) async {
  final getSessionAttendance = ref.read(getSessionAttendanceProvider);
  final list = await getSessionAttendance(sessionId);
  final present = list.where((e) => e.status.toLowerCase() == 'present').length;
  final absent = list.where((e) => e.status.toLowerCase() == 'absent').length;
  return {'present': present, 'absent': absent};
});

class AttendanceState {
  final bool isLoading;
  final String? error;
  
  const AttendanceState({this.isLoading = false, this.error});
  
  AttendanceState copyWith({bool? isLoading, String? error}) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => const AttendanceState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginUser = ref.read(loginUserProvider);
      final user = await loginUser(LoginParams(email: email, password: password));
      ref.read(currentUserProvider.notifier).setUser(user);
      ref.read(sessionProvider.notifier).state = true;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? studentId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final registerUser = ref.read(registerUserProvider);
      final user = await registerUser(
        RegisterParams(
          email: email,
          password: password,
          name: name,
          role: 'student',
          studentId: studentId,
        ),
      );
      ref.read(currentUserProvider.notifier).setUser(user);
      ref.read(sessionProvider.notifier).state = true;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    ref.read(currentUserProvider.notifier).clearUser();
    ref.read(sessionProvider.notifier).state = false;
    state = const AttendanceState();
  }

  Future<void> submitAttendance(String courseId, String status) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check in instead of submitting attendance
      // This would be called from class session
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final attendanceNotifierProvider = NotifierProvider<AttendanceNotifier, AttendanceState>(() {
  return AttendanceNotifier();
});
