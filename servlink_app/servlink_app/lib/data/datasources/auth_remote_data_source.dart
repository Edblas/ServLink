import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {
    await _dio.post(
      '/api/auth/forgot-password',
      data: request.toJson(),
    );
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    await _dio.post(
      '/api/auth/reset-password',
      data: request.toJson(),
    );
  }
}
