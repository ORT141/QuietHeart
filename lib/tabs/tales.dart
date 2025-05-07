import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../tales.dart';

class TalesWidget extends StatefulWidget {
  const TalesWidget({super.key});

  @override
  TalesWidgetState createState() => TalesWidgetState();
}

class TalesWidgetState extends State<TalesWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<String> currentSlideshowImages = ['assets/images/music_dark.png'];
  int currentImageIndex = 0;
  late final AnimationController slideShowAnimationController;
  Timer? imageChangeTimer;
  AudioPlayer? currentAudioPlayer;
  final ScrollController scrollController = ScrollController();
  late List<Tale> sortedTales;
  String? lastPlayedTaleTitleKey;

  late AnimationController _titleController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late AnimationController _slideshowController;
  late Animation<double> _slideshowFadeAnimation;
  late Animation<Offset> _slideshowSlideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sortedTales = List.from(tales);
    _updateThemeBasedDefaultImages();

    slideShowAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    imageChangeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (lastPlayedTaleTitleKey != null && currentSlideshowImages.length > 1) {
        _updateSlideshowImageIndex();
      }
    });

    _titleController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _titleController, curve: Curves.easeIn));
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _titleController.forward();

    _slideshowController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideshowFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _slideshowController, curve: Curves.easeIn));
    _slideshowSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideshowController, curve: Curves.easeOut));
    _slideshowController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (lastPlayedTaleTitleKey == null) {
      _updateThemeBasedDefaultImages();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (lastPlayedTaleTitleKey == null) {
        _updateThemeBasedDefaultImages();
      }
    }
  }

  void _updateThemeBasedDefaultImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        setState(() {
          if (lastPlayedTaleTitleKey == null) {
            currentSlideshowImages = [
              isDark
                  ? 'assets/images/music_dark.png'
                  : 'assets/images/music_light.png'
            ];
            currentImageIndex = 0;
          }
        });
      }
    });
  }

  void _updateSlideshowImageIndex() {
    if (currentSlideshowImages.length > 1 && mounted) {
      setState(() {
        currentImageIndex =
            (currentImageIndex + 1) % currentSlideshowImages.length;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    slideShowAnimationController.dispose();
    imageChangeTimer?.cancel();
    currentAudioPlayer?.dispose();
    scrollController.dispose();
    _titleController.dispose();
    _slideshowController.dispose();
    super.dispose();
  }

  void updateSlideshowImages(Tale? tale) {
    if (!mounted) return;

    setState(() {
      if (tale != null) {
        if (lastPlayedTaleTitleKey != tale.titleKey) {
          currentSlideshowImages = List.generate(
              4,
              (index) =>
                  'assets/tales/${tale.originalIndex + 1}/${index + 1}.jpg');
          currentImageIndex = 0;
          lastPlayedTaleTitleKey = tale.titleKey;
          sortTales();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            }
          });
        }
      } else {
        lastPlayedTaleTitleKey = null;
        _updateThemeBasedDefaultImages();
      }
    });
  }

  void sortTales() {
    if (lastPlayedTaleTitleKey != null) {
      final index =
          sortedTales.indexWhere((t) => t.titleKey == lastPlayedTaleTitleKey);
      if (index != -1) {
        final Tale lastPlayedTale = sortedTales.removeAt(index);
        sortedTales.insert(0, lastPlayedTale);
      }
    }
  }

  Widget _buildSlideshowTransition(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Transform.scale(
            scale: Tween<double>(begin: 0.9, end: 1.0)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutBack))
                .value,
            child: Transform.translate(
              offset: Offset(
                0.0,
                Tween<double>(begin: 20.0, end: 0.0)
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOutBack))
                    .value,
              ),
              child: Opacity(
                opacity: animation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  void playAudio(Tale tale, AudioPlayer audioPlayer) async {
    if (currentAudioPlayer != null && currentAudioPlayer != audioPlayer) {
      await currentAudioPlayer!.stop();
    }

    currentAudioPlayer = audioPlayer;

    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.pause();
    } else {
      try {
        final locale = Localizations.localeOf(context).languageCode;
        String audioPath = 'tales/${tale.originalIndex + 1}';

        if (locale == 'en') {
          audioPath += '_en';
        }

        if (locale == "he") {
          audioPath += '_he';
        }

        await audioPlayer.play(AssetSource('$audioPath.mp3'));
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.errorPlaySoundGame(e.toString())),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double imageWidth = constraints.maxWidth > 600 ? 400 : 300;
      double titleFontSize = constraints.maxWidth > 600 ? 40 : 32;
      double taleTitleFontSize = constraints.maxWidth > 600 ? 24 : 20;
      double taleAuthorFontSize = constraints.maxWidth > 600 ? 16 : 14;
      double iconSize = constraints.maxWidth > 600 ? 44 : 38;
      double verticalPadding = constraints.maxWidth > 600 ? 30 : 20;

      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(height: verticalPadding),
            SlideTransition(
              position: _slideshowSlideAnimation,
              child: FadeTransition(
                opacity: _slideshowFadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      transitionBuilder: _buildSlideshowTransition,
                      child: Image.asset(
                        key: ValueKey<String>(currentSlideshowImages[
                            currentImageIndex % currentSlideshowImages.length]),
                        currentSlideshowImages[
                            currentImageIndex % currentSlideshowImages.length],
                        width: imageWidth,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            width: imageWidth,
                            height: imageWidth * 0.6,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[600])),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalPadding),
            SlideTransition(
              position: _titleSlideAnimation,
              child: FadeTransition(
                opacity: _titleFadeAnimation,
                child: Text(l10n.talesTitle,
                    style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(1, 1),
                          ),
                        ])),
              ),
            ),
            SizedBox(height: verticalPadding),
            ...sortedTales.map((tale) {
              int displayIndex = sortedTales.indexOf(tale);
              return AnimatedTaleBox(
                key: ValueKey(tale.titleKey),
                tale: tale,
                delay: displayIndex * 150,
                onPlayStateChanged: updateSlideshowImages,
                playAudio: playAudio,
                taleTitleFontSize: taleTitleFontSize,
                taleAuthorFontSize: taleAuthorFontSize,
                iconSize: iconSize,
                isDark: isDark,
              );
            }),
            SizedBox(height: verticalPadding * 2),
          ],
        ),
      );
    });
  }
}

