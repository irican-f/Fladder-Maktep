// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i42;
import 'package:collection/collection.dart' as _i49;
import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart' as _i48;
import 'package:fladder/models/item_base_model.dart' as _i44;
import 'package:fladder/models/items/item_shared_models.dart' as _i47;
import 'package:fladder/models/items/photo_queue_source.dart' as _i51;
import 'package:fladder/models/items/photos_model.dart' as _i50;
import 'package:fladder/models/library_search/library_search_options.dart'
    as _i46;
import 'package:fladder/models/seerr/seerr_dashboard_model.dart' as _i52;
import 'package:fladder/routes/nested_details_screen.dart' as _i13;
import 'package:fladder/screens/control_panel/control_active_tasks_page.dart'
    as _i3;
import 'package:fladder/screens/control_panel/control_dashboard_page.dart'
    as _i4;
import 'package:fladder/screens/control_panel/control_libraries_page.dart'
    as _i5;
import 'package:fladder/screens/control_panel/control_livetv_page.dart' as _i6;
import 'package:fladder/screens/control_panel/control_panel_screen.dart' as _i7;
import 'package:fladder/screens/control_panel/control_panel_selection_screen.dart'
    as _i8;
import 'package:fladder/screens/control_panel/control_server_page.dart' as _i9;
import 'package:fladder/screens/control_panel/control_user_edit_page.dart'
    as _i10;
import 'package:fladder/screens/control_panel/control_users_page.dart' as _i11;
import 'package:fladder/screens/dashboard/dashboard_screen.dart' as _i12;
import 'package:fladder/screens/favourites/favourites_screen.dart' as _i14;
import 'package:fladder/screens/home_screen.dart' as _i15;
import 'package:fladder/screens/jellybot/admin_page.dart' as _i16;
import 'package:fladder/screens/jellybot/api_clients_page.dart' as _i17;
import 'package:fladder/screens/jellybot/crawl_links_page.dart' as _i18;
import 'package:fladder/screens/jellybot/downloads_page.dart' as _i19;
import 'package:fladder/screens/jellybot/jellybot_screen.dart' as _i25;
import 'package:fladder/screens/jellybot/jellybot_selection_page.dart' as _i26;
import 'package:fladder/screens/jellybot/live_tv_source_page.dart' as _i21;
import 'package:fladder/screens/jellybot/notifications_page.dart' as _i22;
import 'package:fladder/screens/jellybot/provider_search_page.dart' as _i23;
import 'package:fladder/screens/jellybot/providers_page.dart' as _i24;
import 'package:fladder/screens/library/library_screen.dart' as _i27;
import 'package:fladder/screens/library_search/library_search_screen.dart'
    as _i28;
import 'package:fladder/screens/live_tv/live_tv_channels_screen.dart' as _i20;
import 'package:fladder/screens/live_tv/live_tv_screen.dart' as _i29;
import 'package:fladder/screens/login/lock_screen.dart' as _i30;
import 'package:fladder/screens/login/login_screen.dart' as _i31;
import 'package:fladder/screens/photo_viewer/photo_viewer_screen.dart' as _i32;
import 'package:fladder/screens/seerr/seerr_details_screen.dart' as _i35;
import 'package:fladder/screens/seerr/seerr_screen.dart' as _i36;
import 'package:fladder/screens/seerr/seerr_search_screen.dart' as _i37;
import 'package:fladder/screens/settings/about_settings_page.dart' as _i1;
import 'package:fladder/screens/settings/client_settings_page.dart' as _i2;
import 'package:fladder/screens/settings/player_settings_page.dart' as _i33;
import 'package:fladder/screens/settings/profile_settings_page.dart' as _i34;
import 'package:fladder/screens/settings/settings_screen.dart' as _i38;
import 'package:fladder/screens/settings/settings_selection_screen.dart'
    as _i39;
import 'package:fladder/screens/splash_screen.dart' as _i40;
import 'package:fladder/screens/syncing/synced_screen.dart' as _i41;
import 'package:fladder/seerr/seerr_models.dart' as _i53;
import 'package:flutter/foundation.dart' as _i45;
import 'package:material_ui/material_ui.dart' as _i43;

/// generated route for
/// [_i1.AboutSettingsPage]
class AboutSettingsRoute extends _i42.PageRouteInfo<void> {
  const AboutSettingsRoute({List<_i42.PageRouteInfo>? children})
    : super(AboutSettingsRoute.name, initialChildren: children);

