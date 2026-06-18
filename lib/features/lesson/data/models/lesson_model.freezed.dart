// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LessonVideo _$LessonVideoFromJson(Map<String, dynamic> json) {
  return _LessonVideo.fromJson(json);
}

/// @nodoc
mixin _$LessonVideo {
  @JsonKey(name: 'video_id')
  String get videoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'hls_url')
  String get hlsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_ready')
  bool get isReady => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_configured')
  bool get isConfigured => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonVideoCopyWith<LessonVideo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonVideoCopyWith<$Res> {
  factory $LessonVideoCopyWith(
          LessonVideo value, $Res Function(LessonVideo) then) =
      _$LessonVideoCopyWithImpl<$Res, LessonVideo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'video_id') String videoId,
      @JsonKey(name: 'hls_url') String hlsUrl,
      @JsonKey(name: 'is_ready') bool isReady,
      @JsonKey(name: 'is_configured') bool isConfigured});
}

/// @nodoc
class _$LessonVideoCopyWithImpl<$Res, $Val extends LessonVideo>
    implements $LessonVideoCopyWith<$Res> {
  _$LessonVideoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? hlsUrl = null,
    Object? isReady = null,
    Object? isConfigured = null,
  }) {
    return _then(_value.copyWith(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      hlsUrl: null == hlsUrl
          ? _value.hlsUrl
          : hlsUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfigured: null == isConfigured
          ? _value.isConfigured
          : isConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonVideoImplCopyWith<$Res>
    implements $LessonVideoCopyWith<$Res> {
  factory _$$LessonVideoImplCopyWith(
          _$LessonVideoImpl value, $Res Function(_$LessonVideoImpl) then) =
      __$$LessonVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'video_id') String videoId,
      @JsonKey(name: 'hls_url') String hlsUrl,
      @JsonKey(name: 'is_ready') bool isReady,
      @JsonKey(name: 'is_configured') bool isConfigured});
}

