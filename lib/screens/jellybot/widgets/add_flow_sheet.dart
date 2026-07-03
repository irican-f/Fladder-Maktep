import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/providers/jellybot_add_flow_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/routes/auto_router.gr.dart';
import 'package:fladder/screens/jellybot/widgets/jellybot_meta_chip.dart';
import 'package:fladder/screens/jellybot/widgets/language_badge.dart';
import 'package:fladder/screens/jellybot/widgets/quality_badge.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

/// Opens the unified add flow for [item]: starts the controller immediately
/// (so extraction begins before the sheet has even rendered) and presents an
/// adaptive container — dialog on wide layouts, bottom sheet on phones.
/// Always resets the controller when the sheet closes.
Future<void> showAddFlowSheet(BuildContext context, WidgetRef ref, ProviderSearchItemDto item) async {
  final category = ref.read(jellybotSearchControllerProvider.notifier).searchState.category;
  // Capture the notifier up front: the page's ref may be disposed by the time
  // the sheet closes (auth redirect, deep navigation), but the keepAlive
  // notifier itself stays valid.
  final addFlow = ref.read(jellybotAddFlowProvider.notifier);
  unawaited(addFlow.start(item, category));
  if (AdaptiveLayout.layoutModeOf(context) == LayoutMode.single) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddFlowSheet(),
    );
  } else {
    await showDialog(
      context: context,
      builder: (_) => const Dialog(
        child: SizedBox(
          width: 480,
          child: AddFlowSheet(),
        ),
      ),
    );
  }
  addFlow.cancel();
}

