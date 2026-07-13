// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthUserImpl _$$AuthUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      accessTier: json['access_tier'] == null
          ? null
          : AccessTier.fromJson(json['access_tier'] as Map<String, dynamic>),
      upgradeOptions: (json['upgrade_options'] as List<dynamic>?)
              ?.map((e) => UpgradeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <UpgradeOption>[],
    );

Map<String, dynamic> _$$AuthUserImplToJson(_$AuthUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatar': instance.avatar,
      'access_tier': instance.accessTier,
      'upgrade_options': instance.upgradeOptions,
    };

_$AccessTierImpl _$$AccessTierImplFromJson(Map<String, dynamic> json) =>
    _$AccessTierImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$$AccessTierImplToJson(_$AccessTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

_$UpgradeOptionImpl _$$UpgradeOptionImplFromJson(Map<String, dynamic> json) =>
    _$UpgradeOptionImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      currencyCode: json['currency_code'] as String?,
      level: (json['level'] as num).toInt(),
      price: json['price'] as num,
      upgradeUrl: json['upgrade_url'] as String,
    );

Map<String, dynamic> _$$UpgradeOptionImplToJson(_$UpgradeOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'currency_code': instance.currencyCode,
      'level': instance.level,
      'price': instance.price,
      'upgrade_url': instance.upgradeUrl,
    };
