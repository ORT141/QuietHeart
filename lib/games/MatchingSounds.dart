import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MatchingSoundsGame extends StatefulWidget {
  const MatchingSoundsGame({super.key});

  @override
  MatchingSoundsGameState createState() => MatchingSoundsGameState();
}

class MatchingSoundsGameState extends State<MatchingSoundsGame>
    with TickerProviderStateMixin {
  final List<String> soundAssets = [
    'sounds/cat_meow.mp3',
    'sounds/bird_chirp.mp3',
    'sounds/cow_moo.mp3',
    'sounds/sheep_baa.mp3',
    'sounds/rain.mp3',
    'sounds/wind.mp3',
    'sounds/waves.mp3',
    'sounds/train_whistle.mp3',
    'sounds/bicycle_bell.mp3'
  ];

  final Map<String, String> soundEmojis = {
    'sounds/cat_meow.mp3': '🐱',
    'sounds/bird_chirp.mp3': '🐦',
    'sounds/cow_moo.mp3': '🐄',
    'sounds/sheep_baa.mp3': '🐑',
    'sounds/rain.mp3': '🌧️',
    'sounds/wind.mp3': '🌬️',
    'sounds/waves.mp3': '🌊',
    'sounds/train_whistle.mp3': '🚂',
    'sounds/bicycle_bell.mp3': '🚲',
  };

  late List<String> gameSounds;
  List<Map<String, dynamic>> cards = [];
  int? firstCardIndex;
  int? secondCardIndex;
  bool isProcessing = false;
  int pairsFound = 0;
  final AudioPlayer audioPlayer = AudioPlayer();
  int moves = 0;
  Stopwatch stopwatch = Stopwatch();

  final int numberOfPairs = 8;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    for (var card in cards) {
      card['animationController']?.dispose();
    }
    stopwatch.stop();
    super.dispose();
  }

  void _initGame() {
    int pairsToUse = numberOfPairs.clamp(1, soundAssets.length);

    List<String> availableSounds = [...soundAssets];
    availableSounds.shuffle();

    List<String> selectedSounds = availableSounds.sublist(0, pairsToUse);
    gameSounds = [...selectedSounds, ...selectedSounds];
    gameSounds.shuffle();

    for (var card in cards) {
      card['animationController']?.dispose();
    }

    cards = List.generate(
      gameSounds.length,
      (index) => {
        'index': index,
        'sound': gameSounds[index],
        'isFlipped': false,
        'isMatched': false,
        'animationController': AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      },
    );

    firstCardIndex = null;
    secondCardIndex = null;
    isProcessing = false;
    pairsFound = 0;
    moves = 0;
    stopwatch.reset();
    stopwatch.start();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _playSound(String soundPath) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: l10n.errorPlaySoundGame(e.toString()),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _cardTapped(int index) async {
    if (isProcessing ||
        cards.isEmpty ||
        index >= cards.length ||
        cards[index]['isFlipped'] ||
        cards[index]['isMatched']) {
      return;
    }

    final controller =
        cards[index]['animationController'] as AnimationController?;
    if (controller == null) return;

    if (firstCardIndex == null || secondCardIndex == null) {
      moves++;
    }

    setState(() {
      cards[index]['isFlipped'] = true;
    });
    controller.forward();

    await _playSound(cards[index]['sound']);

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      secondCardIndex = index;
      isProcessing = true;

      if (cards[firstCardIndex!]['sound'] == cards[secondCardIndex!]['sound']) {
        pairsFound++;
        setState(() {
          cards[firstCardIndex!]['isMatched'] = true;
          cards[secondCardIndex!]['isMatched'] = true;
        });

        if (pairsFound == gameSounds.length ~/ 2) {
          stopwatch.stop();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _showGameOverDialog();
          });
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              firstCardIndex = null;
              secondCardIndex = null;
              isProcessing = false;
            });
          }
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted &&
            cards.length > firstCardIndex! &&
            cards.length > secondCardIndex! &&
            !cards[firstCardIndex!]['isMatched'] &&
            !cards[secondCardIndex!]['isMatched']) {
          final controller1 = cards[firstCardIndex!]['animationController']
              as AnimationController?;
          final controller2 = cards[secondCardIndex!]['animationController']
              as AnimationController?;

          setState(() {
            cards[firstCardIndex!]['isFlipped'] = false;
            cards[secondCardIndex!]['isFlipped'] = false;
          });
          controller1?.reverse();
          controller2?.reverse();

          setState(() {
            firstCardIndex = null;
            secondCardIndex = null;
            isProcessing = false;
          });
        } else if (mounted) {
          setState(() {
            isProcessing = false;
            if (cards[firstCardIndex!]['isMatched'] &&
                cards[secondCardIndex!]['isMatched']) {
              firstCardIndex = null;
              secondCardIndex = null;
            }
          });
        }
      }
    }
  }

  void _showGameOverDialog() {
    final l10n = AppLocalizations.of(context)!;
    Duration elapsed = stopwatch.elapsed;
    bool win = pairsFound == gameSounds.length ~/ 2;

    String formattedSeconds =
        (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          title: Text(
            win ? l10n.gameWinTitle : l10n.gameOverTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                win
                    ? l10n.gameOverPairsFoundAll
                    : l10n.gameOverPairsFoundSome(pairsFound),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.gameOverStatsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                l10n.gameOverMoves(moves),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                l10n.gameOverTime(elapsed.inMinutes, formattedSeconds),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(l10n.playAgainButton, style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                _initGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.backButtonTooltip,
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int crossAxisCount = 4;
          double crossAxisSpacing = 10;
          double mainAxisSpacing = 10;

          double childAspectRatio = 0.7;

          double availableWidth = constraints.maxWidth -
              (crossAxisCount - 1) * crossAxisSpacing -
              20;
          double cardWidth = availableWidth / crossAxisCount;

          double iconSize = cardWidth * 0.6;
          double emojiSize = cardWidth * 0.5;

          return Center(
            child: Container(
              width: constraints.maxWidth * 0.95,
              height: constraints.maxHeight * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: cards[index]['animationController'],
                        builder: (context, child) {
                          final double flipValue =
                              cards[index]['animationController'].value;
                          final bool isFront = flipValue < 0.5;

                          return GestureDetector(
                            onTap: () => _cardTapped(index),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(3.141592653589793 * flipValue),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: isFront
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                child: Center(
                                    child: isFront
                                        ? _buildFrontCard(index, iconSize)
                                        : _buildBackCard(index, emojiSize)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Text(
                  'Знайдено пар: $pairsFound / ${gameSounds.length ~/ 2}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text('Ходів: $moves',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(int index, double iconSize) {
    final theme = Theme.of(context);
    if (cards.isEmpty || index >= cards.length) {
      return const SizedBox.shrink();
    }
    final cardData = cards[index];

    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !cardData['isMatched'],
          child: Icon(
            Icons.question_mark_rounded,
            size: iconSize,
            color: theme.colorScheme.onPrimary.withValues(alpha: .8),
          ),
        ),
        if (cardData['isMatched'])
          Container(
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: iconSize * 0.8,
                color: Colors.greenAccent.shade400.withValues(alpha: .9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackCard(int index, double emojiSize) {
    if (cards.isEmpty || index >= cards.length) {
      return const SizedBox.shrink();
    }
    final cardData = cards[index];

    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !cardData['isMatched'],
          child: Text(
            soundEmojis[cardData['sound']] ?? '🎵',
            style: TextStyle(fontSize: emojiSize),
          ),
        ),
        if (cardData['isMatched'])
          Container(
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: emojiSize * 0.8,
                color: Colors.greenAccent.shade400.withValues(alpha: .9),
              ),
            ),
          )
      ],
    );
  }
}
