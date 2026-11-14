// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-side providers for the jellybot admin pages. Mutations live in the
/// pages themselves (existing section convention) and invalidate these.

@ProviderFor(jellybotApiClients)
final jellybotApiClientsProvider = JellybotApiClientsProvider._();

/// Read-side providers for the jellybot admin pages. Mutations live in the
/// pages themselves (existing section convention) and invalidate these.

final class JellybotApiClientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ApiClientDto>>,
          List<ApiClientDto>,
          FutureOr<List<ApiClientDto>>
        >
    with
        $FutureModifier<List<ApiClientDto>>,
        $FutureProvider<List<ApiClientDto>> {
  /// Read-side providers for the jellybot admin pages. Mutations live in the
  /// pages themselves (existing section convention) and invalidate these.
  JellybotApiClientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotApiClientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotApiClientsHash();

  @$internal
  @override
  $FutureProviderElement<List<ApiClientDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ApiClientDto>> create(Ref ref) {
    return jellybotApiClients(ref);
  }
}

String _$jellybotApiClientsHash() =>
    r'57e0df7ed6c68418bb467154ba895e4426af32c1';

@ProviderFor(jellybotAllProviders)
final jellybotAllProvidersProvider = JellybotAllProvidersProvider._();

final class JellybotAllProvidersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IProvider>>,
          List<IProvider>,
          FutureOr<List<IProvider>>
        >
    with $FutureModifier<List<IProvider>>, $FutureProvider<List<IProvider>> {
  JellybotAllProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotAllProvidersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotAllProvidersHash();

  @$internal
  @override
  $FutureProviderElement<List<IProvider>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IProvider>> create(Ref ref) {
    return jellybotAllProviders(ref);
  }
}

String _$jellybotAllProvidersHash() =>
    r'59adabaeefc97c929049ed9192aed2c2715afc63';

@ProviderFor(jellybotLiveTvSource)
final jellybotLiveTvSourceProvider = JellybotLiveTvSourceProvider._();

final class JellybotLiveTvSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveTvSourceResult>,
          LiveTvSourceResult,
          FutureOr<LiveTvSourceResult>
        >
    with
        $FutureModifier<LiveTvSourceResult>,
        $FutureProvider<LiveTvSourceResult> {
  JellybotLiveTvSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotLiveTvSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotLiveTvSourceHash();

  @$internal
  @override
  $FutureProviderElement<LiveTvSourceResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LiveTvSourceResult> create(Ref ref) {
    return jellybotLiveTvSource(ref);
  }
}

String _$jellybotLiveTvSourceHash() =>
    r'88a734bd0827f83af4a59afaf48d3564600149b2';

@ProviderFor(jellybotLiveTvCountries)
final jellybotLiveTvCountriesProvider = JellybotLiveTvCountriesProvider._();

final class JellybotLiveTvCountriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  JellybotLiveTvCountriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotLiveTvCountriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotLiveTvCountriesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return jellybotLiveTvCountries(ref);
  }
}

String _$jellybotLiveTvCountriesHash() =>
    r'dc4154ffa8b26fc1c318e186258fd801d6f26626';
