import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class BreatheWidget extends StatefulWidget {
  const BreatheWidget({super.key});

  @override
  BreatheWidgetState createState() => BreatheWidgetState();
}

enum BreathingPhase { inhale, holdInhale, exhale, holdExhale, idle }

class BreatheWidgetState extends State<BreatheWidget>
    with TickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageRotateAnimation;
  late Animation<double> _imageGlowAnimation;

  late AnimationController _titleAnimationController;
  late Animation<Offset> _titleSlideAnimation;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  late AnimationController _videoAnimationController;
  late Animation<double> _videoFadeAnimation;

  bool isBreathing = false;
  VideoPlayerController? controller;
  ChewieController? chewieController;
  Future<void>? initializeVideoPlayerFuture;

  BreathingPhase _currentPhase = BreathingPhase.idle;

  final int _inhaleHoldDuration = 3;
  final int _exhaleHoldDuration = 3;

  final List<String> _videoAssets = [
    'assets/videos/cube.mp4',
    'assets/videos/hand.mp4',
  ];

  final Map<int, String> _videoNameKeys = {
    0: 'breatheVideoNameCube',
    1: 'breatheVideoNameHand',
  };

  final Map<int, Icon> _videoIcons = {
    0: const Icon(Icons.token),
    1: const Icon(Icons.volunteer_activism),
  };

  int _selectedVideoIndex = 0;

  @override
  void initState() {
    super.initState();

    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _imageScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
          parent: _imageAnimationController, curve: Curves.easeInOut),
    );

    _imageRotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
          parent: _imageAnimationController, curve: Curves.easeInOut),
    );

    _imageGlowAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(
          parent: _imageAnimationController, curve: Curves.easeInOut),
    );

    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    ));

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeIn),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _buttonAnimationController, curve: Curves.elasticOut),
    );

    _videoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _videoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _videoAnimationController, curve: Curves.easeIn),
    );

    _imageAnimationController.addStatusListener(_animationStatusListener);
    _titleAnimationController.forward();
    _buttonAnimationController.forward();
  }

  String getLocalizedVideoName(AppLocalizations l10n, int index) {
    final key = _videoNameKeys[index];
    switch (key) {
      case 'breatheVideoNameCube':
        return l10n.breatheVideoNameCube;
      case 'breatheVideoNameHand':
        return l10n.breatheVideoNameHand;
      default:
        return l10n.breatheVideoNameUnknown;
    }
  }

  void _animationStatusListener(AnimationStatus status) {
    if (!isBreathing) return;

    if (status == AnimationStatus.completed) {
      if (_currentPhase == BreathingPhase.inhale) {
        _currentPhase = BreathingPhase.holdInhale;
        Future.delayed(Duration(seconds: _inhaleHoldDuration), () {
          if (mounted &&
              isBreathing &&
              _currentPhase == BreathingPhase.holdInhale) {
            _currentPhase = BreathingPhase.exhale;
            _imageAnimationController.reverse();
          }
        });
      }
    } else if (status == AnimationStatus.dismissed) {
      if (_currentPhase == BreathingPhase.exhale) {
        _currentPhase = BreathingPhase.holdExhale;
        Future.delayed(Duration(seconds: _exhaleHoldDuration), () {
          if (mounted &&
              isBreathing &&
              _currentPhase == BreathingPhase.holdExhale) {
            _currentPhase = BreathingPhase.inhale;
            _imageAnimationController.forward();
          }
        });
      }
    }
  }

  void _loadVideo(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (controller != null) {
      controller!.dispose();
      controller = null;
    }
    if (chewieController != null) {
      chewieController!.dispose();
      chewieController = null;
    }
    setState(() {
      initializeVideoPlayerFuture = null;
    });

    controller = VideoPlayerController.asset(_videoAssets[index]);

    initializeVideoPlayerFuture = controller!.initialize().then((_) {
      if (!mounted) return;
      chewieController = ChewieController(
          videoPlayerController: controller!,
          autoPlay: true,
          looping: true,
          allowFullScreen: false,
          aspectRatio: controller!.value.aspectRatio,
          showControls: false,
          showOptions: false,
          allowPlaybackSpeedChanging: false);
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: l10n.errorLoadingVideo(error.toString()),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      if (mounted) {
        setState(() {
          isBreathing = false;
          _currentPhase = BreathingPhase.idle;
          initializeVideoPlayerFuture = null;
          controller?.dispose();
          controller = null;
          chewieController = null;
        });
        _videoAnimationController.reverse();
        _imageAnimationController.reset();
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  void startBreathing() {
    if (initializeVideoPlayerFuture != null) return;

    _loadVideo(_selectedVideoIndex);

    setState(() {
      isBreathing = true;
      _currentPhase = BreathingPhase.inhale;
    });

    _videoAnimationController.forward();

    initializeVideoPlayerFuture?.then((_) {
      if (mounted && isBreathing) {
        _imageAnimationController.forward();
      }
    }).catchError((_) {});
  }

  void stopBreathing() {
    chewieController?.pause();
    controller?.pause();

    setState(() {
      isBreathing = false;
      _currentPhase = BreathingPhase.idle;
      chewieController?.dispose();
      controller?.dispose();
      chewieController = null;
      controller = null;
      initializeVideoPlayerFuture = null;
    });

    _videoAnimationController.reverse();
    _imageAnimationController.reset();
  }

  @override
  void dispose() {
    _imageAnimationController.removeStatusListener(_animationStatusListener);
    _imageAnimationController.dispose();
    _titleAnimationController.dispose();
    _buttonAnimationController.dispose();
    _videoAnimationController.dispose();
    controller?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        double imageWidth = isLargeScreen ? 200.0 : 150.0;
        double titleFontSize = isLargeScreen ? 36.0 : 28.0;
        double buttonFontSize = isLargeScreen ? 18.0 : 16.0;
        double verticalPadding = isLargeScreen ? 30.0 : 20.0;
        double dropdownWidth =
            constraints.maxWidth > 400 ? 400 : constraints.maxWidth * 0.8;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: verticalPadding),
                  AnimatedBuilder(
                    animation: _imageAnimationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isBreathing)
                            Container(
                              width: imageWidth * 1.5,
                              height: imageWidth * 1.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(_imageGlowAnimation.value),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          Transform.scale(
                            scale: _imageScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _imageRotateAnimation.value,
                              child: child,
                            ),
                          ),
                        ],
                      );
                    },
                    child: SizedBox(
                      width: imageWidth,
                      height: imageWidth,
                      child: Image.asset(
                        theme.brightness == Brightness.dark
                            ? 'assets/images/breathe_black.png'
                            : 'assets/images/breathe_white.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: Center(
                      child: Text(
                        l10n.tabBreathe,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  if (!isBreathing) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_videoAssets.length <= 3) ...[
                            Center(
                              child: SegmentedButton<int>(
                                segments:
                                    _videoAssets.asMap().entries.map((entry) {
                                  return ButtonSegment<int>(
                                    value: entry.key,
                                    label: Text(
                                        getLocalizedVideoName(l10n, entry.key)),
                                    icon: _videoIcons[entry.key],
                                  );
                                }).toList(),
                                selected: {_selectedVideoIndex},
                                onSelectionChanged: (Set<int> selection) {
                                  setState(() {
                                    _selectedVideoIndex = selection.first;
                                  });
                                },
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedBackgroundColor: theme
                                      .colorScheme.primary
                                      .withOpacity(0.1),
                                  selectedForegroundColor:
                                      theme.colorScheme.primary,
                                ),
                                showSelectedIcon: false,
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: dropdownWidth,
                              child: DropdownButtonFormField2<int>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  labelText: l10n.breatheSelectVideoHint,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                ),
                                value: _selectedVideoIndex,
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.only(right: 8),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                items:
                                    _videoAssets.asMap().entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Semantics(
                                      label:
                                          '${getLocalizedVideoName(l10n, entry.key)} video option',
                                      child: Text(
                                        getLocalizedVideoName(l10n, entry.key),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null &&
                                      newValue != _selectedVideoIndex) {
                                    setState(() {
                                      _selectedVideoIndex = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: verticalPadding),
                  ],
                  AnimatedBuilder(
                    animation: _buttonAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _buttonScaleAnimation.value,
                        child: Opacity(
                          opacity: _buttonFadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: ElevatedButton.icon(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Icon(
                          isBreathing
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey<bool>(isBreathing),
                          color: isBreathing
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        if (isBreathing) {
                          stopBreathing();
                        } else {
                          startBreathing();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBreathing
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        foregroundColor: isBreathing
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: isBreathing
                            ? theme.colorScheme.error.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      label: Text(
                        isBreathing
                            ? l10n.breatheStopButton
                            : l10n.breatheStartButton,
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FadeTransition(
                      opacity: _videoFadeAnimation,
                      child: Visibility(
                        visible: isBreathing,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FutureBuilder(
                              future: initializeVideoPlayerFuture,
                              builder: (context, snapshot) {
                                double containerWidth =
                                    constraints.maxWidth * 0.9;
                                double maxHeight = constraints.maxHeight * 0.5;

                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    initializeVideoPlayerFuture == null) {
                                  double progressIndicatorSize =
                                      isLargeScreen ? 150 : 100;
                                  return SizedBox(
                                    height: maxHeight,
                                    width: containerWidth,
                                    child: Center(
                                        child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: progressIndicatorSize / 2,
                                          height: progressIndicatorSize / 2,
                                          child: CircularProgressIndicator(
                                            color: theme.colorScheme.primary,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.loading,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    )),
                                  );
                                } else if (snapshot.hasError ||
                                    controller == null ||
                                    !controller!.value.isInitialized ||
                                    chewieController == null) {
                                  return Container(
                                    width: containerWidth,
                                    height: maxHeight,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.errorContainer
                                            .withValues(alpha: .1),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                            color: theme.colorScheme.error
                                                .withValues(alpha: .3))),
                                    child: Center(
                                        child: Text(
                                      l10n.errorLoadingVideo(
                                          snapshot.error?.toString() ??
                                              l10n.unknownError),
                                      style: TextStyle(
                                          color: theme.colorScheme.error),
                                      textAlign: TextAlign.center,
                                    )),
                                  );
                                } else {
                                  double aspectRatio =
                                      controller!.value.aspectRatio;
                                  double videoHeight =
                                      containerWidth / aspectRatio;
                                  if (videoHeight > maxHeight) {
                                    videoHeight = maxHeight;
                                    containerWidth = videoHeight * aspectRatio;
                                  }

                                  return Center(
                                      child: SizedBox(
                                    width: containerWidth,
                                    height: videoHeight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child:
                                          Chewie(controller: chewieController!),
                                    ),
                                  ));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
