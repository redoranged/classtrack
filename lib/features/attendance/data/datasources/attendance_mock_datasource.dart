import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';

// Mock static data
final _mockCourses = [
  CourseModel(
    id: '1',
    name: 'Advanced Data Structures',
    lecturer: 'Prof. Smith',
  ),
  CourseModel(
    id: '2',
    name: 'Web Development',
    lecturer: 'Prof. Johnson',
  ),
  CourseModel(
    id: '3',
    name: 'Machine Learning',
    lecturer: 'Prof. Williams',
  ),
  CourseModel(
    id: '4',
    name: 'Database Systems',
    lecturer: 'Prof. Brown',
  ),
];

final _mockAttendanceHistory = <AttendanceModel>[
  AttendanceModel(
    userId: 'mock-user-123',
    courseId: '1',
    date: DateTime.now().subtract(const Duration(days: 2)),
    status: 'present',
  ),
  AttendanceModel(
    userId: 'mock-user-123',
    courseId: '2',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: 'absent',
  ),
  AttendanceModel(
    userId: 'mock-user-123',
    courseId: '3',
    date: DateTime.now(),
    status: 'late',
  ),
];

abstract class AttendanceRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<List<CourseModel>> getCourses();
  Future<void> submitAttendance(AttendanceModel attendance);
  Future<List<AttendanceModel>> getAttendanceHistory(String userId);
}

/// Mock implementation - No Firebase required
class AttendanceMockDataSourceImpl implements AttendanceRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Accept any email/password for demo
    if (email.isNotEmpty && password.isNotEmpty) {
      return UserModel(
        id: 'mock-user-123',
        name: 'Demo Student',
        studentId: 'S001',
      );
    }
    
    throw Exception('Login failed: Please enter email and password');
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockCourses);
  }

  @override
  Future<void> submitAttendance(AttendanceModel attendance) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Add to mock history
    _mockAttendanceHistory.insert(0, attendance);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockAttendanceHistory
        .where((a) => a.userId == userId)
        .toList();
  }
}