  static const String name = 'AboutSettingsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutSettingsPage();
    },
  );
}

/// generated route for
/// [_i2.ClientSettingsPage]
class ClientSettingsRoute extends _i42.PageRouteInfo<void> {
  const ClientSettingsRoute({List<_i42.PageRouteInfo>? children})
    : super(ClientSettingsRoute.name, initialChildren: children);

  static const String name = 'ClientSettingsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i2.ClientSettingsPage();
    },
  );
}

/// generated route for
/// [_i3.ControlActiveTasksPage]
class ControlActiveTasksRoute extends _i42.PageRouteInfo<void> {
  const ControlActiveTasksRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlActiveTasksRoute.name, initialChildren: children);

  static const String name = 'ControlActiveTasksRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i3.ControlActiveTasksPage();
    },
  );
}

/// generated route for
/// [_i4.ControlDashboardPage]
class ControlDashboardRoute extends _i42.PageRouteInfo<void> {
  const ControlDashboardRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlDashboardRoute.name, initialChildren: children);

  static const String name = 'ControlDashboardRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i4.ControlDashboardPage();
    },
  );
}

/// generated route for
/// [_i5.ControlLibrariesPage]
class ControlLibrariesRoute extends _i42.PageRouteInfo<void> {
  const ControlLibrariesRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlLibrariesRoute.name, initialChildren: children);

  static const String name = 'ControlLibrariesRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i5.ControlLibrariesPage();
    },
  );
}

/// generated route for
/// [_i6.ControlLiveTvPage]
class ControlLiveTvRoute extends _i42.PageRouteInfo<void> {
  const ControlLiveTvRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlLiveTvRoute.name, initialChildren: children);

  static const String name = 'ControlLiveTvRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i6.ControlLiveTvPage();
    },
  );
}

/// generated route for
/// [_i7.ControlPanelScreen]
class ControlPanelRoute extends _i42.PageRouteInfo<void> {
  const ControlPanelRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlPanelRoute.name, initialChildren: children);

  static const String name = 'ControlPanelRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i7.ControlPanelScreen();
    },
  );
}

/// generated route for
/// [_i8.ControlPanelSelectionScreen]
class ControlPanelSelectionRoute extends _i42.PageRouteInfo<void> {
  const ControlPanelSelectionRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlPanelSelectionRoute.name, initialChildren: children);

  static const String name = 'ControlPanelSelectionRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i8.ControlPanelSelectionScreen();
    },
  );
}

/// generated route for
/// [_i9.ControlServerPage]
class ControlServerRoute extends _i42.PageRouteInfo<void> {
  const ControlServerRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlServerRoute.name, initialChildren: children);

  static const String name = 'ControlServerRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i9.ControlServerPage();
    },
  );
}

/// generated route for
/// [_i10.ControlUserEditPage]
class ControlUserEditRoute
    extends _i42.PageRouteInfo<ControlUserEditRouteArgs> {
  ControlUserEditRoute({
    String? userId,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         ControlUserEditRoute.name,
         args: ControlUserEditRouteArgs(userId: userId, key: key),
         rawQueryParams: {'userId': userId},
         initialChildren: children,
       );

  static const String name = 'ControlUserEditRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<ControlUserEditRouteArgs>(
        orElse: () =>
            ControlUserEditRouteArgs(userId: queryParams.optString('userId')),
      );
      return _i10.ControlUserEditPage(userId: args.userId, key: args.key);
    },
  );
}

class ControlUserEditRouteArgs {
  const ControlUserEditRouteArgs({this.userId, this.key});

  final String? userId;

  final _i43.Key? key;

  @override
  String toString() {
    return 'ControlUserEditRouteArgs{userId: $userId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ControlUserEditRouteArgs) return false;
    return userId == other.userId && key == other.key;
  }

  @override
  int get hashCode => userId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i11.ControlUsersPage]
class ControlUsersRoute extends _i42.PageRouteInfo<void> {
  const ControlUsersRoute({List<_i42.PageRouteInfo>? children})
    : super(ControlUsersRoute.name, initialChildren: children);

  static const String name = 'ControlUsersRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i11.ControlUsersPage();
    },
  );
}

