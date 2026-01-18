// This file is no longer used - replaced with attendance_mock_datasource.dart
// Keeping for reference only

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<List<CourseModel>> getCourses();
  Future<void> submitAttendance(AttendanceModel attendance);
  Future<List<AttendanceModel>> getAttendanceHistory(String userId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AttendanceRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<UserModel> login(String email, String password) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final doc = await firestore.collection('users').doc(userCredential.user!.uid).get();
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await firestore.collection('courses').get();
    return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> submitAttendance(AttendanceModel attendance) async {
    await firestore.collection('attendance').add(attendance.toFirestore());
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(String userId) async {
    final snapshot = await firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => AttendanceModel.fromFirestore(doc.data())).toList();
  }
}
*/
