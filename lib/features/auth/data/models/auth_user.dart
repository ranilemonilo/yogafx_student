import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    required String email,
    String? avatar,
    @JsonKey(name: 'access_tier') AccessTier? accessTier,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

@freezed
class AccessTier with _$AccessTier {
  const factory AccessTier({
    required int id,
    required String name,
    required String slug,
  }) = _AccessTier;

  factory AccessTier.fromJson(Map<String, dynamic> json) =>
      _$AccessTierFromJson(json);
}