/// generated route for
/// [_i12.DashboardScreen]
class DashboardRoute extends _i42.PageRouteInfo<void> {
  const DashboardRoute({List<_i42.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i12.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i13.DetailsScreen]
class DetailsRoute extends _i42.PageRouteInfo<DetailsRouteArgs> {
  DetailsRoute({
    String id = '',
    _i44.ItemBaseModel? item,
    Object? tag,
    _i45.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         DetailsRoute.name,
         args: DetailsRouteArgs(id: id, item: item, tag: tag, key: key),
         rawQueryParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'DetailsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<DetailsRouteArgs>(
        orElse: () => DetailsRouteArgs(id: queryParams.getString('id', '')),
      );
      return _i13.DetailsScreen(
        id: args.id,
        item: args.item,
        tag: args.tag,
        key: args.key,
      );
    },
  );
}

class DetailsRouteArgs {
  const DetailsRouteArgs({this.id = '', this.item, this.tag, this.key});

  final String id;

  final _i44.ItemBaseModel? item;

  final Object? tag;

  final _i45.Key? key;

  @override
  String toString() {
    return 'DetailsRouteArgs{id: $id, item: $item, tag: $tag, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailsRouteArgs) return false;
    return id == other.id &&
        item == other.item &&
        tag == other.tag &&
        key == other.key;
  }

  @override
  int get hashCode => id.hashCode ^ item.hashCode ^ tag.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i14.FavouritesScreen]
class FavouritesRoute extends _i42.PageRouteInfo<void> {
  const FavouritesRoute({List<_i42.PageRouteInfo>? children})
    : super(FavouritesRoute.name, initialChildren: children);

  static const String name = 'FavouritesRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i14.FavouritesScreen();
    },
  );
}

/// generated route for
/// [_i15.HomeScreen]
class HomeRoute extends _i42.PageRouteInfo<void> {
  const HomeRoute({List<_i42.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i15.HomeScreen();
    },
  );
}

/// generated route for
/// [_i16.JellybotAdminPage]
class JellybotAdminRoute extends _i42.PageRouteInfo<void> {
  const JellybotAdminRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotAdminRoute.name, initialChildren: children);

  static const String name = 'JellybotAdminRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i16.JellybotAdminPage();
    },
  );
}

/// generated route for
/// [_i17.JellybotApiClientsPage]
class JellybotApiClientsRoute extends _i42.PageRouteInfo<void> {
  const JellybotApiClientsRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotApiClientsRoute.name, initialChildren: children);

  static const String name = 'JellybotApiClientsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i17.JellybotApiClientsPage();
    },
  );
}

/// generated route for
/// [_i18.JellybotCrawlLinksPage]
class JellybotCrawlLinksRoute extends _i42.PageRouteInfo<void> {
  const JellybotCrawlLinksRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotCrawlLinksRoute.name, initialChildren: children);

  static const String name = 'JellybotCrawlLinksRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i18.JellybotCrawlLinksPage();
    },
  );
}

/// generated route for
/// [_i19.JellybotDownloadsPage]
class JellybotDownloadsRoute extends _i42.PageRouteInfo<void> {
  const JellybotDownloadsRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotDownloadsRoute.name, initialChildren: children);

  static const String name = 'JellybotDownloadsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i19.JellybotDownloadsPage();
    },
  );
}

/// generated route for
/// [_i20.JellybotLiveTvChannelsScreen]
class JellybotLiveTvChannelsRoute extends _i42.PageRouteInfo<void> {
  const JellybotLiveTvChannelsRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotLiveTvChannelsRoute.name, initialChildren: children);

  static const String name = 'JellybotLiveTvChannelsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i20.JellybotLiveTvChannelsScreen();
    },
  );
}

/// generated route for
/// [_i21.JellybotLiveTvSourcePage]
class JellybotLiveTvSourceRoute extends _i42.PageRouteInfo<void> {
  const JellybotLiveTvSourceRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotLiveTvSourceRoute.name, initialChildren: children);

  static const String name = 'JellybotLiveTvSourceRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i21.JellybotLiveTvSourcePage();
    },
  );
}

/// generated route for
/// [_i22.JellybotNotificationsPage]
class JellybotNotificationsRoute extends _i42.PageRouteInfo<void> {
  const JellybotNotificationsRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotNotificationsRoute.name, initialChildren: children);

  static const String name = 'JellybotNotificationsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i22.JellybotNotificationsPage();
    },
  );
}

