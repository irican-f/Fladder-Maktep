// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(jellybotProviders)
final jellybotProvidersProvider = JellybotProvidersProvider._();

final class JellybotProvidersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IProvider>>,
          List<IProvider>,
          FutureOr<List<IProvider>>
        >
    with $FutureModifier<List<IProvider>>, $FutureProvider<List<IProvider>> {
  JellybotProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotProvidersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotProvidersHash();

  @$internal
  @override
  $FutureProviderElement<List<IProvider>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IProvider>> create(Ref ref) {
    return jellybotProviders(ref);
  }
}

String _$jellybotProvidersHash() => r'b5a7b3a357318938349ccac25ef3a1714c335880';

@ProviderFor(jellybotSearchFilters)
final jellybotSearchFiltersProvider = JellybotSearchFiltersFamily._();

final class JellybotSearchFiltersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ISearchFilter>>,
          List<ISearchFilter>,
          FutureOr<List<ISearchFilter>>
        >
    with
        $FutureModifier<List<ISearchFilter>>,
        $FutureProvider<List<ISearchFilter>> {
  JellybotSearchFiltersProvider._({
    required JellybotSearchFiltersFamily super.from,
    required (String, MediaCategory) super.argument,
  }) : super(
         retry: null,
         name: r'jellybotSearchFiltersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$jellybotSearchFiltersHash();

  @override
  String toString() {
    return r'jellybotSearchFiltersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ISearchFilter>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ISearchFilter>> create(Ref ref) {
    final argument = this.argument as (String, MediaCategory);
    return jellybotSearchFilters(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is JellybotSearchFiltersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jellybotSearchFiltersHash() =>
    r'65e3dbf40d3d960dd23c3643ce580fcd60c5b43c';

final class JellybotSearchFiltersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ISearchFilter>>,
          (String, MediaCategory)
        > {
  JellybotSearchFiltersFamily._()
    : super(
        retry: null,
        name: r'jellybotSearchFiltersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  JellybotSearchFiltersProvider call(
    String providerId,
    MediaCategory category,
  ) => JellybotSearchFiltersProvider._(
    argument: (providerId, category),
    from: this,
  );

  @override
  String toString() => r'jellybotSearchFiltersProvider';
}

/// Normalized URL keys (see [normalizeCrawlUrlKey]) of every crawl link the
/// server knows — backs the "already added" badge on search-result cards.
/// Page 0 is fetched first to learn totalPages, remaining pages concurrently.
/// Invalidated after every successful add (and on 409s) to refresh badging.

@ProviderFor(addedCrawlLinkUrls)
final addedCrawlLinkUrlsProvider = AddedCrawlLinkUrlsProvider._();

/// Normalized URL keys (see [normalizeCrawlUrlKey]) of every crawl link the
/// server knows — backs the "already added" badge on search-result cards.
/// Page 0 is fetched first to learn totalPages, remaining pages concurrently.
/// Invalidated after every successful add (and on 409s) to refresh badging.

final class AddedCrawlLinkUrlsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Normalized URL keys (see [normalizeCrawlUrlKey]) of every crawl link the
  /// server knows — backs the "already added" badge on search-result cards.
  /// Page 0 is fetched first to learn totalPages, remaining pages concurrently.
  /// Invalidated after every successful add (and on 409s) to refresh badging.
  AddedCrawlLinkUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addedCrawlLinkUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addedCrawlLinkUrlsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return addedCrawlLinkUrls(ref);
  }
}

String _$addedCrawlLinkUrlsHash() =>
    r'5500d47642e8b11a68190db0cd4ff1c3faf09e82';

/// Notifier holding the current search-request params (in `_state`) and the
/// search response in its `AsyncValue<PaginatedResponseOfProviderSearchItemDto?>`.
///
/// Filter setters (provider/category/selectedFilters/exactMatch/minScore) call
/// `_maybeAutoSearch` which re-runs the search whenever the query is non-empty.
/// `setQuery` deliberately does NOT auto-search — the search bar uses an
/// explicit submit so we don't fire on every keystroke.

@ProviderFor(JellybotSearchController)
final jellybotSearchControllerProvider = JellybotSearchControllerProvider._();

/// Notifier holding the current search-request params (in `_state`) and the
/// search response in its `AsyncValue<PaginatedResponseOfProviderSearchItemDto?>`.
///
/// Filter setters (provider/category/selectedFilters/exactMatch/minScore) call
/// `_maybeAutoSearch` which re-runs the search whenever the query is non-empty.
/// `setQuery` deliberately does NOT auto-search — the search bar uses an
/// explicit submit so we don't fire on every keystroke.
final class JellybotSearchControllerProvider
    extends
        $AsyncNotifierProvider<
          JellybotSearchController,
          PaginatedResponseOfProviderSearchItemDto?
        > {
  /// Notifier holding the current search-request params (in `_state`) and the
  /// search response in its `AsyncValue<PaginatedResponseOfProviderSearchItemDto?>`.
  ///
  /// Filter setters (provider/category/selectedFilters/exactMatch/minScore) call
  /// `_maybeAutoSearch` which re-runs the search whenever the query is non-empty.
  /// `setQuery` deliberately does NOT auto-search — the search bar uses an
  /// explicit submit so we don't fire on every keystroke.
  JellybotSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotSearchControllerHash();

  @$internal
  @override
  JellybotSearchController create() => JellybotSearchController();
}

String _$jellybotSearchControllerHash() =>
    r'6c37dfef0e60a5a2899bb5b460903b1567a1f9e7';

/// Notifier holding the current search-request params (in `_state`) and the
/// search response in its `AsyncValue<PaginatedResponseOfProviderSearchItemDto?>`.
///
/// Filter setters (provider/category/selectedFilters/exactMatch/minScore) call
/// `_maybeAutoSearch` which re-runs the search whenever the query is non-empty.
/// `setQuery` deliberately does NOT auto-search — the search bar uses an
/// explicit submit so we don't fire on every keystroke.

abstract class _$JellybotSearchController
    extends $AsyncNotifier<PaginatedResponseOfProviderSearchItemDto?> {
  FutureOr<PaginatedResponseOfProviderSearchItemDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedResponseOfProviderSearchItemDto?>,
              PaginatedResponseOfProviderSearchItemDto?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedResponseOfProviderSearchItemDto?>,
                PaginatedResponseOfProviderSearchItemDto?
              >,
              AsyncValue<PaginatedResponseOfProviderSearchItemDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
