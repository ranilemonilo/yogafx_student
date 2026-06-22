class ResetPasswordLinkData {
  final String token;
  final String? email;

  const ResetPasswordLinkData({
    required this.token,
    required this.email,
  });
}