/// generated route for
/// [_i23.JellybotProviderSearchPage]
class JellybotProviderSearchRoute extends _i42.PageRouteInfo<void> {
  const JellybotProviderSearchRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotProviderSearchRoute.name, initialChildren: children);

  static const String name = 'JellybotProviderSearchRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i23.JellybotProviderSearchPage();
    },
  );
}

/// generated route for
/// [_i24.JellybotProvidersPage]
class JellybotProvidersRoute extends _i42.PageRouteInfo<void> {
  const JellybotProvidersRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotProvidersRoute.name, initialChildren: children);

  static const String name = 'JellybotProvidersRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i24.JellybotProvidersPage();
    },
  );
}

/// generated route for
/// [_i25.JellybotScreen]
class JellybotRoute extends _i42.PageRouteInfo<void> {
  const JellybotRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotRoute.name, initialChildren: children);

  static const String name = 'JellybotRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i25.JellybotScreen();
    },
  );
}

/// generated route for
/// [_i26.JellybotSelectionPage]
class JellybotSelectionRoute extends _i42.PageRouteInfo<void> {
  const JellybotSelectionRoute({List<_i42.PageRouteInfo>? children})
    : super(JellybotSelectionRoute.name, initialChildren: children);

  static const String name = 'JellybotSelectionRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i26.JellybotSelectionPage();
    },
  );
}

/// generated route for
/// [_i27.LibraryScreen]
class LibraryRoute extends _i42.PageRouteInfo<void> {
  const LibraryRoute({List<_i42.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i27.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i28.LibrarySearchScreen]
class LibrarySearchRoute extends _i42.PageRouteInfo<LibrarySearchRouteArgs> {
  LibrarySearchRoute({
    String? query,
    List<String>? parentId,
    bool? favourites,
    _i46.SortingOrder? sortOrder,
    _i46.SortingOptions? sortingOptions,
    Map<_i44.FladderItemType, bool>? types,
    Map<String, bool>? genres,
    Map<_i47.Studio, bool>? studios,
    Map<_i48.ItemFilter, bool>? itemFilters,
    Map<String, bool>? tags,
    Map<int, bool>? years,
    bool? recursive,
    bool? isDefault,
    _i45.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         LibrarySearchRoute.name,
         args: LibrarySearchRouteArgs(
           query: query,
           parentId: parentId,
           favourites: favourites,
           sortOrder: sortOrder,
           sortingOptions: sortingOptions,
           types: types,
           genres: genres,
           studios: studios,
           itemFilters: itemFilters,
           tags: tags,
           years: years,
           recursive: recursive,
           isDefault: isDefault,
           key: key,
         ),
         rawQueryParams: {
           'query': query,
           'parentId': parentId,
           'favourites': favourites,
           'sortOrder': sortOrder,
           'sortOptions': sortingOptions,
           'itemTypes': types,
           'genres': genres,
           'studios': studios,
           'itemFilters': itemFilters,
           'tags': tags,
           'years': years,
           'recursive': recursive,
           'isDefault': isDefault,
         },
         initialChildren: children,
       );

  static const String name = 'LibrarySearchRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LibrarySearchRouteArgs>(
        orElse: () => LibrarySearchRouteArgs(
          query: queryParams.optString('query'),
          parentId: queryParams.optList('parentId'),
          favourites: queryParams.optBool('favourites'),
          sortOrder: queryParams.get('sortOrder'),
          sortingOptions: queryParams.get('sortOptions'),
          types: queryParams.get('itemTypes'),
          genres: queryParams.get('genres'),
          studios: queryParams.get('studios'),
          itemFilters: queryParams.get('itemFilters'),
          tags: queryParams.get('tags'),
          years: queryParams.get('years'),
          recursive: queryParams.optBool('recursive'),
          isDefault: queryParams.optBool('isDefault'),
        ),
      );
      return _i28.LibrarySearchScreen(
        query: args.query,
        parentId: args.parentId,
        favourites: args.favourites,
        sortOrder: args.sortOrder,
        sortingOptions: args.sortingOptions,
        types: args.types,
        genres: args.genres,
        studios: args.studios,
        itemFilters: args.itemFilters,
        tags: args.tags,
        years: args.years,
        recursive: args.recursive,
        isDefault: args.isDefault,
        key: args.key,
      );
    },
  );
}

