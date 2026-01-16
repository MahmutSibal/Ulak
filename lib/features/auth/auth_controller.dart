import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/jwt.dart';
import '../../services/auth_api.dart';
import '../../services/auth_storage.dart';
import '../../models/auth_models.dart';
import '../../app/providers.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.accessToken,
    required this.userId,
    required this.mustChangePassword,
  });

  final bool isLoading;
  final String? accessToken;
  final String? userId;
  final bool mustChangePassword;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    String? accessToken,
    String? userId,
    bool? mustChangePassword,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  static const initial = AuthState(
    isLoading: true,
    accessToken: null,
    userId: null,
    mustChangePassword: false,
  );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return AuthState.initial;
  }

  AuthApi get _api => ref.read(authApiProvider);
  AuthStorage get _storage => ref.read(authStorageProvider);

  Future<void> _restore() async {
    final token = await _storage.getAccessToken();
    final mustChange = await _storage.getMustChangePassword();
    final uid = token == null ? null : jwtSubject(token);

    state = state.copyWith(
      isLoading: false,
      accessToken: token,
      userId: uid,
      mustChangePassword: mustChange,
    );
  }

  Future<String?> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final TokenResponse token = await _api.login(email: email, password: password);
      await _storage.saveLogin(
        accessToken: token.accessToken,
        mustChangePassword: token.mustChangePassword,
      );

      state = state.copyWith(
        isLoading: false,
        accessToken: token.accessToken,
        userId: jwtSubject(token.accessToken),
        mustChangePassword: token.mustChangePassword,
      );
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Giriş başarısız. Lütfen bilgileri kontrol edin.';
    }
  }

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirm,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Kayıt başarısız. E-posta kullanılıyor olabilir.';
    }
  }

  Future<ForgotPasswordQuestionResponse?> forgotQuestion(String email) async {
    try {
      return await _api.forgotQuestion(email: email);
    } catch (_) {
      return null;
    }
  }

  Future<ForgotPasswordResetResponse?> forgotReset({required String email, required String answer}) async {
    try {
      return await _api.forgotReset(email: email, securityAnswer: answer);
    } catch (_) {
      return null;
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirm,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _api.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: confirm,
      );
      await _storage.saveLogin(
        accessToken: state.accessToken ?? '',
        mustChangePassword: false,
      );
      state = state.copyWith(isLoading: false, mustChangePassword: false);
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return 'Şifre değiştirilemedi.';
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = AuthState.initial.copyWith(isLoading: false);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
