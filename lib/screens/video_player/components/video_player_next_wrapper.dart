import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/episode_model.dart';
import 'package:fladder/models/items/images_models.dart';
import 'package:fladder/models/media_playback_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/settings/video_player_settings.dart';
import 'package:fladder/providers/settings/video_player_settings_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/providers/video_player_provider.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/fladder_image.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/navigation_scaffold/components/shared/player_bar_shared.dart';
import 'package:fladder/widgets/shared/progress_floating_button.dart';

const _countdown = Duration(seconds: 30);
const _animSpeed = Duration(milliseconds: 250);
const _cardMargin = 24.0;

/// Room kept free under the card so it never covers the player's bottom block
/// (end time, progress bar, timestamps and the button row).
const _controlsClearance = 190.0;

/// Height of the card below its image: kicker, up to two title lines, buttons, padding.
const _cardTextHeight = 160.0;
const _cardMinWidth = 260.0;
const _cardMaxWidth = 480.0;
const _buttonHeight = 44.0;

/// Size of the next-up card for a screen of [screen] size.
///
/// Width: full width (minus margins) on a phone in portrait, a bit under half a phone held
/// sideways, about a third of anything bigger (tablet, desktop window of any shape, TV).
/// A phone held sideways never shows the image: the video needs the little height there is.
/// Elsewhere the card shrinks so it fits above the controls; when even the narrowest card
/// with its 16:9 image would not fit, the image is dropped ([showImage] false).
@visibleForTesting
({double width, bool showImage}) nextUpCardLayout(Size screen) {
  final isPhone = screen.shortestSide < 600;
  final isPortrait = screen.width < screen.height;
  if (isPhone && !isPortrait) return (width: screen.width * 0.44, showImage: false);
  final width = isPhone ? screen.width - 2 * _cardMargin : (screen.width * 0.34).clamp(_cardMinWidth, _cardMaxWidth);
  final availableHeight = screen.height - _cardMargin - _controlsClearance;
  final widthThatFits = (availableHeight - _cardTextHeight) * 16 / 9;
  if (widthThatFits >= width) return (width: width, showImage: true);
  if (widthThatFits >= _cardMinWidth) return (width: widthThatFits, showImage: true);
  return (width: width, showImage: false);
}

class VideoPlayerNextWrapper extends ConsumerStatefulWidget {
  final Widget video;
  final Widget Function(bool nextUpVisible) controlsBuilder;
  final List<Widget> overlays;