class LibrarySearchRouteArgs {
  const LibrarySearchRouteArgs({
    this.query,
    this.parentId,
    this.favourites,
    this.sortOrder,
    this.sortingOptions,
    this.types,
    this.genres,
    this.studios,
    this.itemFilters,
    this.tags,
    this.years,
    this.recursive,
    this.isDefault,
    this.key,
  });

  final String? query;

  final List<String>? parentId;

  final bool? favourites;

  final _i46.SortingOrder? sortOrder;

  final _i46.SortingOptions? sortingOptions;

  final Map<_i44.FladderItemType, bool>? types;

  final Map<String, bool>? genres;

  final Map<_i47.Studio, bool>? studios;

  final Map<_i48.ItemFilter, bool>? itemFilters;

  final Map<String, bool>? tags;

  final Map<int, bool>? years;

  final bool? recursive;

  final bool? isDefault;

  final _i45.Key? key;

  @override
  String toString() {
    return 'LibrarySearchRouteArgs{query: $query, parentId: $parentId, favourites: $favourites, sortOrder: $sortOrder, sortingOptions: $sortingOptions, types: $types, genres: $genres, studios: $studios, itemFilters: $itemFilters, tags: $tags, years: $years, recursive: $recursive, isDefault: $isDefault, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LibrarySearchRouteArgs) return false;
    return query == other.query &&
        const _i49.ListEquality<String>().equals(parentId, other.parentId) &&
        favourites == other.favourites &&
        sortOrder == other.sortOrder &&
        sortingOptions == other.sortingOptions &&
        const _i49.MapEquality<_i44.FladderItemType, bool>().equals(
          types,
          other.types,
        ) &&
        const _i49.MapEquality<String, bool>().equals(genres, other.genres) &&
        const _i49.MapEquality<_i47.Studio, bool>().equals(
          studios,
          other.studios,
        ) &&
        const _i49.MapEquality<_i48.ItemFilter, bool>().equals(
          itemFilters,
          other.itemFilters,
        ) &&
        const _i49.MapEquality<String, bool>().equals(tags, other.tags) &&
        const _i49.MapEquality<int, bool>().equals(years, other.years) &&
        recursive == other.recursive &&
        isDefault == other.isDefault &&
        key == other.key;
  }

  @override
  int get hashCode =>
      query.hashCode ^
      const _i49.ListEquality<String>().hash(parentId) ^
      favourites.hashCode ^
      sortOrder.hashCode ^
      sortingOptions.hashCode ^
      const _i49.MapEquality<_i44.FladderItemType, bool>().hash(types) ^
      const _i49.MapEquality<String, bool>().hash(genres) ^
      const _i49.MapEquality<_i47.Studio, bool>().hash(studios) ^
      const _i49.MapEquality<_i48.ItemFilter, bool>().hash(itemFilters) ^
      const _i49.MapEquality<String, bool>().hash(tags) ^
      const _i49.MapEquality<int, bool>().hash(years) ^
      recursive.hashCode ^
      isDefault.hashCode ^
      key.hashCode;
}

/// generated route for
/// [_i29.LiveTvScreen]
class LiveTvRoute extends _i42.PageRouteInfo<LiveTvRouteArgs> {
  LiveTvRoute({
    String viewId = "",
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         LiveTvRoute.name,
         args: LiveTvRouteArgs(viewId: viewId, key: key),
         rawQueryParams: {'viewId': viewId},
         initialChildren: children,
       );

  static const String name = 'LiveTvRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LiveTvRouteArgs>(
        orElse: () =>
            LiveTvRouteArgs(viewId: queryParams.getString('viewId', "")),
      );
      return _i29.LiveTvScreen(viewId: args.viewId, key: args.key);
    },
  );
}

class LiveTvRouteArgs {
  const LiveTvRouteArgs({this.viewId = "", this.key});

  final String viewId;

  final _i43.Key? key;

  @override
  String toString() {
    return 'LiveTvRouteArgs{viewId: $viewId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LiveTvRouteArgs) return false;
    return viewId == other.viewId && key == other.key;
  }

  @override
  int get hashCode => viewId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i30.LockScreen]
class LockRoute extends _i42.PageRouteInfo<void> {
  const LockRoute({List<_i42.PageRouteInfo>? children})
    : super(LockRoute.name, initialChildren: children);

