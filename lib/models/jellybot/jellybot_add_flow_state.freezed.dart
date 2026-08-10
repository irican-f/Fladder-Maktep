// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jellybot_add_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JellybotAddFlowState {
  ProviderSearchItemDto get item;
  MediaCategory get category;
  AddFlowStep get step;
  String? get addToken;
  String? get originalUrl;
  int? get availableSeasons;
  int? get selectedSeason;
  CrawlLinkDto? get previewLink;
  MediaSearchResultDto? get existingMedia;
  String? get mediaTitle;
  AddFlowFailure? get failure;
  String? get failureDetail;
  bool get hasRetriedExpiredToken;

  /// Create a copy of JellybotAddFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JellybotAddFlowStateCopyWith<JellybotAddFlowState> get copyWith =>
      _$JellybotAddFlowStateCopyWithImpl<JellybotAddFlowState>(
          this as JellybotAddFlowState, _$identity);

  @override
  String toString() {
    return 'JellybotAddFlowState(item: $item, category: $category, step: $step, addToken: $addToken, originalUrl: $originalUrl, availableSeasons: $availableSeasons, selectedSeason: $selectedSeason, previewLink: $previewLink, existingMedia: $existingMedia, mediaTitle: $mediaTitle, failure: $failure, failureDetail: $failureDetail, hasRetriedExpiredToken: $hasRetriedExpiredToken)';
  }
}

/// @nodoc
abstract mixin class $JellybotAddFlowStateCopyWith<$Res> {
  factory $JellybotAddFlowStateCopyWith(JellybotAddFlowState value,
          $Res Function(JellybotAddFlowState) _then) =
      _$JellybotAddFlowStateCopyWithImpl;
  @useResult
  $Res call(
      {ProviderSearchItemDto item,
      MediaCategory category,
      AddFlowStep step,
      String? addToken,
      String? originalUrl,
      int? availableSeasons,
      int? selectedSeason,
      CrawlLinkDto? previewLink,
      MediaSearchResultDto? existingMedia,
      String? mediaTitle,
      AddFlowFailure? failure,
      String? failureDetail,
      bool hasRetriedExpiredToken});
}