class AnimatedTaleBox extends StatefulWidget {
  final Tale tale;
  final int delay;
  final Function(Tale?) onPlayStateChanged;
  final Function(Tale, AudioPlayer) playAudio;
  final double taleTitleFontSize;
  final double taleAuthorFontSize;
  final double iconSize;
  final bool isDark;

  const AnimatedTaleBox({
    super.key,
    required this.tale,
    required this.delay,
    required this.onPlayStateChanged,
    required this.playAudio,
    required this.taleTitleFontSize,
    required this.taleAuthorFontSize,
    required this.iconSize,
    required this.isDark,
  });

  @override
  AnimatedTaleBoxState createState() => AnimatedTaleBoxState();
}

class AnimatedTaleBoxState extends State<AnimatedTaleBox>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut)));

    rotateAnimation = Tween<double>(begin: 0.02, end: 0.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.translate(
            offset: slideAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Transform.rotate(
                angle: rotateAnimation.value,
                child: TaleBox(
                  tale: widget.tale,
                  onPlayStateChanged: widget.onPlayStateChanged,
                  playAudio: widget.playAudio,
                  taleTitleFontSize: widget.taleTitleFontSize,
                  taleAuthorFontSize: widget.taleAuthorFontSize,
                  iconSize: widget.iconSize,
                  isDark: widget.isDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TaleBox extends StatefulWidget {
  final Tale tale;
  final Function(Tale?) onPlayStateChanged;
  final Function(Tale, AudioPlayer) playAudio;
  final double taleTitleFontSize;
  final double taleAuthorFontSize;
  final double iconSize;
  final bool isDark;

  const TaleBox({
    super.key,
    required this.tale,
    required this.onPlayStateChanged,
    required this.playAudio,
    required this.taleTitleFontSize,
    required this.taleAuthorFontSize,
    required this.iconSize,
    required this.isDark,
  });

  @override
  TaleBoxState createState() => TaleBoxState();
}

class TaleBoxState extends State<TaleBox> with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AudioPlayer audioPlayer;
  double sliderValue = 0.0;

  late AnimationController _playPauseController;
  late Animation<double> _playPauseAnimation;
  late Animation<double> _bobbleAnimation;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _setupAudioListeners();

    _playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _playPauseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
            parent: _playPauseController, curve: Curves.elasticOut));

    _bobbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _playPauseController,
            curve: const Interval(0.3, 0.7, curve: Curves.bounceOut)));
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    audioPlayer.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      try {
        final bool currentlyPlaying = state == PlayerState.playing;
        if (isPlaying != currentlyPlaying) {
          setState(() => isPlaying = currentlyPlaying);
          if (currentlyPlaying) {
            widget.onPlayStateChanged(widget.tale);
            _playPauseController.forward(from: 0.0);
          } else {
            widget.onPlayStateChanged(null);
            _playPauseController.reverse();
          }
        }
        if (state == PlayerState.completed) {
          setState(() {
            position = duration;
            sliderValue = 1.0;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !isPlaying) {
              setState(() {
                position = Duration.zero;
                sliderValue = 0.0;
              });
            }
          });
        }
      } catch (e) {
        if (e.toString().contains('disposed')) {
        } else {
          rethrow;
        }
      }
    });

    _durationSubscription = audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;

      try {
        setState(() => duration = newDuration);
      } catch (e) {
        if (!e.toString().contains('disposed')) {
          rethrow;
        }
      }
    });

    _positionSubscription = audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;

      try {
        setState(() {
          position = newPosition;
          sliderValue = (duration.inSeconds > 0)
              ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
              : 0.0;
        });
      } catch (e) {
        if (!e.toString().contains('disposed')) {
          rethrow;
        }
      }
    });
  }

  void _handlePlayPauseTap() {
    widget.playAudio(widget.tale, audioPlayer);
  }

  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String getLocalizedTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'tale1Title':
        return l10n.tale1Title;
      case 'tale2Title':
        return l10n.tale2Title;
      case 'tale3Title':
        return l10n.tale3Title;
      default:
        return key;
    }
  }

  String getLocalizedAuthor(AppLocalizations l10n, String key) {
    switch (key) {
      case 'tale1Author':
        return l10n.tale1Author;
      case 'tale2Author':
        return l10n.tale2Author;
      case 'tale3Author':
        return l10n.tale3Author;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPlaying
              ? [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.2),
                ]
              : [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surfaceContainerHigh,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.shadowColor.withOpacity(0.1),
            spreadRadius: isPlaying ? 2 : 1,
            blurRadius: isPlaying ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: isPlaying
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isPlaying)
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getLocalizedTitle(l10n, widget.tale.titleKey),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: widget.taleTitleFontSize,
                                color: isPlaying
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                shadows: isPlaying
                                    ? [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.3),
                                          offset: const Offset(1, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              getLocalizedAuthor(l10n, widget.tale.authorKey),
                              style: TextStyle(
                                fontSize: widget.taleAuthorFontSize,
                                color: isPlaying
                                    ? theme.colorScheme.primary.withOpacity(0.7)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildPlayPauseButton(theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(theme),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position),
                            style: TextStyle(
                                fontSize: 12,
                                color: isPlaying
                                    ? theme.colorScheme.primary.withOpacity(0.8)
                                    : theme.colorScheme.onSurfaceVariant)),
                        Text(_formatDuration(duration),
                            style: TextStyle(
                                fontSize: 12,
                                color: isPlaying
                                    ? theme.colorScheme.primary.withOpacity(0.8)
                                    : theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DecorativeElements(
              isPlaying: isPlaying,
              size: const Size(double.infinity, 120),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _playPauseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _playPauseAnimation.value,
          child: Transform.translate(
            offset:
                Offset(0, -4 * _bobbleAnimation.value * (isPlaying ? 1 : 0)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _handlePlayPauseTap,
          customBorder: const CircleBorder(),
          splashColor: theme.colorScheme.primary.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlaying
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : theme.colorScheme.primaryContainer.withOpacity(0.3),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              size: widget.iconSize,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: isPlaying
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.7),
        inactiveTrackColor: isPlaying
            ? theme.colorScheme.primary.withOpacity(0.3)
            : theme.colorScheme.primary.withOpacity(0.2),
        thumbColor: theme.colorScheme.primary,
        overlayColor: theme.colorScheme.primary.withOpacity(0.2),
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: isPlaying ? 10 : 7,
          disabledThumbRadius: 6,
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: isPlaying ? 20 : 14,
        ),
        trackHeight: isPlaying ? 6.0 : 4.0,
        trackShape: RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        min: 0.0,
        max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
        value: sliderValue *
            (duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0),
        onChanged: (value) async {
          if (duration.inSeconds > 0) {
            final newPosition = Duration(seconds: value.toInt());
            await audioPlayer.seek(newPosition);
            setState(() {
              position = newPosition;
              sliderValue = value / duration.inSeconds.toDouble();
            });
          }
        },
      ),
    );
  }
}

class FloatingElement extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double left;
  final double top;
  final double maxHorizontalDeviation;
  final double maxVerticalDeviation;
  final Duration duration;

  const FloatingElement({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    required this.left,
    required this.top,
    this.maxHorizontalDeviation = 20.0,
    this.maxVerticalDeviation = 30.0,
    this.duration = const Duration(seconds: 3),
  });

  @override
  FloatingElementState createState() => FloatingElementState();
}

