import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_user.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'token_type') required String tokenType,
    required AuthUser user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}