import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import 'usecase_providers.dart';

// Session Provider untuk tracking active session
final sessionProvider = StateProvider<bool>((ref) => false);

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
  final getCourses = ref.watch(getCoursesProvider);
  return await getCourses(NoParams());
});

final attendanceHistoryProvider = FutureProvider.family<List<AttendanceEntity>, String>((ref, userId) async {
  final getAttendanceHistory = ref.watch(getAttendanceHistoryProvider);
  return await getAttendanceHistory(userId);
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
      // Set active session
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
      final submit = ref.read(submitAttendanceProvider);
      await submit(AttendanceEntity(
        userId: user.id,
        courseId: courseId,
        date: DateTime.now(),
        status: status,
      ));
      ref.invalidate(attendanceHistoryProvider(user.id));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final attendanceNotifierProvider = NotifierProvider<AttendanceNotifier, AttendanceState>(() {
  return AttendanceNotifier();
});