class AddFlowSheet extends ConsumerWidget {
  const AddFlowSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jellybotAddFlowProvider);

    ref.listen(jellybotAddFlowProvider, (previous, next) {
      if (next?.step == AddFlowStep.success && previous?.step != AddFlowStep.success) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).maybePop();
          }
        });
      }
    });

    if (state == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        // Keeps the confirm step's text field above the keyboard on phones.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FlowHeader(state: state),
              const Divider(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (state.step) {
                  AddFlowStep.extracting => _ProgressStep(
                      key: const ValueKey('extracting'),
                      label: context.localized.jellybotAddFlowExtracting,
                    ),
                  AddFlowStep.committing => _ProgressStep(
                      key: const ValueKey('committing'),
                      label: context.localized.jellybotAddFlowCommitting,
                    ),
                  AddFlowStep.seasonSelection => _SeasonStep(state: state),
                  AddFlowStep.duplicateCheck => _DuplicateStep(state: state),
                  AddFlowStep.confirming => _ConfirmStep(state: state),
                  AddFlowStep.success => const _SuccessStep(),
                  AddFlowStep.failure => _FailureStep(state: state),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowHeader extends StatelessWidget {
  final JellybotAddFlowState state;
  const _FlowHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final item = state.item;
    final thumb = state.previewLink?.thumbnailUrl ?? item.thumbnailUrl;
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: 48,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(IconsaxPlusLinear.video_play, size: 20, color: scheme.onSurfaceVariant),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: (thumb ?? '').isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    thumb!,
                    width: 48,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => placeholder,
                  ),
                )
              : placeholder,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.mediaTitle ?? item.title ?? context.localized.unknown,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if ((item.quality ?? state.previewLink?.quality ?? '').isNotEmpty)
                    QualityBadge(quality: (item.quality ?? state.previewLink?.quality)!),
                  if ((item.language ?? '').isNotEmpty) LanguageBadge(language: item.language!),
                  if (item.year != null || state.previewLink?.productionYear != null)
                    JellybotMetaChip(
                      icon: IconsaxPlusLinear.calendar_1,
                      label: '${item.year ?? state.previewLink?.productionYear}',
                    ),
                  if (state.selectedSeason != null || item.season != null)
                    JellybotMetaChip(
                      icon: IconsaxPlusLinear.video_play,
                      label: '${context.localized.season(1)} ${state.selectedSeason ?? item.season}',
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: context.localized.close,
          icon: const Icon(Icons.close, size: 20),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  const _ProgressStep({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SeasonStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _SeasonStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasons = state.availableSeasons ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized.jellybotSelectSeason, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: seasons,
            itemBuilder: (context, index) {
              final season = index + 1;
              return ListTile(
                leading: const Icon(IconsaxPlusLinear.video_play),
                title: Text('${context.localized.season(1)} $season'),
                onTap: () => ref.read(jellybotAddFlowProvider.notifier).selectSeason(season),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DuplicateStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _DuplicateStep({required this.state});

  void _openExisting(BuildContext context) {
    final id = state.existingMedia?.id;
    if (id == null || id.isEmpty) {
      return;
    }
    final router = context.router;
    Navigator.of(context).maybePop();
    router.push(DetailsRoute(id: id.replaceAll('-', '')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = state.existingMedia;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(IconsaxPlusLinear.warning_2, size: 18, color: theme.colorScheme.tertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(context.localized.jellybotMediaExistsTitle, style: theme.textTheme.titleSmall),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.localized.jellybotMediaExistsMessage,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComparisonRow(
                    icon: IconsaxPlusBold.tick_circle,
                    iconColor: theme.colorScheme.tertiary,
                    label: context.localized.jellybotExistingTitle,
                    title: media?.title ?? context.localized.unknown,
                    year: media?.productionYear,
                  ),
                  const Divider(height: 16),
                  _ComparisonRow(
                    icon: IconsaxPlusLinear.link_21,
                    iconColor: theme.colorScheme.primary,
                    label: context.localized.jellybotAddedLinkTitle,
                    title: state.mediaTitle ?? state.item.title ?? '',
                    year: state.item.year ?? state.previewLink?.productionYear,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ChoiceTile(
          icon: IconsaxPlusLinear.add_circle,
          title: context.localized.jellybotNoDifferentMedia,
          subtitle: context.localized.jellybotDifferentMediaSubtitle,
          primary: true,
          onTap: () => ref.read(jellybotAddFlowProvider.notifier).continueAfterDuplicate(),
        ),
        const SizedBox(height: 8),
        _ChoiceTile(
          icon: IconsaxPlusLinear.export_3,
          title: context.localized.jellybotYesSameMedia,
          subtitle: context.localized.jellybotSameMediaSubtitle,
          primary: false,
          onTap: () => _openExisting(context),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = primary ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Material(
      color: primary ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: primary ? scheme.onPrimaryContainer : scheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              Icon(IconsaxPlusLinear.arrow_right_3, size: 16, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;
  final int? year;

  const _ComparisonRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.title,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
              ),
              Text(
                year != null ? '$title ($year)' : title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmStep extends ConsumerStatefulWidget {
  final JellybotAddFlowState state;
  const _ConfirmStep({required this.state});

  @override
  ConsumerState<_ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends ConsumerState<_ConfirmStep> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.state.mediaTitle ?? widget.state.item.title ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirm() {
    ref.read(jellybotAddFlowProvider.notifier).confirm(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.state.previewLink;
    final theme = Theme.of(context);
    final aired = link?.airedEpisodesCount ?? 0;
    final total = link?.totalEpisodesCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized.jellybotConfirmAdd, style: theme.textTheme.titleSmall),
        if (aired > 0 || total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$aired / $total ${context.localized.jellybotEpisodes(total)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _confirm(),
          decoration: InputDecoration(
            labelText: context.localized.name,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(IconsaxPlusLinear.tick_circle, size: 18),
            label: Text(context.localized.confirm),
          ),
        ),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconsaxPlusBold.tick_circle, color: scheme.tertiary, size: 28),
          const SizedBox(width: 12),
          Text(context.localized.jellybotLinkAdded, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FailureStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _FailureStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final failure = state.failure ?? AddFlowFailure.network;
    final (IconData icon, String message) = switch (failure) {
      AddFlowFailure.alreadyAdded => (IconsaxPlusBold.tick_circle, context.localized.jellybotLinkAlreadyExists),
      AddFlowFailure.previewExpired => (IconsaxPlusLinear.timer_1, context.localized.jellybotAddFlowPreviewExpired),
      AddFlowFailure.extractionFailed => (
          IconsaxPlusLinear.warning_2,
          context.localized.jellybotAddFlowExtractionFailed
        ),
      AddFlowFailure.network => (IconsaxPlusLinear.wifi_square, context.localized.jellybotErrorAddingLink),
    };
    final isInfo = failure == AddFlowFailure.alreadyAdded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: isInfo ? theme.colorScheme.tertiary : theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          ],
        ),
        if ((state.failureDetail ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SelectableText.rich(
              TextSpan(
                text: state.failureDetail,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ),
        if (!isInfo) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () => ref.read(jellybotAddFlowProvider.notifier).retry(),
              icon: const Icon(IconsaxPlusLinear.refresh),
              label: Text(context.localized.retry),
            ),
          ),
        ],
      ],
    );
  }
}
