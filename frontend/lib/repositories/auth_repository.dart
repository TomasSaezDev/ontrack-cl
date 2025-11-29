import '../models/user_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> register(String nombreCompleto, String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<dynamic> getMarcador(int userId);
  Future<List<dynamic>> getMarcadores();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
    : _authService = authService ?? AuthService();

  @override
  Future<User> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result['success']) {
      return result['user'];
    } else {
      throw Exception(result['message'] ?? 'Error al iniciar sesión');
    }
  }

  @override
  Future<void> register(
    String nombreCompleto,
    String email,
    String password,
  ) async {
    final result = await _authService.register(nombreCompleto, email, password);
    if (!result['success']) {
      throw Exception(result['message'] ?? 'Error al registrar usuario');
    }
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  @override
  Future<dynamic> getMarcador(int userId) async {
    return await _authService.getMarcador(userId);
  }

  @override
  Future<List<dynamic>> getMarcadores() async {
    return await _authService.getMarcadores();
  }
}