  static const String name = 'LockRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i30.LockScreen();
    },
  );
}

/// generated route for
/// [_i31.LoginScreen]
class LoginRoute extends _i42.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    String? authLink,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(authLink: authLink, key: key),
         rawQueryParams: {'authLink': authLink},
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () =>
            LoginRouteArgs(authLink: queryParams.optString('authLink')),
      );
      return _i31.LoginScreen(authLink: args.authLink, key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.authLink, this.key});

  final String? authLink;

  final _i43.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{authLink: $authLink, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return authLink == other.authLink && key == other.key;
  }

  @override
  int get hashCode => authLink.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i32.PhotoViewerScreen]
class PhotoViewerRoute extends _i42.PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    List<_i50.PhotoModel>? items,
    String? selected,
    _i51.PhotoQueueSource? photoQueueSource,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(
           items: items,
           selected: selected,
           photoQueueSource: photoQueueSource,
           key: key,
         ),
         rawQueryParams: {'selectedId': selected},
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<PhotoViewerRouteArgs>(
        orElse: () =>
            PhotoViewerRouteArgs(selected: queryParams.optString('selectedId')),
      );
      return _i32.PhotoViewerScreen(
        items: args.items,
        selected: args.selected,
        photoQueueSource: args.photoQueueSource,
        key: args.key,
      );
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({
    this.items,
    this.selected,
    this.photoQueueSource,
    this.key,
  });

  final List<_i50.PhotoModel>? items;

  final String? selected;

  final _i51.PhotoQueueSource? photoQueueSource;

  final _i43.Key? key;

  @override
  String toString() {
    return 'PhotoViewerRouteArgs{items: $items, selected: $selected, photoQueueSource: $photoQueueSource, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PhotoViewerRouteArgs) return false;
    return const _i49.ListEquality<_i50.PhotoModel>().equals(
          items,
          other.items,
        ) &&
        selected == other.selected &&
        photoQueueSource == other.photoQueueSource &&
        key == other.key;
  }

  @override
  int get hashCode =>
      const _i49.ListEquality<_i50.PhotoModel>().hash(items) ^
      selected.hashCode ^
      photoQueueSource.hashCode ^
      key.hashCode;
}

/// generated route for
/// [_i33.PlayerSettingsPage]
class PlayerSettingsRoute extends _i42.PageRouteInfo<void> {
  const PlayerSettingsRoute({List<_i42.PageRouteInfo>? children})
    : super(PlayerSettingsRoute.name, initialChildren: children);

  static const String name = 'PlayerSettingsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i33.PlayerSettingsPage();
    },
  );
}

/// generated route for
/// [_i34.ProfileSettingsPage]
class ProfileSettingsRoute extends _i42.PageRouteInfo<void> {
  const ProfileSettingsRoute({List<_i42.PageRouteInfo>? children})
    : super(ProfileSettingsRoute.name, initialChildren: children);

  static const String name = 'ProfileSettingsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i34.ProfileSettingsPage();
    },
  );
}

/// generated route for
/// [_i35.SeerrDetailsScreen]
class SeerrDetailsRoute extends _i42.PageRouteInfo<SeerrDetailsRouteArgs> {
  SeerrDetailsRoute({
    required String mediaType,
    required int tmdbId,
    _i52.SeerrDashboardPosterModel? poster,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         SeerrDetailsRoute.name,
         args: SeerrDetailsRouteArgs(
           mediaType: mediaType,
           tmdbId: tmdbId,
           poster: poster,
           key: key,
         ),
         rawPathParams: {'mediaType': mediaType, 'tmdbId': tmdbId},
         initialChildren: children,
       );

  static const String name = 'SeerrDetailsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SeerrDetailsRouteArgs>(
        orElse: () => SeerrDetailsRouteArgs(
          mediaType: pathParams.getString('mediaType'),
          tmdbId: pathParams.getInt('tmdbId'),
        ),
      );
      return _i35.SeerrDetailsScreen(
        mediaType: args.mediaType,
        tmdbId: args.tmdbId,
        poster: args.poster,
        key: args.key,
      );
    },
  );
}

class SeerrDetailsRouteArgs {
  const SeerrDetailsRouteArgs({
    required this.mediaType,
    required this.tmdbId,
    this.poster,
    this.key,
  });

