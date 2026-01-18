import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/attendance_repository.dart';

class RegisterUser implements UseCase<UserEntity, RegisterParams> {
  final AttendanceRepository repository;

  RegisterUser(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
      studentId: params.studentId,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;
  final String role; // 'teacher' or 'student'
  final String? studentId;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.studentId,
  });
}
