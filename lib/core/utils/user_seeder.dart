import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class untuk seed users di Supabase
/// Berguna untuk development dan testing
class UserSeeder {
  final SupabaseClient supabase;

  UserSeeder({required this.supabase});

  /// Test users untuk development
  static final testUsers = [
    {
      'email': 'budi@classtrack.dev',
      'password': 'BudiPass123!',
      'name': 'Budi Santoso',
      'student_id': '2021001'
    },
    {
      'email': 'siti@classtrack.dev',
      'password': 'SitiPass123!',
      'name': 'Siti Aminah',
      'student_id': '2021002'
    },
    {
      'email': 'ahmad@classtrack.dev',
      'password': 'AhmadPass123!',
      'name': 'Ahmad Wijaya',
      'student_id': '2021003'
    },
    {
      'email': 'dewi@classtrack.dev',
      'password': 'DewiPass123!',
      'name': 'Dewi Kusuma',
      'student_id': '2021004'
    },
    {
      'email': 'rini@classtrack.dev',
      'password': 'RiniPass123!',
      'name': 'Rini Setiawan',
      'student_id': '2021005'
    },
  ];

  /// Create all test users
  /// Returns list of created user IDs
  Future<List<String>> seedAllUsers() async {
    final createdUserIds = <String>[];

    for (var userData in testUsers) {
      try {
        final userId = await _createUser(userData);
        if (userId != null) {
          createdUserIds.add(userId);
          developer.log('✓ Created user: ${userData['name']}');
        }
      } catch (e) {
        developer.log('✗ Error creating ${userData['name']}: $e');
      }
    }

    return createdUserIds;
  }

  /// Create single user
  /// Returns user ID if successful, null otherwise
  Future<String?> _createUser(Map<String, dynamic> userData) async {
    try {
      final email = (userData['email'] as String?)?.trim();
      final password = userData['password'] as String?;

      if (email == null || email.isEmpty) {
        throw Exception('Email is empty');
      }
      if (password == null || password.isEmpty) {
        throw Exception('Password is empty');
      }

      // Basic email validation to avoid goTrue 400
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Email format invalid: $email');
      }

      // 1. Sign up user in auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final userId = response.user!.id;

      // 2. Insert user data to users table
      await supabase.from('users').insert({
        'id': userId,
        'name': userData['name'],
        'student_id': userData['student_id'],
      });

      return userId;
    } on AuthException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Create custom user
  Future<String?> createCustomUser({
    required String email,
    required String password,
    required String name,
    required String studentId,
  }) async {
    try {
      final cleanEmail = email.trim();
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        throw Exception('Email format invalid: $cleanEmail');
      }

      final response = await supabase.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final userId = response.user!.id;

      await supabase.from('users').insert({
        'id': userId,
        'name': name,
        'student_id': studentId,
      });

      return userId;
    } on AuthException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Enroll user to course
  Future<void> enrollUserToCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      await supabase.from('enrollments').insert({
        'user_id': userId,
        'course_id': courseId,
      });
    } catch (e) {
      throw Exception('Failed to enroll user: $e');
    }
  }

  /// Create attendance record
  Future<void> markAttendance({
    required String userId,
    required String courseId,
    required DateTime date,
    required String status, // 'present', 'absent', 'late', 'excused'
  }) async {
    try {
      await supabase.from('attendances').insert({
        'user_id': userId,
        'course_id': courseId,
        'date': date.toIso8601String(),
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  /// Get all courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await supabase.from('courses').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }

  /// Verify seeded data
  Future<Map<String, int>> verifySeededData() async {
    try {
      final usersCount =
          await supabase.from('users').select().then((data) => data.length);

      final enrollmentsCount =
          await supabase.from('enrollments').select().then((data) => data.length);

      final attendancesCount =
          await supabase.from('attendances').select().then((data) => data.length);

      return {
        'users': usersCount,
        'enrollments': enrollmentsCount,
        'attendances': attendancesCount,
      };
    } catch (e) {
      throw Exception('Failed to verify data: $e');
    }
  }

  /// Delete user (for cleanup)
  Future<void> deleteUser(String userId) async {
    try {
      // Delete from users table (auth.users will cascade delete)
      await supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Delete all test users (WARNING: Be careful with this!)
  Future<void> deleteAllTestUsers() async {
    try {
      for (var userData in testUsers) {
        final studentId = userData['student_id'];
        if (studentId is! String) continue;
        
        final users = await supabase
            .from('users')
            .select('id')
            .eq('student_id', studentId);

        if (users.isNotEmpty) {
          final userId = users[0]['id'];
          if (userId != null) {
            await deleteUser(userId);
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to delete test users: $e');
    }
  }
}

/// Example usage dalam widget:
/*
class UserSeederExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seed Users')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _seedUsers(context),
          child: Text('Create Test Users'),
        ),
      ),
    );
  }

  Future<void> _seedUsers(BuildContext context) async {
    final seeder = UserSeeder(supabase: Supabase.instance.client);
    
    try {
      final userIds = await seeder.seedAllUsers();
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created ${userIds.length} users'),
          backgroundColor: Colors.green,
        ),
      );

      // Verify
      final data = await seeder.verifySeededData();
      print('Users: ${data['users']}');
      print('Enrollments: ${data['enrollments']}');
      print('Attendances: ${data['attendances']}');
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
*/
