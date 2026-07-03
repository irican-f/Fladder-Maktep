import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_problem_details.dart';
import 'package:fladder/providers/jellybot_admin_provider.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/jellybot/widgets/jellybot_admin_lock.dart';
import 'package:fladder/screens/jellybot/widgets/search_error_state.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

@RoutePage()
class JellybotProvidersPage extends ConsumerWidget {
  const JellybotProvidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return const JellybotAdminLock();
    }

    final providersAsync = ref.watch(jellybotAllProvidersProvider);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                leading: AdaptiveLayout.layoutModeOf(context) == LayoutMode.single
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.router.maybePop(),
                      )
                    : null,
                title: Row(
                  children: [
                    const Icon(IconsaxPlusLinear.global),
                    const SizedBox(width: 12),
                    Text(context.localized.jellybotProvidersManage),
                  ],
                ),
              ),
              providersAsync.when(
                data: (providers) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProviderCard(provider: providers[index]),
                      childCount: providers.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: SearchErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(jellybotAllProvidersProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  final IProvider provider;
  const _ProviderCard({required this.provider});

  Future<void> _update(BuildContext context, WidgetRef ref, UpdateProviderRequest request) async {
    final id = provider.id;
    if (id == null) {
      return;
    }
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiProvidersProviderIdPut(providerId: id, body: request);
      if (!context.mounted) {
        return;
      }
      if (response.isSuccessful) {
        ref.invalidate(jellybotAllProvidersProvider);
        ref.invalidate(jellybotProvidersProvider);
        FladderSnack.show(context.localized.jellybotProviderUpdated, context: context);
      } else {
        FladderSnack.show(
          problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}'),
          context: context,
        );
      }
    } catch (e) {
      log('Failed to update provider', error: e);
      if (context.mounted) {
        FladderSnack.show(e.toString(), context: context);
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => _ProviderEditDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.displayName ?? provider.name ?? '', style: theme.textTheme.titleSmall),
                      if ((provider.url ?? '').isNotEmpty)
                        Text(
                          provider.url!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (provider.isManuallyDisabled == true)
                        Text(
                          context.localized.jellybotProviderManuallyDisabled,
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(IconsaxPlusLinear.edit_2),
                  tooltip: context.localized.jellybotProviderEditTitle,
                  onPressed: () => _edit(context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotProviderEnabled),
                    value: provider.enabled ?? false,
                    onChanged: (value) => _update(context, ref, UpdateProviderRequest(enabled: value)),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotProviderSearchEnabled),
                    value: provider.searchEnabled ?? false,
                    onChanged: (value) => _update(context, ref, UpdateProviderRequest(searchEnabled: value)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderEditDialog extends ConsumerStatefulWidget {
  final IProvider provider;
  const _ProviderEditDialog({required this.provider});

  @override
  ConsumerState<_ProviderEditDialog> createState() => _ProviderEditDialogState();
}

class _ProviderEditDialogState extends ConsumerState<_ProviderEditDialog> {
  late final _name = TextEditingController(text: widget.provider.displayName ?? widget.provider.name ?? '');
  late final _url = TextEditingController(text: widget.provider.url ?? '');
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = widget.provider.id;
    if (id == null) {
      return;
    }
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiProvidersProviderIdPut(
        providerId: id,
        body: UpdateProviderRequest(
          displayName: _name.text.trim(),
          url: _url.text.trim(),
        ),
      );
      if (!mounted) {
        return;
      }
      if (response.isSuccessful) {
        ref.invalidate(jellybotAllProvidersProvider);
        ref.invalidate(jellybotProvidersProvider);
        Navigator.pop(context);
        FladderSnack.show(context.localized.jellybotProviderUpdated, context: context);
      } else {
        setState(() {
          _saving = false;
          _errorText =
              problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}');
        });
      }
    } catch (e) {
      log('Failed to update provider', error: e);
      if (mounted) {
        setState(() {
          _saving = false;
          _errorText = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.localized.jellybotProviderEditTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: context.localized.jellybotProviderDisplayName,
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            decoration: InputDecoration(
              labelText: context.localized.jellybotProviderUrl,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.localized.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.localized.save),
        ),
      ],
    );
  }
}
