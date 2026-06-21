class LoginOtpChallenge {
  final bool otpRequired;
  final String challengeToken;
  final String email;
  final DateTime? expiresAt;

  const LoginOtpChallenge({
    required this.otpRequired,
    required this.challengeToken,
    required this.email,
    required this.expiresAt,
  });

  factory LoginOtpChallenge.fromJson(Map<String, dynamic> json) {
    return LoginOtpChallenge(
      otpRequired: json['otp_required'] as bool? ?? false,
      challengeToken: json['challenge_token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.tryParse(json['expires_at'] as String),
    );
  }
}