/// @nodoc
class _$JellybotAddFlowStateCopyWithImpl<$Res>
    implements $JellybotAddFlowStateCopyWith<$Res> {
  _$JellybotAddFlowStateCopyWithImpl(this._self, this._then);

  final JellybotAddFlowState _self;
  final $Res Function(JellybotAddFlowState) _then;

  /// Create a copy of JellybotAddFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? category = null,
    Object? step = null,
    Object? addToken = freezed,
    Object? originalUrl = freezed,
    Object? availableSeasons = freezed,
    Object? selectedSeason = freezed,
    Object? previewLink = freezed,
    Object? existingMedia = freezed,
    Object? mediaTitle = freezed,
    Object? failure = freezed,
    Object? failureDetail = freezed,
    Object? hasRetriedExpiredToken = null,
  }) {
    return _then(_self.copyWith(
      item: null == item
          ? _self.item
          : item // ignore: cast_nullable_to_non_nullable
              as ProviderSearchItemDto,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as MediaCategory,
      step: null == step
          ? _self.step
          : step // ignore: cast_nullable_to_non_nullable
              as AddFlowStep,
      addToken: freezed == addToken
          ? _self.addToken
          : addToken // ignore: cast_nullable_to_non_nullable
              as String?,
      originalUrl: freezed == originalUrl
          ? _self.originalUrl
          : originalUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSeasons: freezed == availableSeasons
          ? _self.availableSeasons
          : availableSeasons // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedSeason: freezed == selectedSeason
          ? _self.selectedSeason
          : selectedSeason // ignore: cast_nullable_to_non_nullable
              as int?,
      previewLink: freezed == previewLink
          ? _self.previewLink
          : previewLink // ignore: cast_nullable_to_non_nullable
              as CrawlLinkDto?,
      existingMedia: freezed == existingMedia
          ? _self.existingMedia
          : existingMedia // ignore: cast_nullable_to_non_nullable
              as MediaSearchResultDto?,
      mediaTitle: freezed == mediaTitle
          ? _self.mediaTitle
          : mediaTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      failure: freezed == failure
          ? _self.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as AddFlowFailure?,
      failureDetail: freezed == failureDetail
          ? _self.failureDetail
          : failureDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      hasRetriedExpiredToken: null == hasRetriedExpiredToken
          ? _self.hasRetriedExpiredToken
          : hasRetriedExpiredToken // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [JellybotAddFlowState].
extension JellybotAddFlowStatePatterns on JellybotAddFlowState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_JellybotAddFlowState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_JellybotAddFlowState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_JellybotAddFlowState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            ProviderSearchItemDto item,
            MediaCategory category,
            AddFlowStep step,
            String? addToken,
            String? originalUrl,
            int? availableSeasons,
            int? selectedSeason,
            CrawlLinkDto? previewLink,
            MediaSearchResultDto? existingMedia,
            String? mediaTitle,
            AddFlowFailure? failure,
            String? failureDetail,
            bool hasRetriedExpiredToken)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState() when $default != null:
        return $default(
            _that.item,
            _that.category,
            _that.step,
            _that.addToken,
            _that.originalUrl,
            _that.availableSeasons,
            _that.selectedSeason,
            _that.previewLink,
            _that.existingMedia,
            _that.mediaTitle,
            _that.failure,
            _that.failureDetail,
            _that.hasRetriedExpiredToken);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            ProviderSearchItemDto item,
            MediaCategory category,
            AddFlowStep step,
            String? addToken,
            String? originalUrl,
            int? availableSeasons,
            int? selectedSeason,
            CrawlLinkDto? previewLink,
            MediaSearchResultDto? existingMedia,
            String? mediaTitle,
            AddFlowFailure? failure,
            String? failureDetail,
            bool hasRetriedExpiredToken)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState():
        return $default(
            _that.item,
            _that.category,
            _that.step,
            _that.addToken,
            _that.originalUrl,
            _that.availableSeasons,
            _that.selectedSeason,
            _that.previewLink,
            _that.existingMedia,
            _that.mediaTitle,
            _that.failure,
            _that.failureDetail,
            _that.hasRetriedExpiredToken);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            ProviderSearchItemDto item,
            MediaCategory category,
            AddFlowStep step,
            String? addToken,
            String? originalUrl,
            int? availableSeasons,
            int? selectedSeason,
            CrawlLinkDto? previewLink,
            MediaSearchResultDto? existingMedia,
            String? mediaTitle,
            AddFlowFailure? failure,
            String? failureDetail,
            bool hasRetriedExpiredToken)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JellybotAddFlowState() when $default != null:
        return $default(
            _that.item,
            _that.category,
            _that.step,
            _that.addToken,
            _that.originalUrl,
            _that.availableSeasons,
            _that.selectedSeason,
            _that.previewLink,
            _that.existingMedia,
            _that.mediaTitle,
            _that.failure,
            _that.failureDetail,
            _that.hasRetriedExpiredToken);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _JellybotAddFlowState implements JellybotAddFlowState {
  const _JellybotAddFlowState(
      {required this.item,
      required this.category,
      this.step = AddFlowStep.extracting,
      this.addToken,
      this.originalUrl,
      this.availableSeasons,
      this.selectedSeason,
      this.previewLink,
      this.existingMedia,
      this.mediaTitle,
      this.failure,
      this.failureDetail,
      this.hasRetriedExpiredToken = false});

  @override
  final ProviderSearchItemDto item;
  @override
  final MediaCategory category;
  @override
  @JsonKey()
  final AddFlowStep step;
  @override
  final String? addToken;
  @override
  final String? originalUrl;
  @override
  final int? availableSeasons;
  @override
  final int? selectedSeason;
  @override
  final CrawlLinkDto? previewLink;
  @override
  final MediaSearchResultDto? existingMedia;
  @override
  final String? mediaTitle;
  @override
  final AddFlowFailure? failure;
  @override
  final String? failureDetail;
  @override
  @JsonKey()
  final bool hasRetriedExpiredToken;

  /// Create a copy of JellybotAddFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JellybotAddFlowStateCopyWith<_JellybotAddFlowState> get copyWith =>
      __$JellybotAddFlowStateCopyWithImpl<_JellybotAddFlowState>(
          this, _$identity);

  @override
  String toString() {
    return 'JellybotAddFlowState(item: $item, category: $category, step: $step, addToken: $addToken, originalUrl: $originalUrl, availableSeasons: $availableSeasons, selectedSeason: $selectedSeason, previewLink: $previewLink, existingMedia: $existingMedia, mediaTitle: $mediaTitle, failure: $failure, failureDetail: $failureDetail, hasRetriedExpiredToken: $hasRetriedExpiredToken)';
  }
}

