import 'package:dio/dio.dart';

import '../models/auth_models.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirm,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    await _dio.post(
      '/api/auth/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'security_question': securityQuestion,
        'security_answer': securityAnswer,
      },
    );
  }

  Future<TokenResponse> login({required String email, required String password}) async {
    final res = await _dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return TokenResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ForgotPasswordQuestionResponse> forgotQuestion({required String email}) async {
    final res = await _dio.post(
      '/api/auth/forgot-password/question',
      data: {'email': email},
    );
    return ForgotPasswordQuestionResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ForgotPasswordResetResponse> forgotReset({required String email, required String securityAnswer}) async {
    final res = await _dio.post(
      '/api/auth/forgot-password/reset',
      data: {
        'email': email,
        'security_answer': securityAnswer,
      },
    );
    return ForgotPasswordResetResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    await _dio.post(
      '/api/auth/change-password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );
  }
}
