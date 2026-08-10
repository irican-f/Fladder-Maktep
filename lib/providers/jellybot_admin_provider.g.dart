// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jellybotApiClientsHash() =>
    r'57e0df7ed6c68418bb467154ba895e4426af32c1';

/// Read-side providers for the jellybot admin pages. Mutations live in the
/// pages themselves (existing section convention) and invalidate these.
///
/// Copied from [jellybotApiClients].
@ProviderFor(jellybotApiClients)
final jellybotApiClientsProvider =
    AutoDisposeFutureProvider<List<ApiClientDto>>.internal(
  jellybotApiClients,
  name: r'jellybotApiClientsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellybotApiClientsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellybotApiClientsRef
    = AutoDisposeFutureProviderRef<List<ApiClientDto>>;
String _$jellybotAllProvidersHash() =>
    r'59adabaeefc97c929049ed9192aed2c2715afc63';

/// See also [jellybotAllProviders].
@ProviderFor(jellybotAllProviders)
final jellybotAllProvidersProvider =
    AutoDisposeFutureProvider<List<IProvider>>.internal(
  jellybotAllProviders,
  name: r'jellybotAllProvidersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellybotAllProvidersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellybotAllProvidersRef = AutoDisposeFutureProviderRef<List<IProvider>>;
String _$jellybotLiveTvSourceHash() =>
    r'88a734bd0827f83af4a59afaf48d3564600149b2';

/// See also [jellybotLiveTvSource].
@ProviderFor(jellybotLiveTvSource)
final jellybotLiveTvSourceProvider =
    AutoDisposeFutureProvider<LiveTvSourceResult>.internal(
  jellybotLiveTvSource,
  name: r'jellybotLiveTvSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellybotLiveTvSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellybotLiveTvSourceRef
    = AutoDisposeFutureProviderRef<LiveTvSourceResult>;
String _$jellybotLiveTvCountriesHash() =>
    r'dc4154ffa8b26fc1c318e186258fd801d6f26626';

/// See also [jellybotLiveTvCountries].
@ProviderFor(jellybotLiveTvCountries)
final jellybotLiveTvCountriesProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  jellybotLiveTvCountries,
  name: r'jellybotLiveTvCountriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jellybotLiveTvCountriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JellybotLiveTvCountriesRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