class FloatingElementState extends State<FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _verticalAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    final random = math.Random();
    final horizontalTween = Tween<double>(
      begin: -widget.maxHorizontalDeviation,
      end: widget.maxHorizontalDeviation,
    );
    final verticalTween = Tween<double>(
      begin: -widget.maxVerticalDeviation,
      end: 0,
    );

    _horizontalAnimation = horizontalTween.animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _verticalAnimation = verticalTween.animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: random.nextInt(1000)), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.left + _horizontalAnimation.value,
          top: widget.top + _verticalAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                widget.icon,
                color: widget.color.withOpacity(0.7),
                size: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DecorativeElements extends StatelessWidget {
  final bool isPlaying;
  final Size size;
  final Color color;

  const DecorativeElements({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return const SizedBox.shrink();

    final random = math.Random();
    final List<Widget> elements = [];

    final icons = [
      Icons.star_rounded,
      Icons.music_note_rounded,
      Icons.auto_awesome,
      Icons.emoji_emotions_rounded,
    ];

    for (int i = 0; i < 6; i++) {
      elements.add(
        FloatingElement(
          icon: icons[random.nextInt(icons.length)],
          color: color,
          size: random.nextDouble() * 10 + 15,
          left: random.nextDouble() * size.width * 0.8,
          top: random.nextDouble() * 60 + 10,
          duration: Duration(seconds: random.nextInt(2) + 3),
        ),
      );
    }

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(children: elements),
    );
  }
}
