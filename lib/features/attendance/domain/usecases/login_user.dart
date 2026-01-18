import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/attendance_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AttendanceRepository repository;

  LoginUser(this.repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