  const VideoPlayerNextWrapper({
    required this.video,
    required this.controlsBuilder,
    this.overlays = const [],
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoPlayerNextWrapperState();
}

class _VideoPlayerNextWrapperState extends ConsumerState<VideoPlayerNextWrapper> {
  bool show = false;
  bool showOverwrite = false;
  late RestartableTimerController timerController = RestartableTimerController(
    _countdown,
    const Duration(milliseconds: 33),
    onTimeout: onTimeOut,
  );

  final FocusNode _playFocus = FocusNode(debugLabel: 'next-up-play');
  FocusNode? _focusBeforeCard;

  void onTimeOut() {
    timerController.cancel();
    if (showOverwrite == true) return;
    final nextUp = ref.read(playBackModel.select((value) => value?.nextVideo));
    if (nextUp != null) {
      ref.read(playbackModelHelper).loadNewVideo(nextUp);
    }
    hideNextUp();
  }

  void showNextScreen(MediaPlaybackModel model) {
    final nextUp = ref.read(playBackModel.select((value) => value?.nextVideo));
    if (nextUp == null) return;
    if (show) return;
    if (showOverwrite) return;
    if (!model.playing) return;
    if (model.buffering) return;

    setState(() {
      show = true;
      timerController.reset();
      timerController.play();
    });

    // A D-pad has no pointer to reach the card with: put Play under the remote.
    if (AdaptiveLayout.inputDeviceOf(context) == InputDevice.dPad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !show) return;
        _focusBeforeCard = FocusManager.instance.primaryFocus;
        _playFocus.requestFocus();
      });
    }
  }

  void determineShow(MediaPlaybackModel model) {
    final playerState = ref.watch(mediaPlaybackProvider.select((value) => value.state));
    if (playerState != VideoPlayerState.fullScreen) {
      showOverwrite = false;
      show = false;
      return;
    }

    final nextType = ref.read(videoPlayerSettingsProvider.select((value) => value.nextVideoType));
    if (nextType == AutoNextType.off || model.duration < const Duration(seconds: 40)) {
      showOverwrite = false;
      show = false;
      return;
    }

    final credits = ref.read(playBackModel)?.mediaSegments?.outro;

    if (nextType == AutoNextType.static || credits == null) {
      if ((model.duration - model.position).abs() < const Duration(seconds: 32)) {
        showNextScreen(model);
        return;
      }
    } else if (nextType == AutoNextType.smart) {
      final maxTime = ref.read(userProvider.select((value) => value?.serverConfiguration?.maxResumePct ?? 90));
      final resumeDuration = model.duration * (maxTime / 100);
      final timeLeft = model.duration - credits.end;
      if (credits.end > resumeDuration && timeLeft < const Duration(seconds: 30)) {
        if (model.position >= credits.start) {
          showNextScreen(model);
          return;
        }
      } else if ((model.duration - model.position).abs() < const Duration(seconds: 32)) {
        showNextScreen(model);
        return;
      }
    }
    setState(() {
      show = false;
      showOverwrite = false;
      timerController.cancel();
    });
  }

  void hideNextUp() {
    timerController.cancel();
    setState(() {
      show = false;
      showOverwrite = true;
    });
    if (_playFocus.hasFocus) {
      _focusBeforeCard?.requestFocus();
    }
    _focusBeforeCard = null;
  }

  @override
  void dispose() {
    timerController.cancel();
    _playFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextUp = ref.watch(playBackModel.select((value) => value?.nextVideo));
    final cardLayout = nextUpCardLayout(MediaQuery.sizeOf(context));

    ref.listen(mediaPlaybackProvider, (previous, next) => determineShow(next));
    return Hero(
      tag: videoPlayerHeroTag,
      child: Stack(
        children: [
          Positioned.fill(child: widget.video),
          // The card sits on top of the controls instead of replacing them, so they stay usable.
          Positioned.fill(child: widget.controlsBuilder(false)),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _animSpeed,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: show && nextUp != null
                  ? Align(
                      key: const ValueKey('next-up-card'),
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: MediaQuery.paddingOf(
                          context,
                        ).add(const EdgeInsets.fromLTRB(_cardMargin, _cardMargin, _cardMargin, _controlsClearance)),
                        child: SizedBox(
                          width: cardLayout.width,
                          child: _NextUpCard(
                            item: nextUp,
                            showImage: cardLayout.showImage,
                            timer: timerController,
                            playFocus: _playFocus,
                            onPlay: onTimeOut,
                            onDismiss: hideNextUp,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-next-up-card')),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final ItemBaseModel item;
  final bool showImage;
  final RestartableTimerController timer;
  final FocusNode playFocus;
  final VoidCallback onPlay;
  final VoidCallback onDismiss;

  const _NextUpCard({
    required this.item,
    required this.showImage,
    required this.timer,
    required this.playFocus,
    required this.onPlay,
    required this.onDismiss,
  });

  /// Episodes show their 16:9 still; anything else prefers a landscape backdrop.
  ImageData? get _image => item is EpisodeModel
      ? item.images?.primary ?? item.images?.backDrop?.firstOrNull
      : item.images?.backDrop?.firstOrNull ?? item.images?.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localized;
    final episode = item is EpisodeModel ? item as EpisodeModel : null;
    final kickerDetail = item.subTextShort(l10n);
    final kicker = kickerDetail == null ? l10n.nextUp : '${l10n.nextUp} · $kickerDetail';
    final title = episode?.name ?? item.title;

    return Focus(
      // Back / Esc while the card has focus means "keep watching", not "leave the player".
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.goBack)) {
          onDismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: StreamBuilder<Duration>(
        stream: timer.timeLeft,
        initialData: _countdown,
        builder: (context, snapshot) {
          final left = snapshot.data ?? _countdown;
          final progress = (1 - left.inMilliseconds / _countdown.inMilliseconds).clamp(0.0, 1.0);
          final seconds = (left.inMilliseconds / 1000).ceil();
          return Card(
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showImage)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FladderImage(image: _image),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(height: 4, color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kicker.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            focusNode: playFocus,
                            onPressed: onPlay,
                            clipBehavior: Clip.antiAlias,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, _buttonHeight),
                              backgroundColor: theme.colorScheme.onSurface,
                              foregroundColor: theme.colorScheme.surface,
                            ),
                            child: SizedBox(
                              height: _buttonHeight,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // The countdown, filling the button towards autoplay.
                                  Positioned.fill(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: ColoredBox(color: theme.colorScheme.primary.withValues(alpha: 0.45)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(IconsaxPlusBold.play, size: 18),
                                        const SizedBox(width: 6),
                                        Text('${l10n.playLabel} · $seconds'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: onDismiss,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, _buttonHeight),
                              fixedSize: const Size.fromHeight(_buttonHeight),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            child: Text(l10n.resumeVideo),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
