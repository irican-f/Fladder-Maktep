import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:chopper/chopper.dart' show Response;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

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
class JellybotApiClientsPage extends ConsumerWidget {
  const JellybotApiClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return const JellybotAdminLock();
    }

    final clientsAsync = ref.watch(jellybotApiClientsProvider);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _ApiClientFormDialog(client: null),
            ),
            icon: const Icon(IconsaxPlusLinear.add),
            label: Text(context.localized.jellybotApiClientAdd),
          ),
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
                    const Icon(IconsaxPlusLinear.cloud),
                    const SizedBox(width: 12),
                    Text(context.localized.jellybotApiClients),
                  ],
                ),
              ),
              clientsAsync.when(
                data: (clients) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ApiClientCard(client: clients[index]),
                      childCount: clients.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: SearchErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(jellybotApiClientsProvider),
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

class _ApiClientCard extends ConsumerWidget {
  final ApiClientDto client;
  const _ApiClientCard({required this.client});

  Future<void> _setEnabled(BuildContext context, WidgetRef ref, bool value) async {
    final id = client.id;
    if (id == null) {
      return;
    }
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiApiClientsApiClientIdPut(
        apiClientId: id,
        body: UpdateApiClientRequest(isEnabled: value),
      );
      if (!context.mounted) {
        return;
      }
      if (response.isSuccessful) {
        ref.invalidate(jellybotApiClientsProvider);
      } else {
        FladderSnack.show(
          problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}'),
          context: context,
        );
      }
    } catch (e) {
      log('Failed to toggle api client', error: e);
      if (context.mounted) {
        FladderSnack.show(e.toString(), context: context);
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final id = client.id;
    if (id == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localized.jellybotApiClientDelete),
        content: Text(context.localized.jellybotApiClientDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiApiClientsApiClientIdDelete(apiClientId: id);
      if (!context.mounted) {
        return;
      }
      if (response.isSuccessful) {
        ref.invalidate(jellybotApiClientsProvider);
        FladderSnack.show(context.localized.jellybotApiClientDeleted, context: context);
      } else {
        FladderSnack.show(
          problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}'),
          context: context,
        );
      }
    } catch (e) {
      log('Failed to delete api client', error: e);
      if (context.mounted) {
        FladderSnack.show(e.toString(), context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expires = client.subscriptionExpiresAt;
    final now = DateTime.now();
    final isExpired = expires != null && expires.isBefore(now);
    final expiresSoon = expires != null && !isExpired && expires.difference(now).inDays < 7;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              client.isTorrentClient == true ? IconsaxPlusLinear.document_download : IconsaxPlusLinear.cloud,
              color: client.isActive == true ? theme.colorScheme.tertiary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name ?? '', style: theme.textTheme.titleSmall),
                  Text(
                    [
                      client.type,
                      if ((client.baseUrl ?? '').isNotEmpty) client.baseUrl,
                      '${context.localized.jellybotApiClientPriority} ${client.priority}',
                    ].whereType<String>().join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (expires != null)
                    Text(
                      isExpired
                          ? context.localized.jellybotApiClientExpired
                          : context.localized.jellybotApiClientExpiresOn(DateFormat.yMMMd().format(expires)),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isExpired
                            ? theme.colorScheme.error
                            : expiresSoon
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: client.isEnabled ?? false,
              onChanged: (value) => _setEnabled(context, ref, value),
            ),
            IconButton(
              icon: const Icon(IconsaxPlusLinear.edit_2),
              tooltip: context.localized.jellybotApiClientEdit,
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _ApiClientFormDialog(client: client),
              ),
            ),
            IconButton(
              icon: Icon(IconsaxPlusLinear.trash, color: theme.colorScheme.error),
              tooltip: context.localized.jellybotApiClientDelete,
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiClientFormDialog extends ConsumerStatefulWidget {
  final ApiClientDto? client;
  const _ApiClientFormDialog({required this.client});

  @override
  ConsumerState<_ApiClientFormDialog> createState() => _ApiClientFormDialogState();
}

class _ApiClientFormDialogState extends ConsumerState<_ApiClientFormDialog> {
  late final _name = TextEditingController(text: widget.client?.name ?? '');
  late final _type = TextEditingController(text: widget.client?.type ?? '');
  late final _baseUrl = TextEditingController(text: widget.client?.baseUrl ?? '');
  late final _username = TextEditingController(text: widget.client?.username ?? '');
  final _apiKey = TextEditingController();
  final _password = TextEditingController();
  late final _priority = TextEditingController(text: '${widget.client?.priority ?? 0}');
  late final _maxConcurrent = TextEditingController(text: '${widget.client?.maxConcurrentRequests ?? 1}');
  late final _rateLimit = TextEditingController(text: '${widget.client?.rateLimitPerMinute ?? 60}');
  late bool _isEnabled = widget.client?.isEnabled ?? true;
  late bool _isTorrent = widget.client?.isTorrentClient ?? false;
  late DateTime? _expiresAt = widget.client?.subscriptionExpiresAt;
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _type,
      _baseUrl,
      _username,
      _apiKey,
      _password,
      _priority,
      _maxConcurrent,
      _rateLimit
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final api = ref.read(jellybotApiProvider);
    final existing = widget.client;
    final Response<ApiClientDto> response;
    try {
      response = existing != null
          ? await api.apiApiClientsApiClientIdPut(
              apiClientId: existing.id,
              body: UpdateApiClientRequest(
                name: _name.text.trim(),
                type: _type.text.trim(),
                baseUrl: _baseUrl.text.trim().isEmpty ? null : _baseUrl.text.trim(),
                username: _username.text.trim().isEmpty ? null : _username.text.trim(),
                apiKey: _apiKey.text.isEmpty ? null : _apiKey.text,
                password: _password.text.isEmpty ? null : _password.text,
                isEnabled: _isEnabled,
                isTorrentClient: _isTorrent,
                priority: int.tryParse(_priority.text),
                maxConcurrentRequests: int.tryParse(_maxConcurrent.text),
                rateLimitPerMinute: int.tryParse(_rateLimit.text),
                subscriptionExpiresAt: _expiresAt,
              ),
            )
          : await api.apiApiClientsPost(
              body: CreateApiClientRequest(
                name: _name.text.trim(),
                type: _type.text.trim(),
                baseUrl: _baseUrl.text.trim().isEmpty ? null : _baseUrl.text.trim(),
                username: _username.text.trim().isEmpty ? null : _username.text.trim(),
                apiKey: _apiKey.text.isEmpty ? null : _apiKey.text,
                password: _password.text.isEmpty ? null : _password.text,
                isEnabled: _isEnabled,
                isTorrentClient: _isTorrent,
                priority: int.tryParse(_priority.text) ?? 0,
                maxConcurrentRequests: int.tryParse(_maxConcurrent.text) ?? 1,
                rateLimitPerMinute: int.tryParse(_rateLimit.text) ?? 60,
                subscriptionExpiresAt: _expiresAt,
              ),
            );
    } catch (e) {
      log('Failed to save api client', error: e);
      if (mounted) {
        setState(() {
          _saving = false;
          _errorText = e.toString();
        });
      }
      return;
    }
    if (!mounted) {
      return;
    }
    if (response.isSuccessful) {
      ref.invalidate(jellybotApiClientsProvider);
      Navigator.pop(context);
      FladderSnack.show(context.localized.jellybotApiClientSaved, context: context);
    } else {
      setState(() {
        _saving = false;
        _errorText =
            problemDetailFromResponse(response) ?? context.localized.jellybotRequestFailed('${response.statusCode}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
    final secretHint = isEdit ? context.localized.jellybotApiClientSecretHint : null;
    return AlertDialog(
      title: Text(isEdit ? context.localized.jellybotApiClientEdit : context.localized.jellybotApiClientAdd),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: '${context.localized.jellybotApiClientName} *',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _type,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: '${context.localized.jellybotApiClientType} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKey,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.localized.jellybotApiClientApiKey,
                  helperText: (widget.client?.hasApiKey ?? false) ? secretHint : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.localized.enabled),
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(context.localized.jellybotAdvanced),
                children: [
                  TextField(
                    controller: _baseUrl,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientBaseUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientUsername,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientPassword,
                      helperText: (widget.client?.hasPassword ?? false) ? secretHint : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priority,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.localized.jellybotApiClientPriority,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxConcurrent,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.localized.jellybotApiClientMaxConcurrent,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rateLimit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientRateLimit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotApiClientTorrent),
                    value: _isTorrent,
                    onChanged: (value) => setState(() => _isTorrent = value),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotApiClientExpiresOn(
                      _expiresAt != null ? DateFormat.yMMMd().format(_expiresAt!) : '—',
                    )),
                    trailing: const Icon(IconsaxPlusLinear.calendar_1),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiresAt ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _expiresAt = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.localized.cancel),
        ),
        FilledButton(
          onPressed: _saving || _name.text.trim().isEmpty || _type.text.trim().isEmpty ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.localized.save),
        ),
      ],
    );
  }
}
