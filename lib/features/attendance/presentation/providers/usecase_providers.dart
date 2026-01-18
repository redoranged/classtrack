import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/submit_attendance.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>((ref) {
  return AttendanceRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
  );
});

final loginUserProvider = Provider((ref) => LoginUser(ref.watch(attendanceRepositoryProvider)));
final getCoursesProvider = Provider((ref) => GetCourses(ref.watch(attendanceRepositoryProvider)));
final submitAttendanceProvider = Provider((ref) => SubmitAttendance(ref.watch(attendanceRepositoryProvider)));
final getAttendanceHistoryProvider = Provider((ref) => GetAttendanceHistory(ref.watch(attendanceRepositoryProvider)));
