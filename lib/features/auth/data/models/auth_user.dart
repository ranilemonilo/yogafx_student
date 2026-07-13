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
    @JsonKey(name: 'upgrade_options')
    @Default(<UpgradeOption>[])
    List<UpgradeOption> upgradeOptions,
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

@freezed
class UpgradeOption with _$UpgradeOption {
  const factory UpgradeOption({
    required int id,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'currency_code') String? currencyCode,
    required int level,
    required num price,
    @JsonKey(name: 'upgrade_url') required String upgradeUrl,
  }) = _UpgradeOption;

  factory UpgradeOption.fromJson(Map<String, dynamic> json) =>
      _$UpgradeOptionFromJson(json);
}
