// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's JellyBot notification preferences; null when JellyBot is not configured, unreachable, or
/// does not know this account's server (401).

@ProviderFor(JellybotNotificationPreferences)
final jellybotNotificationPreferencesProvider = JellybotNotificationPreferencesProvider._();

/// The signed-in user's JellyBot notification preferences; null when JellyBot is not configured, unreachable, or
/// does not know this account's server (401).
final class JellybotNotificationPreferencesProvider
    extends $AsyncNotifierProvider<JellybotNotificationPreferences, NotificationPreferencesDto?> {
  /// The signed-in user's JellyBot notification preferences; null when JellyBot is not configured, unreachable, or
  /// does not know this account's server (401).
  JellybotNotificationPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotNotificationPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotNotificationPreferencesHash();

  @$internal
  @override
  JellybotNotificationPreferences create() => JellybotNotificationPreferences();
}

String _$jellybotNotificationPreferencesHash() => r'a4fe09edbfc0e5c82b0fa55a7fc399fcacd97304';

/// The signed-in user's JellyBot notification preferences; null when JellyBot is not configured, unreachable, or
/// does not know this account's server (401).

abstract class _$JellybotNotificationPreferences extends $AsyncNotifier<NotificationPreferencesDto?> {
  FutureOr<NotificationPreferencesDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NotificationPreferencesDto?>, NotificationPreferencesDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationPreferencesDto?>, NotificationPreferencesDto?>,
              AsyncValue<NotificationPreferencesDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
/// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
///
/// Kept alive so the synchronous show context menu can read a value fetched earlier.

@ProviderFor(JellybotSeriesSubscription)
final jellybotSeriesSubscriptionProvider = JellybotSeriesSubscriptionFamily._();

/// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
/// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
///
/// Kept alive so the synchronous show context menu can read a value fetched earlier.
final class JellybotSeriesSubscriptionProvider
    extends $AsyncNotifierProvider<JellybotSeriesSubscription, SeriesSubscriptionDto?> {
  /// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
  /// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
  ///
  /// Kept alive so the synchronous show context menu can read a value fetched earlier.
  JellybotSeriesSubscriptionProvider._({
    required JellybotSeriesSubscriptionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'jellybotSeriesSubscriptionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$jellybotSeriesSubscriptionHash();

  @override
  String toString() {
    return r'jellybotSeriesSubscriptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JellybotSeriesSubscription create() => JellybotSeriesSubscription();

  @override
  bool operator ==(Object other) {
    return other is JellybotSeriesSubscriptionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jellybotSeriesSubscriptionHash() => r'858a94e5ac36a8cbc1608fce4cf7e2b0dc852e36';

/// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
/// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
///
/// Kept alive so the synchronous show context menu can read a value fetched earlier.

final class JellybotSeriesSubscriptionFamily extends $Family
    with
        $ClassFamilyOverride<
          JellybotSeriesSubscription,
          AsyncValue<SeriesSubscriptionDto?>,
          SeriesSubscriptionDto?,
          FutureOr<SeriesSubscriptionDto?>,
          String
        > {
  JellybotSeriesSubscriptionFamily._()
    : super(
        retry: null,
        name: r'jellybotSeriesSubscriptionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
  /// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
  ///
  /// Kept alive so the synchronous show context menu can read a value fetched earlier.

  JellybotSeriesSubscriptionProvider call(String seriesId) =>
      JellybotSeriesSubscriptionProvider._(argument: seriesId, from: this);

  @override
  String toString() => r'jellybotSeriesSubscriptionProvider';
}

/// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
/// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
///
/// Kept alive so the synchronous show context menu can read a value fetched earlier.

abstract class _$JellybotSeriesSubscription extends $AsyncNotifier<SeriesSubscriptionDto?> {
  late final _$args = ref.$arg as String;
  String get seriesId => _$args;

  FutureOr<SeriesSubscriptionDto?> build(String seriesId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SeriesSubscriptionDto?>, SeriesSubscriptionDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SeriesSubscriptionDto?>, SeriesSubscriptionDto?>,
              AsyncValue<SeriesSubscriptionDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// How many JellyBot events the signed-in user hasn't read, from the newest history page (so it caps at a page).
/// Drives the JellyBot tab dot and the menu count. Refreshes whenever a check publishes to [notificationsProvider]
/// (app open, desktop timer, the Workmanager port) and after marking read. No system-notification gate, so it
/// works on web.

@ProviderFor(JellybotUnreadNotifications)
final jellybotUnreadNotificationsProvider = JellybotUnreadNotificationsProvider._();

/// How many JellyBot events the signed-in user hasn't read, from the newest history page (so it caps at a page).
/// Drives the JellyBot tab dot and the menu count. Refreshes whenever a check publishes to [notificationsProvider]
/// (app open, desktop timer, the Workmanager port) and after marking read. No system-notification gate, so it
/// works on web.
final class JellybotUnreadNotificationsProvider extends $AsyncNotifierProvider<JellybotUnreadNotifications, int?> {
  /// How many JellyBot events the signed-in user hasn't read, from the newest history page (so it caps at a page).
  /// Drives the JellyBot tab dot and the menu count. Refreshes whenever a check publishes to [notificationsProvider]
  /// (app open, desktop timer, the Workmanager port) and after marking read. No system-notification gate, so it
  /// works on web.
  JellybotUnreadNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotUnreadNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotUnreadNotificationsHash();

  @$internal
  @override
  JellybotUnreadNotifications create() => JellybotUnreadNotifications();
}

String _$jellybotUnreadNotificationsHash() => r'af79b658808957f74d95a4891f589e8257a29bca';

/// How many JellyBot events the signed-in user hasn't read, from the newest history page (so it caps at a page).
/// Drives the JellyBot tab dot and the menu count. Refreshes whenever a check publishes to [notificationsProvider]
/// (app open, desktop timer, the Workmanager port) and after marking read. No system-notification gate, so it
/// works on web.

abstract class _$JellybotUnreadNotifications extends $AsyncNotifier<int?> {
  FutureOr<int?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<AsyncValue<int?>, int?>, AsyncValue<int?>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// The in-app notification list, paged by id. Opening it marks everything shown as read.

@ProviderFor(JellybotNotificationHistory)
final jellybotNotificationHistoryProvider = JellybotNotificationHistoryProvider._();

/// The in-app notification list, paged by id. Opening it marks everything shown as read.
final class JellybotNotificationHistoryProvider
    extends $AsyncNotifierProvider<JellybotNotificationHistory, JellybotHistoryState> {
  /// The in-app notification list, paged by id. Opening it marks everything shown as read.
  JellybotNotificationHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotNotificationHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotNotificationHistoryHash();

  @$internal
  @override
  JellybotNotificationHistory create() => JellybotNotificationHistory();
}

String _$jellybotNotificationHistoryHash() => r'8e79c53b7d291ae53e1432d3911c55c596a94d9c';

/// The in-app notification list, paged by id. Opening it marks everything shown as read.

abstract class _$JellybotNotificationHistory extends $AsyncNotifier<JellybotHistoryState> {
  FutureOr<JellybotHistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<JellybotHistoryState>, JellybotHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<JellybotHistoryState>, JellybotHistoryState>,
              AsyncValue<JellybotHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
