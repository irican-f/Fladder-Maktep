import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:chopper/chopper.dart' show Response;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_problem_details.dart';
import 'package:fladder/providers/jellybot_admin_provider.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/jellybot/widgets/jellybot_admin_lock.dart';
import 'package:fladder/screens/jellybot/widgets/search_error_state.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

@RoutePage()
class JellybotLiveTvSourcePage extends ConsumerStatefulWidget {
  const JellybotLiveTvSourcePage({super.key});

  @override
  ConsumerState<JellybotLiveTvSourcePage> createState() => _JellybotLiveTvSourcePageState();
}

class _JellybotLiveTvSourcePageState extends ConsumerState<JellybotLiveTvSourcePage> {
  final _urlController = TextEditingController();
  Set<String> _selectedCountries = {};
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _seedFrom(LiveTvSourceResult source) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    _urlController.text = source.baseUrl ?? '';
    _selectedCountries = {...(source.countries ?? const <String>[])};
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = ref.read(jellybotApiProvider);
    final Response<LiveTvSourceResult> response;
    try {
      response = await api.apiSettingsLiveTvSourcePut(
        body: UpdateLiveTvSourceRequest(
          baseUrl: _urlController.text.trim(),
          countries: _selectedCountries.toList(),
        ),
      );
    } catch (e) {
      log('Failed to save Live TV source', error: e);
      if (mounted) {
        setState(() => _saving = false);
        FladderSnack.show(e.toString(), context: context);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (response.isSuccessful) {
      _seeded = false;
      ref.invalidate(jellybotLiveTvSourceProvider);
      ref.invalidate(jellybotLiveTvCountriesProvider);
      // Capture what the closure needs — the FladderSnack overlay can outlive
      // this page, so the action must not touch `ref` or `context`.
      final jobTriggered = context.localized.jellybotJobTriggered('LiveTvChannelsJob');
      FladderSnack.show(
        context.localized.jellybotLiveTvSourceSaved,
        context: context,
        actionLabel: context.localized.jellybotLiveTvRunJob,
        onActionPressed: () => unawaited(
          api
              .apiJobsPost(body: const TriggerJobRequest(jobType: 'LiveTvChannelsJob'))
              .then((jobResponse) => FladderSnack.show(jobTriggered))
              .catchError((Object e) {
            log('Failed to trigger Live TV job', error: e);
            FladderSnack.show(e.toString());
          }),
        ),
      );
    } else {
      FladderSnack.show(
        problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}'),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return const JellybotAdminLock();
    }

    final sourceAsync = ref.watch(jellybotLiveTvSourceProvider);
    final countriesAsync = ref.watch(jellybotLiveTvCountriesProvider);
    final theme = Theme.of(context);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          body: sourceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SearchErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(jellybotLiveTvSourceProvider),
            ),
            data: (source) {
              _seedFrom(source);
              final countries = countriesAsync.valueOrNull ?? const <String>[];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      if (AdaptiveLayout.layoutModeOf(context) == LayoutMode.single)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.router.maybePop(),
                        ),
                      const Icon(IconsaxPlusLinear.monitor),
                      const SizedBox(width: 12),
                      Text(context.localized.jellybotLiveTvSource, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (source.fromDatabase == false)
                    Card(
                      color: theme.colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(IconsaxPlusLinear.info_circle, color: theme.colorScheme.onTertiaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.localized.jellybotLiveTvSourceFromConfig,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotLiveTvSourceUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.localized.jellybotLiveTvSourceCountries, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (countriesAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else if (countries.isEmpty)
                    Text(
                      context.localized.jellybotLiveTvSourceNoCountries,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: countries
                          .map(
                            (country) => FilterChip(
                              label: Text(country.toUpperCase()),
                              selected: _selectedCountries.contains(country),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _selectedCountries.add(country);
                                } else {
                                  _selectedCountries.remove(country);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(IconsaxPlusLinear.tick_circle),
                      label: Text(context.localized.save),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
