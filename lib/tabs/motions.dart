import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class MotionsWidget extends StatefulWidget {
  const MotionsWidget({super.key});

  @override
  MotionsWidgetState createState() => MotionsWidgetState();
}

class MotionsWidgetState extends State<MotionsWidget>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late Animation<Offset> _titleSlideAnimation;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  late AnimationController _videoAnimationController;
  late Animation<double> _videoFadeAnimation;

  bool isPlaying = false;
  VideoPlayerController? controller;
  ChewieController? chewieController;
  Future<void>? initializeVideoPlayerFuture;

  final List<String> _videoAssetsBase = [
    'assets/videos/dog.mp4',
    'assets/videos/heart.mp4'
  ];

  final Map<int, String> _videoNameKeys = {
    0: 'motionVideoNameDog',
    1: 'motionVideoNameHeart'
  };

  final Map<int, Icon> _videoIcons = {
    0: const Icon(Icons.pets),
    1: const Icon(Icons.favorite),
  };

  int _selectedVideoIndex = 0;

  @override
  void initState() {
    super.initState();

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

    _titleAnimationController.forward();
    _buttonAnimationController.forward();
  }

  String getLocalizedVideoName(AppLocalizations l10n, int index) {
    final key = _videoNameKeys[index];
    switch (key) {
      case 'motionVideoNameDog':
        return l10n.motionVideoNameDog;
      case 'motionVideoNameHeart':
        return l10n.motionVideoNameHeart;
      default:
        return l10n.motionVideoNameUnknown;
    }
  }

  String _getLanguageSpecificAssetPath(
      BuildContext context, String baseAssetPath) {
    final locale = Localizations.localeOf(context).languageCode;
    String suffix = '';
    if (locale == 'en') {
      suffix = '_en';
    } else if (locale == 'he') {
      suffix = '_he';
    }

    if (suffix.isEmpty) {
      return baseAssetPath;
    }

    int dotIndex = baseAssetPath.lastIndexOf('.');
    if (dotIndex == -1) {
      return baseAssetPath;
    }
    String name = baseAssetPath.substring(0, dotIndex);
    String extension = baseAssetPath.substring(dotIndex);
    return '$name$suffix$extension';
  }

  void _loadVideo(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (controller != null) {
      controller!.dispose();
    }
    if (chewieController != null) {
      chewieController!.dispose();
    }

    final String baseAssetPath = _videoAssetsBase[index];
    final String localizedAssetPath =
        _getLanguageSpecificAssetPath(context, baseAssetPath);

    controller = VideoPlayerController.asset(localizedAssetPath);

    initializeVideoPlayerFuture = controller!.initialize().then((_) {
      if (!mounted) return;
      chewieController = ChewieController(
          videoPlayerController: controller!,
          autoPlay: true,
          looping: true,
          allowFullScreen: false,
          aspectRatio: controller!.value.aspectRatio,
          showControlsOnInitialize: false,
          allowPlaybackSpeedChanging: false);
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: l10n.errorLoadingVideo(error.toString()),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        isPlaying = false;
        initializeVideoPlayerFuture = null;
      });
    });

    setState(() {});
  }

  void startVideo() async {
    if (initializeVideoPlayerFuture != null) return;

    _loadVideo(_selectedVideoIndex);

    setState(() {
      isPlaying = true;
    });

    _videoAnimationController.forward();
  }

  void stopPlaying() {
    chewieController?.pause();
    controller?.pause();
    controller?.seekTo(Duration.zero);

    setState(() {
      isPlaying = false;
      chewieController?.dispose();
      controller?.dispose();
      chewieController = null;
      controller = null;
      initializeVideoPlayerFuture = null;
    });
    _videoAnimationController.reverse();
  }

  @override
  void dispose() {
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
        double titleFontSize = constraints.maxWidth > 600 ? 36.0 : 28.0;
        double buttonFontSize = constraints.maxWidth > 600 ? 18.0 : 16.0;
        double verticalPadding = constraints.maxWidth > 600 ? 30.0 : 20.0;
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
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: Center(
                      child: Text(
                        l10n.tabMotions,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  if (!isPlaying) ...[
                    if (_videoAssetsBase.length <= 3) ...[
                      Center(
                        child: SegmentedButton<int>(
                          segments:
                              _videoAssetsBase.asMap().entries.map((entry) {
                            return ButtonSegment<int>(
                              value: entry.key,
                              label:
                                  Text(getLocalizedVideoName(l10n, entry.key)),
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
                            selectedBackgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            selectedForegroundColor: theme.colorScheme.primary,
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
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                                _videoAssetsBase.asMap().entries.map((entry) {
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
                          )),
                    ],
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
                          isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey<bool>(isPlaying),
                          color: isPlaying
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          stopPlaying();
                        } else {
                          startVideo();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPlaying
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        foregroundColor: isPlaying
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: isPlaying
                            ? theme.colorScheme.error.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      label: Text(
                        isPlaying
                            ? l10n.motionStopButton
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
                        visible: isPlaying,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: FutureBuilder(
                          future: initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.connectionState ==
                                    ConnectionState.active) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error loading video: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (controller != null &&
                                  controller!.value.isInitialized) {
                                double videoWidth = constraints.maxWidth * 0.8;
                                double videoHeight =
                                    videoWidth / controller!.value.aspectRatio;

                                if (constraints.maxWidth <= 600 &&
                                    videoHeight > constraints.maxHeight * 0.6) {
                                  videoHeight = constraints.maxHeight * 0.6;
                                  videoWidth = videoHeight *
                                      controller!.value.aspectRatio;
                                }
                                if (constraints.maxWidth > 600 &&
                                    videoHeight > constraints.maxHeight * 0.7) {
                                  videoHeight = constraints.maxHeight * 0.7;
                                  videoWidth = videoHeight *
                                      controller!.value.aspectRatio;
                                }

                                return Center(
                                  child: SizedBox(
                                    width: videoWidth,
                                    height: videoHeight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child:
                                          Chewie(controller: chewieController!),
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: Text(
                                        'Video player could not be initialized.'));
                              }
                            }

                            return const Center(
                                child: CircularProgressIndicator());
                          },
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