/// @nodoc
abstract mixin class _$JellybotAddFlowStateCopyWith<$Res>
    implements $JellybotAddFlowStateCopyWith<$Res> {
  factory _$JellybotAddFlowStateCopyWith(_JellybotAddFlowState value,
          $Res Function(_JellybotAddFlowState) _then) =
      __$JellybotAddFlowStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ProviderSearchItemDto item,
      MediaCategory category,
      AddFlowStep step,
      String? addToken,
      String? originalUrl,
      int? availableSeasons,
      int? selectedSeason,
      CrawlLinkDto? previewLink,
      MediaSearchResultDto? existingMedia,
      String? mediaTitle,
      AddFlowFailure? failure,
      String? failureDetail,
      bool hasRetriedExpiredToken});
}

/// @nodoc
class __$JellybotAddFlowStateCopyWithImpl<$Res>
    implements _$JellybotAddFlowStateCopyWith<$Res> {
  __$JellybotAddFlowStateCopyWithImpl(this._self, this._then);

  final _JellybotAddFlowState _self;
  final $Res Function(_JellybotAddFlowState) _then;

  /// Create a copy of JellybotAddFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? item = null,
    Object? category = null,
    Object? step = null,
    Object? addToken = freezed,
    Object? originalUrl = freezed,
    Object? availableSeasons = freezed,
    Object? selectedSeason = freezed,
    Object? previewLink = freezed,
    Object? existingMedia = freezed,
    Object? mediaTitle = freezed,
    Object? failure = freezed,
    Object? failureDetail = freezed,
    Object? hasRetriedExpiredToken = null,
  }) {
    return _then(_JellybotAddFlowState(
      item: null == item
          ? _self.item
          : item // ignore: cast_nullable_to_non_nullable
              as ProviderSearchItemDto,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as MediaCategory,
      step: null == step
          ? _self.step
          : step // ignore: cast_nullable_to_non_nullable
              as AddFlowStep,
      addToken: freezed == addToken
          ? _self.addToken
          : addToken // ignore: cast_nullable_to_non_nullable
              as String?,
      originalUrl: freezed == originalUrl
          ? _self.originalUrl
          : originalUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSeasons: freezed == availableSeasons
          ? _self.availableSeasons
          : availableSeasons // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedSeason: freezed == selectedSeason
          ? _self.selectedSeason
          : selectedSeason // ignore: cast_nullable_to_non_nullable
              as int?,
      previewLink: freezed == previewLink
          ? _self.previewLink
          : previewLink // ignore: cast_nullable_to_non_nullable
              as CrawlLinkDto?,
      existingMedia: freezed == existingMedia
          ? _self.existingMedia
          : existingMedia // ignore: cast_nullable_to_non_nullable
              as MediaSearchResultDto?,
      mediaTitle: freezed == mediaTitle
          ? _self.mediaTitle
          : mediaTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      failure: freezed == failure
          ? _self.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as AddFlowFailure?,
      failureDetail: freezed == failureDetail
          ? _self.failureDetail
          : failureDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      hasRetriedExpiredToken: null == hasRetriedExpiredToken
          ? _self.hasRetriedExpiredToken
          : hasRetriedExpiredToken // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
