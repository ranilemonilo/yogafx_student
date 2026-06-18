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
      @JsonKey(name: 'access_tier') AccessTier? accessTier});

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
      @JsonKey(name: 'access_tier') AccessTier? accessTier});

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
      @JsonKey(name: 'access_tier') this.accessTier});

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

  @override
  String toString() {
    return 'AuthUser(id: $id, name: $name, email: $email, avatar: $avatar, accessTier: $accessTier)';
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
                other.accessTier == accessTier));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, avatar, accessTier);

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
          @JsonKey(name: 'access_tier') final AccessTier? accessTier}) =
      _$AuthUserImpl;

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
