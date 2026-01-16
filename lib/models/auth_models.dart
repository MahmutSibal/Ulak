class TokenResponse {
  TokenResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.mustChangePassword,
  });

  final String accessToken;
  final DateTime expiresAt;
  final bool mustChangePassword;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      mustChangePassword: (json['must_change_password'] as bool?) ?? false,
    );
  }
}

class ForgotPasswordQuestionResponse {
  ForgotPasswordQuestionResponse({required this.securityQuestion});
  final String securityQuestion;

  factory ForgotPasswordQuestionResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordQuestionResponse(
      securityQuestion: json['security_question'] as String,
    );
  }
}

class ForgotPasswordResetResponse {
  ForgotPasswordResetResponse({required this.newPassword});
  final String newPassword;

  factory ForgotPasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResetResponse(newPassword: json['new_password'] as String);
  }
}