  final String mediaType;

  final int tmdbId;

  final _i52.SeerrDashboardPosterModel? poster;

  final _i43.Key? key;

  @override
  String toString() {
    return 'SeerrDetailsRouteArgs{mediaType: $mediaType, tmdbId: $tmdbId, poster: $poster, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeerrDetailsRouteArgs) return false;
    return mediaType == other.mediaType &&
        tmdbId == other.tmdbId &&
        poster == other.poster &&
        key == other.key;
  }

  @override
  int get hashCode =>
      mediaType.hashCode ^ tmdbId.hashCode ^ poster.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i36.SeerrScreen]
class SeerrRoute extends _i42.PageRouteInfo<void> {
  const SeerrRoute({List<_i42.PageRouteInfo>? children})
    : super(SeerrRoute.name, initialChildren: children);

  static const String name = 'SeerrRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i36.SeerrScreen();
    },
  );
}

/// generated route for
/// [_i37.SeerrSearchScreen]
class SeerrSearchRoute extends _i42.PageRouteInfo<SeerrSearchRouteArgs> {
  SeerrSearchRoute({
    _i53.SeerrSearchMode? mode,
    int? yearGte,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         SeerrSearchRoute.name,
         args: SeerrSearchRouteArgs(mode: mode, yearGte: yearGte, key: key),
         rawQueryParams: {'mode': mode, 'yearGte': yearGte},
         initialChildren: children,
       );

  static const String name = 'SeerrSearchRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SeerrSearchRouteArgs>(
        orElse: () => SeerrSearchRouteArgs(
          mode: queryParams.get('mode'),
          yearGte: queryParams.optInt('yearGte'),
        ),
      );
      return _i37.SeerrSearchScreen(
        mode: args.mode,
        yearGte: args.yearGte,
        key: args.key,
      );
    },
  );
}

class SeerrSearchRouteArgs {
  const SeerrSearchRouteArgs({this.mode, this.yearGte, this.key});

  final _i53.SeerrSearchMode? mode;

  final int? yearGte;

  final _i43.Key? key;

  @override
  String toString() {
    return 'SeerrSearchRouteArgs{mode: $mode, yearGte: $yearGte, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeerrSearchRouteArgs) return false;
    return mode == other.mode && yearGte == other.yearGte && key == other.key;
  }

  @override
  int get hashCode => mode.hashCode ^ yearGte.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i38.SettingsScreen]
class SettingsRoute extends _i42.PageRouteInfo<void> {
  const SettingsRoute({List<_i42.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i38.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i39.SettingsSelectionScreen]
class SettingsSelectionRoute extends _i42.PageRouteInfo<void> {
  const SettingsSelectionRoute({List<_i42.PageRouteInfo>? children})
    : super(SettingsSelectionRoute.name, initialChildren: children);

  static const String name = 'SettingsSelectionRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i39.SettingsSelectionScreen();
    },
  );
}

/// generated route for
/// [_i40.SplashScreen]
class SplashRoute extends _i42.PageRouteInfo<SplashRouteArgs> {
  SplashRoute({
    dynamic Function(bool)? loggedIn,
    _i43.Key? key,
    List<_i42.PageRouteInfo>? children,
  }) : super(
         SplashRoute.name,
         args: SplashRouteArgs(loggedIn: loggedIn, key: key),
         initialChildren: children,
       );

  static const String name = 'SplashRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SplashRouteArgs>(
        orElse: () => const SplashRouteArgs(),
      );
      return _i40.SplashScreen(loggedIn: args.loggedIn, key: args.key);
    },
  );
}

class SplashRouteArgs {
  const SplashRouteArgs({this.loggedIn, this.key});

  final dynamic Function(bool)? loggedIn;

  final _i43.Key? key;

  @override
  String toString() {
    return 'SplashRouteArgs{loggedIn: $loggedIn, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SplashRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i41.SyncedScreen]
class SyncedRoute extends _i42.PageRouteInfo<void> {
  const SyncedRoute({List<_i42.PageRouteInfo>? children})
    : super(SyncedRoute.name, initialChildren: children);

  static const String name = 'SyncedRoute';

  static _i42.PageInfo page = _i42.PageInfo(
    name,
    builder: (data) {
      return const _i41.SyncedScreen();
    },
  );
}