/// @nodoc
class __$$LessonVideoImplCopyWithImpl<$Res>
    extends _$LessonVideoCopyWithImpl<$Res, _$LessonVideoImpl>
    implements _$$LessonVideoImplCopyWith<$Res> {
  __$$LessonVideoImplCopyWithImpl(
      _$LessonVideoImpl _value, $Res Function(_$LessonVideoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? hlsUrl = null,
    Object? isReady = null,
    Object? isConfigured = null,
  }) {
    return _then(_$LessonVideoImpl(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      hlsUrl: null == hlsUrl
          ? _value.hlsUrl
          : hlsUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfigured: null == isConfigured
          ? _value.isConfigured
          : isConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonVideoImpl implements _LessonVideo {
  const _$LessonVideoImpl(
      {@JsonKey(name: 'video_id') required this.videoId,
      @JsonKey(name: 'hls_url') required this.hlsUrl,
      @JsonKey(name: 'is_ready') required this.isReady,
      @JsonKey(name: 'is_configured') required this.isConfigured});

  factory _$LessonVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonVideoImplFromJson(json);

  @override
  @JsonKey(name: 'video_id')
  final String videoId;
  @override
  @JsonKey(name: 'hls_url')
  final String hlsUrl;
  @override
  @JsonKey(name: 'is_ready')
  final bool isReady;
  @override
  @JsonKey(name: 'is_configured')
  final bool isConfigured;

  @override
  String toString() {
    return 'LessonVideo(videoId: $videoId, hlsUrl: $hlsUrl, isReady: $isReady, isConfigured: $isConfigured)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonVideoImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.hlsUrl, hlsUrl) || other.hlsUrl == hlsUrl) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.isConfigured, isConfigured) ||
                other.isConfigured == isConfigured));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, videoId, hlsUrl, isReady, isConfigured);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonVideoImplCopyWith<_$LessonVideoImpl> get copyWith =>
      __$$LessonVideoImplCopyWithImpl<_$LessonVideoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonVideoImplToJson(
      this,
    );
  }
}

abstract class _LessonVideo implements LessonVideo {
  const factory _LessonVideo(
          {@JsonKey(name: 'video_id') required final String videoId,
          @JsonKey(name: 'hls_url') required final String hlsUrl,
          @JsonKey(name: 'is_ready') required final bool isReady,
          @JsonKey(name: 'is_configured') required final bool isConfigured}) =
      _$LessonVideoImpl;

  factory _LessonVideo.fromJson(Map<String, dynamic> json) =
      _$LessonVideoImpl.fromJson;

  @override
  @JsonKey(name: 'video_id')
  String get videoId;
  @override
  @JsonKey(name: 'hls_url')
  String get hlsUrl;
  @override
  @JsonKey(name: 'is_ready')
  bool get isReady;
  @override
  @JsonKey(name: 'is_configured')
  bool get isConfigured;
  @override
  @JsonKey(ignore: true)
  _$$LessonVideoImplCopyWith<_$LessonVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonAudio _$LessonAudioFromJson(Map<String, dynamic> json) {
  return _LessonAudio.fromJson(json);
}

/// @nodoc
mixin _$LessonAudio {
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonAudioCopyWith<LessonAudio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonAudioCopyWith<$Res> {
  factory $LessonAudioCopyWith(
          LessonAudio value, $Res Function(LessonAudio) then) =
      _$LessonAudioCopyWithImpl<$Res, LessonAudio>;
  @useResult
  $Res call({String? url, @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class _$LessonAudioCopyWithImpl<$Res, $Val extends LessonAudio>
    implements $LessonAudioCopyWith<$Res> {
  _$LessonAudioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_value.copyWith(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonAudioImplCopyWith<$Res>
    implements $LessonAudioCopyWith<$Res> {
  factory _$$LessonAudioImplCopyWith(
          _$LessonAudioImpl value, $Res Function(_$LessonAudioImpl) then) =
      __$$LessonAudioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? url, @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class __$$LessonAudioImplCopyWithImpl<$Res>
    extends _$LessonAudioCopyWithImpl<$Res, _$LessonAudioImpl>
    implements _$$LessonAudioImplCopyWith<$Res> {
  __$$LessonAudioImplCopyWithImpl(
      _$LessonAudioImpl _value, $Res Function(_$LessonAudioImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_$LessonAudioImpl(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonAudioImpl implements _LessonAudio {
  const _$LessonAudioImpl(
      {this.url, @JsonKey(name: 'is_available') required this.isAvailable});

  factory _$LessonAudioImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonAudioImplFromJson(json);

  @override
  final String? url;
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  @override
  String toString() {
    return 'LessonAudio(url: $url, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonAudioImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, isAvailable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonAudioImplCopyWith<_$LessonAudioImpl> get copyWith =>
      __$$LessonAudioImplCopyWithImpl<_$LessonAudioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonAudioImplToJson(
      this,
    );
  }
}

abstract class _LessonAudio implements LessonAudio {
  const factory _LessonAudio(
          {final String? url,
          @JsonKey(name: 'is_available') required final bool isAvailable}) =
      _$LessonAudioImpl;

  factory _LessonAudio.fromJson(Map<String, dynamic> json) =
      _$LessonAudioImpl.fromJson;

  @override
  String? get url;
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;
  @override
  @JsonKey(ignore: true)
  _$$LessonAudioImplCopyWith<_$LessonAudioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonWorkbook _$LessonWorkbookFromJson(Map<String, dynamic> json) {
  return _LessonWorkbook.fromJson(json);
}

/// @nodoc
mixin _$LessonWorkbook {
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_url')
  String? get downloadUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_name')
  String? get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonWorkbookCopyWith<LessonWorkbook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonWorkbookCopyWith<$Res> {
  factory $LessonWorkbookCopyWith(
          LessonWorkbook value, $Res Function(LessonWorkbook) then) =
      _$LessonWorkbookCopyWithImpl<$Res, LessonWorkbook>;
  @useResult
  $Res call(
      {String? url,
      @JsonKey(name: 'download_url') String? downloadUrl,
      @JsonKey(name: 'file_name') String? fileName,
      @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class _$LessonWorkbookCopyWithImpl<$Res, $Val extends LessonWorkbook>
    implements $LessonWorkbookCopyWith<$Res> {
  _$LessonWorkbookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_value.copyWith(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonWorkbookImplCopyWith<$Res>
    implements $LessonWorkbookCopyWith<$Res> {
  factory _$$LessonWorkbookImplCopyWith(_$LessonWorkbookImpl value,
          $Res Function(_$LessonWorkbookImpl) then) =
      __$$LessonWorkbookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? url,
      @JsonKey(name: 'download_url') String? downloadUrl,
      @JsonKey(name: 'file_name') String? fileName,
      @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class __$$LessonWorkbookImplCopyWithImpl<$Res>
    extends _$LessonWorkbookCopyWithImpl<$Res, _$LessonWorkbookImpl>
    implements _$$LessonWorkbookImplCopyWith<$Res> {
  __$$LessonWorkbookImplCopyWithImpl(
      _$LessonWorkbookImpl _value, $Res Function(_$LessonWorkbookImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_$LessonWorkbookImpl(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonWorkbookImpl implements _LessonWorkbook {
  const _$LessonWorkbookImpl(
      {this.url,
      @JsonKey(name: 'download_url') this.downloadUrl,
      @JsonKey(name: 'file_name') this.fileName,
      @JsonKey(name: 'is_available') required this.isAvailable});

  factory _$LessonWorkbookImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonWorkbookImplFromJson(json);

  @override
  final String? url;
  @override
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @override
  @JsonKey(name: 'file_name')
  final String? fileName;
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  @override
  String toString() {
    return 'LessonWorkbook(url: $url, downloadUrl: $downloadUrl, fileName: $fileName, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonWorkbookImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, url, downloadUrl, fileName, isAvailable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonWorkbookImplCopyWith<_$LessonWorkbookImpl> get copyWith =>
      __$$LessonWorkbookImplCopyWithImpl<_$LessonWorkbookImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonWorkbookImplToJson(
      this,
    );
  }
}

abstract class _LessonWorkbook implements LessonWorkbook {
  const factory _LessonWorkbook(
          {final String? url,
          @JsonKey(name: 'download_url') final String? downloadUrl,
          @JsonKey(name: 'file_name') final String? fileName,
          @JsonKey(name: 'is_available') required final bool isAvailable}) =
      _$LessonWorkbookImpl;

  factory _LessonWorkbook.fromJson(Map<String, dynamic> json) =
      _$LessonWorkbookImpl.fromJson;

  @override
  String? get url;
  @override
  @JsonKey(name: 'download_url')
  String? get downloadUrl;
  @override
  @JsonKey(name: 'file_name')
  String? get fileName;
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;
  @override
  @JsonKey(ignore: true)
  _$$LessonWorkbookImplCopyWith<_$LessonWorkbookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonProgress _$LessonProgressFromJson(Map<String, dynamic> json) {
  return _LessonProgress.fromJson(json);
}

/// @nodoc
mixin _$LessonProgress {
  @JsonKey(name: 'watch_progress')
  int get watchProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_workbook_downloaded')
  bool get isWorkbookDownloaded => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_done')
  bool get isDone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonProgressCopyWith<LessonProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonProgressCopyWith<$Res> {
  factory $LessonProgressCopyWith(
          LessonProgress value, $Res Function(LessonProgress) then) =
      _$LessonProgressCopyWithImpl<$Res, LessonProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'watch_progress') int watchProgress,
      @JsonKey(name: 'is_workbook_downloaded') bool isWorkbookDownloaded,
      @JsonKey(name: 'is_done') bool isDone});
}

/// @nodoc
class _$LessonProgressCopyWithImpl<$Res, $Val extends LessonProgress>
    implements $LessonProgressCopyWith<$Res> {
  _$LessonProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchProgress = null,
    Object? isWorkbookDownloaded = null,
    Object? isDone = null,
  }) {
    return _then(_value.copyWith(
      watchProgress: null == watchProgress
          ? _value.watchProgress
          : watchProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isWorkbookDownloaded: null == isWorkbookDownloaded
          ? _value.isWorkbookDownloaded
          : isWorkbookDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      isDone: null == isDone
          ? _value.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonProgressImplCopyWith<$Res>
    implements $LessonProgressCopyWith<$Res> {
  factory _$$LessonProgressImplCopyWith(_$LessonProgressImpl value,
          $Res Function(_$LessonProgressImpl) then) =
      __$$LessonProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'watch_progress') int watchProgress,
      @JsonKey(name: 'is_workbook_downloaded') bool isWorkbookDownloaded,
      @JsonKey(name: 'is_done') bool isDone});
}

/// @nodoc
class __$$LessonProgressImplCopyWithImpl<$Res>
    extends _$LessonProgressCopyWithImpl<$Res, _$LessonProgressImpl>
    implements _$$LessonProgressImplCopyWith<$Res> {
  __$$LessonProgressImplCopyWithImpl(
      _$LessonProgressImpl _value, $Res Function(_$LessonProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchProgress = null,
    Object? isWorkbookDownloaded = null,
    Object? isDone = null,
  }) {
    return _then(_$LessonProgressImpl(
      watchProgress: null == watchProgress
          ? _value.watchProgress
          : watchProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isWorkbookDownloaded: null == isWorkbookDownloaded
          ? _value.isWorkbookDownloaded
          : isWorkbookDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      isDone: null == isDone
          ? _value.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonProgressImpl implements _LessonProgress {
  const _$LessonProgressImpl(
      {@JsonKey(name: 'watch_progress') required this.watchProgress,
      @JsonKey(name: 'is_workbook_downloaded')
      required this.isWorkbookDownloaded,
      @JsonKey(name: 'is_done') required this.isDone});

  factory _$LessonProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonProgressImplFromJson(json);

  @override
  @JsonKey(name: 'watch_progress')
  final int watchProgress;
  @override
  @JsonKey(name: 'is_workbook_downloaded')
  final bool isWorkbookDownloaded;
  @override
  @JsonKey(name: 'is_done')
  final bool isDone;

  @override
  String toString() {
    return 'LessonProgress(watchProgress: $watchProgress, isWorkbookDownloaded: $isWorkbookDownloaded, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonProgressImpl &&
            (identical(other.watchProgress, watchProgress) ||
                other.watchProgress == watchProgress) &&
            (identical(other.isWorkbookDownloaded, isWorkbookDownloaded) ||
                other.isWorkbookDownloaded == isWorkbookDownloaded) &&
            (identical(other.isDone, isDone) || other.isDone == isDone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, watchProgress, isWorkbookDownloaded, isDone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      __$$LessonProgressImplCopyWithImpl<_$LessonProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonProgressImplToJson(
      this,
    );
  }
}

abstract class _LessonProgress implements LessonProgress {
  const factory _LessonProgress(
          {@JsonKey(name: 'watch_progress') required final int watchProgress,
          @JsonKey(name: 'is_workbook_downloaded')
          required final bool isWorkbookDownloaded,
          @JsonKey(name: 'is_done') required final bool isDone}) =
      _$LessonProgressImpl;

  factory _LessonProgress.fromJson(Map<String, dynamic> json) =
      _$LessonProgressImpl.fromJson;

  @override
  @JsonKey(name: 'watch_progress')
  int get watchProgress;
  @override
  @JsonKey(name: 'is_workbook_downloaded')
  bool get isWorkbookDownloaded;
  @override
  @JsonKey(name: 'is_done')
  bool get isDone;
  @override
  @JsonKey(ignore: true)
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonModule _$LessonModuleFromJson(Map<String, dynamic> json) {
  return _LessonModule.fromJson(json);
}

/// @nodoc
mixin _$LessonModule {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_count')
  int get lessonCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_lessons')
  int get completedLessons => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonModuleCopyWith<LessonModule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonModuleCopyWith<$Res> {
  factory $LessonModuleCopyWith(
          LessonModule value, $Res Function(LessonModule) then) =
      _$LessonModuleCopyWithImpl<$Res, LessonModule>;
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage});
}

/// @nodoc
class _$LessonModuleCopyWithImpl<$Res, $Val extends LessonModule>
    implements $LessonModuleCopyWith<$Res> {
  _$LessonModuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? lessonCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonModuleImplCopyWith<$Res>
    implements $LessonModuleCopyWith<$Res> {
  factory _$$LessonModuleImplCopyWith(
          _$LessonModuleImpl value, $Res Function(_$LessonModuleImpl) then) =
      __$$LessonModuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      @JsonKey(name: 'lesson_count') int lessonCount,
      @JsonKey(name: 'completed_lessons') int completedLessons,
      @JsonKey(name: 'progress_percentage') int progressPercentage});
}

/// @nodoc
class __$$LessonModuleImplCopyWithImpl<$Res>
    extends _$LessonModuleCopyWithImpl<$Res, _$LessonModuleImpl>
    implements _$$LessonModuleImplCopyWith<$Res> {
  __$$LessonModuleImplCopyWithImpl(
      _$LessonModuleImpl _value, $Res Function(_$LessonModuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? lessonCount = null,
    Object? completedLessons = null,
    Object? progressPercentage = null,
  }) {
    return _then(_$LessonModuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonModuleImpl implements _LessonModule {
  const _$LessonModuleImpl(
      {required this.id,
      required this.title,
      required this.slug,
      @JsonKey(name: 'lesson_count') required this.lessonCount,
      @JsonKey(name: 'completed_lessons') required this.completedLessons,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage});

  factory _$LessonModuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonModuleImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  @JsonKey(name: 'lesson_count')
  final int lessonCount;
  @override
  @JsonKey(name: 'completed_lessons')
  final int completedLessons;
  @override
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;

  @override
  String toString() {
    return 'LessonModule(id: $id, title: $title, slug: $slug, lessonCount: $lessonCount, completedLessons: $completedLessons, progressPercentage: $progressPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonModuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.lessonCount, lessonCount) ||
                other.lessonCount == lessonCount) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, slug, lessonCount,
      completedLessons, progressPercentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonModuleImplCopyWith<_$LessonModuleImpl> get copyWith =>
      __$$LessonModuleImplCopyWithImpl<_$LessonModuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonModuleImplToJson(
      this,
    );
  }
}

abstract class _LessonModule implements LessonModule {
  const factory _LessonModule(
      {required final int id,
      required final String title,
      required final String slug,
      @JsonKey(name: 'lesson_count') required final int lessonCount,
      @JsonKey(name: 'completed_lessons') required final int completedLessons,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage}) = _$LessonModuleImpl;

  factory _LessonModule.fromJson(Map<String, dynamic> json) =
      _$LessonModuleImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  @JsonKey(name: 'lesson_count')
  int get lessonCount;
  @override
  @JsonKey(name: 'completed_lessons')
  int get completedLessons;
  @override
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage;
  @override
  @JsonKey(ignore: true)
  _$$LessonModuleImplCopyWith<_$LessonModuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonNavItem _$LessonNavItemFromJson(Map<String, dynamic> json) {
  return _LessonNavItem.fromJson(json);
}

/// @nodoc
mixin _$LessonNavItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_locked')
  bool get isLocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'lock_reason')
  String? get lockReason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonNavItemCopyWith<LessonNavItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonNavItemCopyWith<$Res> {
  factory $LessonNavItemCopyWith(
          LessonNavItem value, $Res Function(LessonNavItem) then) =
      _$LessonNavItemCopyWithImpl<$Res, LessonNavItem>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      String status,
      @JsonKey(name: 'progress_percentage') int progressPercentage});
}

/// @nodoc
class _$LessonNavItemCopyWithImpl<$Res, $Val extends LessonNavItem>
    implements $LessonNavItemCopyWith<$Res> {
  _$LessonNavItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
    Object? thumbnailUrl = freezed,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? status = null,
    Object? progressPercentage = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonNavItemImplCopyWith<$Res>
    implements $LessonNavItemCopyWith<$Res> {
  factory _$$LessonNavItemImplCopyWith(
          _$LessonNavItemImpl value, $Res Function(_$LessonNavItemImpl) then) =
      __$$LessonNavItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      String status,
      @JsonKey(name: 'progress_percentage') int progressPercentage});
}

/// @nodoc
class __$$LessonNavItemImplCopyWithImpl<$Res>
    extends _$LessonNavItemCopyWithImpl<$Res, _$LessonNavItemImpl>
    implements _$$LessonNavItemImplCopyWith<$Res> {
  __$$LessonNavItemImplCopyWithImpl(
      _$LessonNavItemImpl _value, $Res Function(_$LessonNavItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
    Object? thumbnailUrl = freezed,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? status = null,
    Object? progressPercentage = null,
  }) {
    return _then(_$LessonNavItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonNavItemImpl implements _LessonNavItem {
  const _$LessonNavItemImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'sort_order') required this.sortOrder,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      @JsonKey(name: 'is_locked') required this.isLocked,
      @JsonKey(name: 'lock_reason') this.lockReason,
      required this.status,
      @JsonKey(name: 'progress_percentage') required this.progressPercentage});

  factory _$LessonNavItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonNavItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'is_locked')
  final bool isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  final String? lockReason;
  @override
  final String status;
  @override
  @JsonKey(name: 'progress_percentage')
  final int progressPercentage;

  @override
  String toString() {
    return 'LessonNavItem(id: $id, title: $title, sortOrder: $sortOrder, thumbnailUrl: $thumbnailUrl, isLocked: $isLocked, lockReason: $lockReason, status: $status, progressPercentage: $progressPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonNavItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.lockReason, lockReason) ||
                other.lockReason == lockReason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, sortOrder,
      thumbnailUrl, isLocked, lockReason, status, progressPercentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonNavItemImplCopyWith<_$LessonNavItemImpl> get copyWith =>
      __$$LessonNavItemImplCopyWithImpl<_$LessonNavItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonNavItemImplToJson(
      this,
    );
  }
}

abstract class _LessonNavItem implements LessonNavItem {
  const factory _LessonNavItem(
      {required final int id,
      required final String title,
      @JsonKey(name: 'sort_order') required final int sortOrder,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      @JsonKey(name: 'is_locked') required final bool isLocked,
      @JsonKey(name: 'lock_reason') final String? lockReason,
      required final String status,
      @JsonKey(name: 'progress_percentage')
      required final int progressPercentage}) = _$LessonNavItemImpl;

  factory _LessonNavItem.fromJson(Map<String, dynamic> json) =
      _$LessonNavItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'is_locked')
  bool get isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  String? get lockReason;
  @override
  String get status;
  @override
  @JsonKey(name: 'progress_percentage')
  int get progressPercentage;
  @override
  @JsonKey(ignore: true)
  _$$LessonNavItemImplCopyWith<_$LessonNavItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NextLesson _$NextLessonFromJson(Map<String, dynamic> json) {
  return _NextLesson.fromJson(json);
}

/// @nodoc
mixin _$NextLesson {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'lock_reason')
  String? get lockReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NextLessonCopyWith<NextLesson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NextLessonCopyWith<$Res> {
  factory $NextLessonCopyWith(
          NextLesson value, $Res Function(NextLesson) then) =
      _$NextLessonCopyWithImpl<$Res, NextLesson>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'lock_reason') String? lockReason});
}

/// @nodoc
class _$NextLessonCopyWithImpl<$Res, $Val extends NextLesson>
    implements $NextLessonCopyWith<$Res> {
  _$NextLessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
    Object? thumbnailUrl = freezed,
    Object? isUnlocked = null,
    Object? lockReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NextLessonImplCopyWith<$Res>
    implements $NextLessonCopyWith<$Res> {
  factory _$$NextLessonImplCopyWith(
          _$NextLessonImpl value, $Res Function(_$NextLessonImpl) then) =
      __$$NextLessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'lock_reason') String? lockReason});
}

/// @nodoc
class __$$NextLessonImplCopyWithImpl<$Res>
    extends _$NextLessonCopyWithImpl<$Res, _$NextLessonImpl>
    implements _$$NextLessonImplCopyWith<$Res> {
  __$$NextLessonImplCopyWithImpl(
      _$NextLessonImpl _value, $Res Function(_$NextLessonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
    Object? thumbnailUrl = freezed,
    Object? isUnlocked = null,
    Object? lockReason = freezed,
  }) {
    return _then(_$NextLessonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NextLessonImpl implements _NextLesson {
  const _$NextLessonImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'sort_order') required this.sortOrder,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      @JsonKey(name: 'is_unlocked') required this.isUnlocked,
      @JsonKey(name: 'lock_reason') this.lockReason});

  factory _$NextLessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$NextLessonImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @override
  @JsonKey(name: 'lock_reason')
  final String? lockReason;

  @override
  String toString() {
    return 'NextLesson(id: $id, title: $title, sortOrder: $sortOrder, thumbnailUrl: $thumbnailUrl, isUnlocked: $isUnlocked, lockReason: $lockReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NextLessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.lockReason, lockReason) ||
                other.lockReason == lockReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, sortOrder, thumbnailUrl, isUnlocked, lockReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NextLessonImplCopyWith<_$NextLessonImpl> get copyWith =>
      __$$NextLessonImplCopyWithImpl<_$NextLessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NextLessonImplToJson(
      this,
    );
  }
}

abstract class _NextLesson implements NextLesson {
  const factory _NextLesson(
          {required final int id,
          required final String title,
          @JsonKey(name: 'sort_order') required final int sortOrder,
          @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
          @JsonKey(name: 'is_unlocked') required final bool isUnlocked,
          @JsonKey(name: 'lock_reason') final String? lockReason}) =
      _$NextLessonImpl;

  factory _NextLesson.fromJson(Map<String, dynamic> json) =
      _$NextLessonImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked;
  @override
  @JsonKey(name: 'lock_reason')
  String? get lockReason;
  @override
  @JsonKey(ignore: true)
  _$$NextLessonImplCopyWith<_$NextLessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonDetail _$LessonDetailFromJson(Map<String, dynamic> json) {
  return _LessonDetail.fromJson(json);
}

/// @nodoc
mixin _$LessonDetail {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_locked')
  bool get isLocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'lock_reason')
  String? get lockReason => throw _privateConstructorUsedError;
  LessonVideo? get video => throw _privateConstructorUsedError;
  LessonAudio get audio => throw _privateConstructorUsedError;
  LessonWorkbook get workbook => throw _privateConstructorUsedError;
  LessonProgress get progress => throw _privateConstructorUsedError;
  LessonModule get module => throw _privateConstructorUsedError;
  Map<String, dynamic>? get assessment => throw _privateConstructorUsedError;
  List<LessonNavItem> get navigation => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_lesson')
  NextLesson? get nextLesson => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonDetailCopyWith<LessonDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonDetailCopyWith<$Res> {
  factory $LessonDetailCopyWith(
          LessonDetail value, $Res Function(LessonDetail) then) =
      _$LessonDetailCopyWithImpl<$Res, LessonDetail>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? content,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      LessonVideo? video,
      LessonAudio audio,
      LessonWorkbook workbook,
      LessonProgress progress,
      LessonModule module,
      Map<String, dynamic>? assessment,
      List<LessonNavItem> navigation,
      @JsonKey(name: 'next_lesson') NextLesson? nextLesson});

  $LessonVideoCopyWith<$Res>? get video;
  $LessonAudioCopyWith<$Res> get audio;
  $LessonWorkbookCopyWith<$Res> get workbook;
  $LessonProgressCopyWith<$Res> get progress;
  $LessonModuleCopyWith<$Res> get module;
  $NextLessonCopyWith<$Res>? get nextLesson;
}

/// @nodoc
class _$LessonDetailCopyWithImpl<$Res, $Val extends LessonDetail>
    implements $LessonDetailCopyWith<$Res> {
  _$LessonDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = freezed,
    Object? thumbnailUrl = freezed,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? video = freezed,
    Object? audio = null,
    Object? workbook = null,
    Object? progress = null,
    Object? module = null,
    Object? assessment = freezed,
    Object? navigation = null,
    Object? nextLesson = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as LessonVideo?,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as LessonAudio,
      workbook: null == workbook
          ? _value.workbook
          : workbook // ignore: cast_nullable_to_non_nullable
              as LessonWorkbook,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as LessonProgress,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as LessonModule,
      assessment: freezed == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      navigation: null == navigation
          ? _value.navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as List<LessonNavItem>,
      nextLesson: freezed == nextLesson
          ? _value.nextLesson
          : nextLesson // ignore: cast_nullable_to_non_nullable
              as NextLesson?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonVideoCopyWith<$Res>? get video {
    if (_value.video == null) {
      return null;
    }

    return $LessonVideoCopyWith<$Res>(_value.video!, (value) {
      return _then(_value.copyWith(video: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonAudioCopyWith<$Res> get audio {
    return $LessonAudioCopyWith<$Res>(_value.audio, (value) {
      return _then(_value.copyWith(audio: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonWorkbookCopyWith<$Res> get workbook {
    return $LessonWorkbookCopyWith<$Res>(_value.workbook, (value) {
      return _then(_value.copyWith(workbook: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonProgressCopyWith<$Res> get progress {
    return $LessonProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonModuleCopyWith<$Res> get module {
    return $LessonModuleCopyWith<$Res>(_value.module, (value) {
      return _then(_value.copyWith(module: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NextLessonCopyWith<$Res>? get nextLesson {
    if (_value.nextLesson == null) {
      return null;
    }

    return $NextLessonCopyWith<$Res>(_value.nextLesson!, (value) {
      return _then(_value.copyWith(nextLesson: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LessonDetailImplCopyWith<$Res>
    implements $LessonDetailCopyWith<$Res> {
  factory _$$LessonDetailImplCopyWith(
          _$LessonDetailImpl value, $Res Function(_$LessonDetailImpl) then) =
      __$$LessonDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? content,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'is_locked') bool isLocked,
      @JsonKey(name: 'lock_reason') String? lockReason,
      LessonVideo? video,
      LessonAudio audio,
      LessonWorkbook workbook,
      LessonProgress progress,
      LessonModule module,
      Map<String, dynamic>? assessment,
      List<LessonNavItem> navigation,
      @JsonKey(name: 'next_lesson') NextLesson? nextLesson});

  @override
  $LessonVideoCopyWith<$Res>? get video;
  @override
  $LessonAudioCopyWith<$Res> get audio;
  @override
  $LessonWorkbookCopyWith<$Res> get workbook;
  @override
  $LessonProgressCopyWith<$Res> get progress;
  @override
  $LessonModuleCopyWith<$Res> get module;
  @override
  $NextLessonCopyWith<$Res>? get nextLesson;
}

/// @nodoc
class __$$LessonDetailImplCopyWithImpl<$Res>
    extends _$LessonDetailCopyWithImpl<$Res, _$LessonDetailImpl>
    implements _$$LessonDetailImplCopyWith<$Res> {
  __$$LessonDetailImplCopyWithImpl(
      _$LessonDetailImpl _value, $Res Function(_$LessonDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = freezed,
    Object? thumbnailUrl = freezed,
    Object? isLocked = null,
    Object? lockReason = freezed,
    Object? video = freezed,
    Object? audio = null,
    Object? workbook = null,
    Object? progress = null,
    Object? module = null,
    Object? assessment = freezed,
    Object? navigation = null,
    Object? nextLesson = freezed,
  }) {
    return _then(_$LessonDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lockReason: freezed == lockReason
          ? _value.lockReason
          : lockReason // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as LessonVideo?,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as LessonAudio,
      workbook: null == workbook
          ? _value.workbook
          : workbook // ignore: cast_nullable_to_non_nullable
              as LessonWorkbook,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as LessonProgress,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as LessonModule,
      assessment: freezed == assessment
          ? _value._assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      navigation: null == navigation
          ? _value._navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as List<LessonNavItem>,
      nextLesson: freezed == nextLesson
          ? _value.nextLesson
          : nextLesson // ignore: cast_nullable_to_non_nullable
              as NextLesson?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonDetailImpl implements _LessonDetail {
  const _$LessonDetailImpl(
      {required this.id,
      required this.title,
      this.content,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      @JsonKey(name: 'is_locked') required this.isLocked,
      @JsonKey(name: 'lock_reason') this.lockReason,
      this.video,
      required this.audio,
      required this.workbook,
      required this.progress,
      required this.module,
      final Map<String, dynamic>? assessment,
      required final List<LessonNavItem> navigation,
      @JsonKey(name: 'next_lesson') this.nextLesson})
      : _assessment = assessment,
        _navigation = navigation;

  factory _$LessonDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? content;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'is_locked')
  final bool isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  final String? lockReason;
  @override
  final LessonVideo? video;
  @override
  final LessonAudio audio;
  @override
  final LessonWorkbook workbook;
  @override
  final LessonProgress progress;
  @override
  final LessonModule module;
  final Map<String, dynamic>? _assessment;
  @override
  Map<String, dynamic>? get assessment {
    final value = _assessment;
    if (value == null) return null;
    if (_assessment is EqualUnmodifiableMapView) return _assessment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<LessonNavItem> _navigation;
  @override
  List<LessonNavItem> get navigation {
    if (_navigation is EqualUnmodifiableListView) return _navigation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_navigation);
  }

  @override
  @JsonKey(name: 'next_lesson')
  final NextLesson? nextLesson;

  @override
  String toString() {
    return 'LessonDetail(id: $id, title: $title, content: $content, thumbnailUrl: $thumbnailUrl, isLocked: $isLocked, lockReason: $lockReason, video: $video, audio: $audio, workbook: $workbook, progress: $progress, module: $module, assessment: $assessment, navigation: $navigation, nextLesson: $nextLesson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.lockReason, lockReason) ||
                other.lockReason == lockReason) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.workbook, workbook) ||
                other.workbook == workbook) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.module, module) || other.module == module) &&
            const DeepCollectionEquality()
                .equals(other._assessment, _assessment) &&
            const DeepCollectionEquality()
                .equals(other._navigation, _navigation) &&
            (identical(other.nextLesson, nextLesson) ||
                other.nextLesson == nextLesson));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      content,
      thumbnailUrl,
      isLocked,
      lockReason,
      video,
      audio,
      workbook,
      progress,
      module,
      const DeepCollectionEquality().hash(_assessment),
      const DeepCollectionEquality().hash(_navigation),
      nextLesson);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonDetailImplCopyWith<_$LessonDetailImpl> get copyWith =>
      __$$LessonDetailImplCopyWithImpl<_$LessonDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonDetailImplToJson(
      this,
    );
  }
}

abstract class _LessonDetail implements LessonDetail {
  const factory _LessonDetail(
          {required final int id,
          required final String title,
          final String? content,
          @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
          @JsonKey(name: 'is_locked') required final bool isLocked,
          @JsonKey(name: 'lock_reason') final String? lockReason,
          final LessonVideo? video,
          required final LessonAudio audio,
          required final LessonWorkbook workbook,
          required final LessonProgress progress,
          required final LessonModule module,
          final Map<String, dynamic>? assessment,
          required final List<LessonNavItem> navigation,
          @JsonKey(name: 'next_lesson') final NextLesson? nextLesson}) =
      _$LessonDetailImpl;

  factory _LessonDetail.fromJson(Map<String, dynamic> json) =
      _$LessonDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get content;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'is_locked')
  bool get isLocked;
  @override
  @JsonKey(name: 'lock_reason')
  String? get lockReason;
  @override
  LessonVideo? get video;
  @override
  LessonAudio get audio;
  @override
  LessonWorkbook get workbook;
  @override
  LessonProgress get progress;
  @override
  LessonModule get module;
  @override
  Map<String, dynamic>? get assessment;
  @override
  List<LessonNavItem> get navigation;
  @override
  @JsonKey(name: 'next_lesson')
  NextLesson? get nextLesson;
  @override
  @JsonKey(ignore: true)
  _$$LessonDetailImplCopyWith<_$LessonDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
