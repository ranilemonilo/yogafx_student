// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return _AuthUser.fromJson(json);
}

/// @nodoc
mixin _$AuthUser {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_tier')
  AccessTier? get accessTier => throw _privateConstructorUsedError;
  @JsonKey(name: 'upgrade_options')
  List<UpgradeOption> get upgradeOptions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthUserCopyWith<AuthUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthUserCopyWith<$Res> {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) then) =
      _$AuthUserCopyWithImpl<$Res, AuthUser>;
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      String? avatar,
      @JsonKey(name: 'access_tier') AccessTier? accessTier,
      @JsonKey(name: 'upgrade_options') List<UpgradeOption> upgradeOptions});

  $AccessTierCopyWith<$Res>? get accessTier;
}

/// @nodoc
class _$AuthUserCopyWithImpl<$Res, $Val extends AuthUser>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatar = freezed,
    Object? accessTier = freezed,
    Object? upgradeOptions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      accessTier: freezed == accessTier
          ? _value.accessTier
          : accessTier // ignore: cast_nullable_to_non_nullable
              as AccessTier?,
      upgradeOptions: null == upgradeOptions
          ? _value.upgradeOptions
          : upgradeOptions // ignore: cast_nullable_to_non_nullable
              as List<UpgradeOption>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccessTierCopyWith<$Res>? get accessTier {
    if (_value.accessTier == null) {
      return null;
    }

    return $AccessTierCopyWith<$Res>(_value.accessTier!, (value) {
      return _then(_value.copyWith(accessTier: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthUserImplCopyWith<$Res>
    implements $AuthUserCopyWith<$Res> {
  factory _$$AuthUserImplCopyWith(
          _$AuthUserImpl value, $Res Function(_$AuthUserImpl) then) =
      __$$AuthUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      String? avatar,
      @JsonKey(name: 'access_tier') AccessTier? accessTier,
      @JsonKey(name: 'upgrade_options') List<UpgradeOption> upgradeOptions});

  @override
  $AccessTierCopyWith<$Res>? get accessTier;
}

/// @nodoc
class __$$AuthUserImplCopyWithImpl<$Res>
    extends _$AuthUserCopyWithImpl<$Res, _$AuthUserImpl>
    implements _$$AuthUserImplCopyWith<$Res> {
  __$$AuthUserImplCopyWithImpl(
      _$AuthUserImpl _value, $Res Function(_$AuthUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatar = freezed,
    Object? accessTier = freezed,
    Object? upgradeOptions = null,
  }) {
    return _then(_$AuthUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      accessTier: freezed == accessTier
          ? _value.accessTier
          : accessTier // ignore: cast_nullable_to_non_nullable
              as AccessTier?,
      upgradeOptions: null == upgradeOptions
          ? _value._upgradeOptions
          : upgradeOptions // ignore: cast_nullable_to_non_nullable
              as List<UpgradeOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthUserImpl implements _AuthUser {
  const _$AuthUserImpl(
      {required this.id,
      required this.name,
      required this.email,
      this.avatar,
      @JsonKey(name: 'access_tier') this.accessTier,
      @JsonKey(name: 'upgrade_options')
      final List<UpgradeOption> upgradeOptions = const <UpgradeOption>[]})
      : _upgradeOptions = upgradeOptions;

  factory _$AuthUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthUserImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String? avatar;
  @override
  @JsonKey(name: 'access_tier')
  final AccessTier? accessTier;
  final List<UpgradeOption> _upgradeOptions;
  @override
  @JsonKey(name: 'upgrade_options')
  List<UpgradeOption> get upgradeOptions {
    if (_upgradeOptions is EqualUnmodifiableListView) return _upgradeOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upgradeOptions);
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, name: $name, email: $email, avatar: $avatar, accessTier: $accessTier, upgradeOptions: $upgradeOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.accessTier, accessTier) ||
                other.accessTier == accessTier) &&
            const DeepCollectionEquality()
                .equals(other._upgradeOptions, _upgradeOptions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, avatar,
      accessTier, const DeepCollectionEquality().hash(_upgradeOptions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      __$$AuthUserImplCopyWithImpl<_$AuthUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthUserImplToJson(
      this,
    );
  }
}

abstract class _AuthUser implements AuthUser {
  const factory _AuthUser(
      {required final int id,
      required final String name,
      required final String email,
      final String? avatar,
      @JsonKey(name: 'access_tier') final AccessTier? accessTier,
      @JsonKey(name: 'upgrade_options')
      final List<UpgradeOption> upgradeOptions}) = _$AuthUserImpl;

  factory _AuthUser.fromJson(Map<String, dynamic> json) =
      _$AuthUserImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String? get avatar;
  @override
  @JsonKey(name: 'access_tier')
  AccessTier? get accessTier;
  @override
  @JsonKey(name: 'upgrade_options')
  List<UpgradeOption> get upgradeOptions;
  @override
  @JsonKey(ignore: true)
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccessTier _$AccessTierFromJson(Map<String, dynamic> json) {
  return _AccessTier.fromJson(json);
}

/// @nodoc
mixin _$AccessTier {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccessTierCopyWith<AccessTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccessTierCopyWith<$Res> {
  factory $AccessTierCopyWith(
          AccessTier value, $Res Function(AccessTier) then) =
      _$AccessTierCopyWithImpl<$Res, AccessTier>;
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class _$AccessTierCopyWithImpl<$Res, $Val extends AccessTier>
    implements $AccessTierCopyWith<$Res> {
  _$AccessTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccessTierImplCopyWith<$Res>
    implements $AccessTierCopyWith<$Res> {
  factory _$$AccessTierImplCopyWith(
          _$AccessTierImpl value, $Res Function(_$AccessTierImpl) then) =
      __$$AccessTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class __$$AccessTierImplCopyWithImpl<$Res>
    extends _$AccessTierCopyWithImpl<$Res, _$AccessTierImpl>
    implements _$$AccessTierImplCopyWith<$Res> {
  __$$AccessTierImplCopyWithImpl(
      _$AccessTierImpl _value, $Res Function(_$AccessTierImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_$AccessTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccessTierImpl implements _AccessTier {
  const _$AccessTierImpl(
      {required this.id, required this.name, required this.slug});

  factory _$AccessTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccessTierImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;

  @override
  String toString() {
    return 'AccessTier(id: $id, name: $name, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccessTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccessTierImplCopyWith<_$AccessTierImpl> get copyWith =>
      __$$AccessTierImplCopyWithImpl<_$AccessTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccessTierImplToJson(
      this,
    );
  }
}

abstract class _AccessTier implements AccessTier {
  const factory _AccessTier(
      {required final int id,
      required final String name,
      required final String slug}) = _$AccessTierImpl;

  factory _AccessTier.fromJson(Map<String, dynamic> json) =
      _$AccessTierImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  @JsonKey(ignore: true)
  _$$AccessTierImplCopyWith<_$AccessTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpgradeOption _$UpgradeOptionFromJson(Map<String, dynamic> json) {
  return _UpgradeOption.fromJson(json);
}

/// @nodoc
mixin _$UpgradeOption {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency_code')
  String? get currencyCode => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  num get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'upgrade_url')
  String get upgradeUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpgradeOptionCopyWith<UpgradeOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpgradeOptionCopyWith<$Res> {
  factory $UpgradeOptionCopyWith(
          UpgradeOption value, $Res Function(UpgradeOption) then) =
      _$UpgradeOptionCopyWithImpl<$Res, UpgradeOption>;
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      @JsonKey(name: 'currency_code') String? currencyCode,
      int level,
      num price,
      @JsonKey(name: 'upgrade_url') String upgradeUrl});
}

/// @nodoc
class _$UpgradeOptionCopyWithImpl<$Res, $Val extends UpgradeOption>
    implements $UpgradeOptionCopyWith<$Res> {
  _$UpgradeOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? currencyCode = freezed,
    Object? level = null,
    Object? price = null,
    Object? upgradeUrl = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num,
      upgradeUrl: null == upgradeUrl
          ? _value.upgradeUrl
          : upgradeUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpgradeOptionImplCopyWith<$Res>
    implements $UpgradeOptionCopyWith<$Res> {
  factory _$$UpgradeOptionImplCopyWith(
          _$UpgradeOptionImpl value, $Res Function(_$UpgradeOptionImpl) then) =
      __$$UpgradeOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      @JsonKey(name: 'currency_code') String? currencyCode,
      int level,
      num price,
      @JsonKey(name: 'upgrade_url') String upgradeUrl});
}

/// @nodoc
class __$$UpgradeOptionImplCopyWithImpl<$Res>
    extends _$UpgradeOptionCopyWithImpl<$Res, _$UpgradeOptionImpl>
    implements _$$UpgradeOptionImplCopyWith<$Res> {
  __$$UpgradeOptionImplCopyWithImpl(
      _$UpgradeOptionImpl _value, $Res Function(_$UpgradeOptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? currencyCode = freezed,
    Object? level = null,
    Object? price = null,
    Object? upgradeUrl = null,
  }) {
    return _then(_$UpgradeOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num,
      upgradeUrl: null == upgradeUrl
          ? _value.upgradeUrl
          : upgradeUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpgradeOptionImpl implements _UpgradeOption {
  const _$UpgradeOptionImpl(
      {required this.id,
      required this.name,
      required this.slug,
      this.description,
      @JsonKey(name: 'currency_code') this.currencyCode,
      required this.level,
      required this.price,
      @JsonKey(name: 'upgrade_url') required this.upgradeUrl});

  factory _$UpgradeOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpgradeOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? description;
  @override
  @JsonKey(name: 'currency_code')
  final String? currencyCode;
  @override
  final int level;
  @override
  final num price;
  @override
  @JsonKey(name: 'upgrade_url')
  final String upgradeUrl;

  @override
  String toString() {
    return 'UpgradeOption(id: $id, name: $name, slug: $slug, description: $description, currencyCode: $currencyCode, level: $level, price: $price, upgradeUrl: $upgradeUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpgradeOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.upgradeUrl, upgradeUrl) ||
                other.upgradeUrl == upgradeUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug, description,
      currencyCode, level, price, upgradeUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpgradeOptionImplCopyWith<_$UpgradeOptionImpl> get copyWith =>
      __$$UpgradeOptionImplCopyWithImpl<_$UpgradeOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpgradeOptionImplToJson(
      this,
    );
  }
}

abstract class _UpgradeOption implements UpgradeOption {
  const factory _UpgradeOption(
          {required final int id,
          required final String name,
          required final String slug,
          final String? description,
          @JsonKey(name: 'currency_code') final String? currencyCode,
          required final int level,
          required final num price,
          @JsonKey(name: 'upgrade_url') required final String upgradeUrl}) =
      _$UpgradeOptionImpl;

  factory _UpgradeOption.fromJson(Map<String, dynamic> json) =
      _$UpgradeOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get description;
  @override
  @JsonKey(name: 'currency_code')
  String? get currencyCode;
  @override
  int get level;
  @override
  num get price;
  @override
  @JsonKey(name: 'upgrade_url')
  String get upgradeUrl;
  @override
  @JsonKey(ignore: true)
  _$$UpgradeOptionImplCopyWith<_$UpgradeOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
