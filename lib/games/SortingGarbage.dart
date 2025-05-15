import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SortingGarbageGame extends StatefulWidget {
  const SortingGarbageGame({super.key});

  @override
  SortingGarbageGameState createState() => SortingGarbageGameState();
}

class SortingGarbageGameState extends State<SortingGarbageGame>
    with TickerProviderStateMixin {
  int score = 0;
  int lives = 3;
  bool isInitialSetup = true;
  Map<String, dynamic> currentItem = {};
  Offset itemPosition = Offset.zero;

  final double itemSize = 100.0;
  AnimationController? bounceController;
  bool showIncorrectMessage = false;
  bool gameOver = false;
  bool dragging = false;

  AnimationController? incorrectMessageController;
  Animation<double>? incorrectMessageOpacity;

  final List<Map<String, dynamic>> allItems = [
    {
      'nameKey': 'itemNamePlasticBottle',
      'type': 'plastic',
      'image': 'assets/images/products/plastic_bottle.png'
    },
    {
      'nameKey': 'itemNameGlassBottle',
      'type': 'glass',
      'image': 'assets/images/products/glass_bottle.png'
    },
    {
      'nameKey': 'itemNameNewspaper',
      'type': 'paper',
      'image': 'assets/images/products/newspaper.png'
    },
    {
      'nameKey': 'itemNameCardboard',
      'type': 'paper',
      'image': 'assets/images/products/cardboard.png'
    },
    {
      'nameKey': 'itemNameBanana',
      'type': 'organic',
      'image': 'assets/images/products/banana.png'
    },
    {
      'nameKey': 'itemNameApple',
      'type': 'organic',
      'image': 'assets/images/products/apple.png'
    },
    {
      'nameKey': 'itemNamePlasticBag',
      'type': 'plastic',
      'image': 'assets/images/products/plastic_bag.png'
    },
    {
      'nameKey': 'itemNameTinCan',
      'type': 'metal',
      'image': 'assets/images/products/tin_can.png'
    },
    {
      'nameKey': 'itemNameJarGlass',
      'type': 'glass',
      'image': 'assets/images/products/jar_glass.png'
    },
  ];

  List<Map<String, dynamic>> items = [];

  final GlobalKey plasticBinKey = GlobalKey();
  final GlobalKey paperBinKey = GlobalKey();
  final GlobalKey glassBinKey = GlobalKey();
  final GlobalKey metalBinKey = GlobalKey();
  final GlobalKey organicBinKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.2,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    incorrectMessageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    incorrectMessageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: incorrectMessageController!, curve: Curves.easeInOut));

    startGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInitialSetup && mounted) {
      itemPosition = Offset(
        MediaQuery.of(context).size.width / 2 - itemSize / 2,
        MediaQuery.of(context).size.height * 0.7,
      );
      nextItem();
      isInitialSetup = false;
    }
  }

  @override
  void dispose() {
    bounceController?.dispose();
    incorrectMessageController?.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      score = 0;
      lives = 3;
      gameOver = false;
      showIncorrectMessage = false;
      items = List.from(allItems)..shuffle();
      currentItem = {};
      isInitialSetup = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !gameOver) {
        nextItem();
      }
    });
  }

  void nextItem() {
    if (!mounted) return;

    if (gameOver) return;

    if (lives <= 0) {
      Future.microtask(() =>
          showGameOverDialog(gameOverReasonKey: 'sortingGameOverOutOfLives'));
      return;
    }
    if (items.isEmpty) {
      items = List.from(allItems)..shuffle();
      if (lives <= 0) {
        Future.microtask(() =>
            showGameOverDialog(gameOverReasonKey: 'sortingGameOverOutOfLives'));
        return;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          currentItem = items.removeLast();
          showIncorrectMessage = false;
          itemPosition = Offset(
            MediaQuery.of(context).size.width / 2 - itemSize / 2,
            MediaQuery.of(context).size.height * 0.7,
          );
          dragging = false;
        });
      }
    });
  }

  void showGameOverDialog({String? gameOverReasonKey}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (gameOver) return;
    setState(() => gameOver = true);

    String? localizedReason;
    if (gameOverReasonKey == 'sortingGameOverOutOfLives') {
      localizedReason = l10n.sortingGameOverOutOfLives;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(l10n.gameOverTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.sortingGameOverScore(score)),
              if (localizedReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(localizedReason,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.playAgainButton),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  void checkBin(Offset dropPosition, String binType) {
    if (!mounted) return;

    if (gameOver || currentItem.isEmpty) return;

    GlobalKey? targetKey;
    String? correctItemType;

    switch (binType) {
      case 'plastic':
        targetKey = plasticBinKey;
        correctItemType = 'plastic';
        break;
      case 'paper':
        targetKey = paperBinKey;
        correctItemType = 'paper';
        break;
      case 'glass':
        targetKey = glassBinKey;
        correctItemType = 'glass';
        break;
      case 'metal':
        targetKey = metalBinKey;
        correctItemType = 'metal';
        break;
      case 'organic':
        targetKey = organicBinKey;
        correctItemType = 'organic';
        break;
      case 'wrong_area':
        break;
      default:
        return;
    }

    bool isCorrect = false;
    if (binType != 'wrong_area' &&
        targetKey != null &&
        targetKey.currentContext != null) {
      RenderBox binBox =
          targetKey.currentContext!.findRenderObject() as RenderBox;
      Offset binPosition = binBox.localToGlobal(Offset.zero);
      Rect binRect = binPosition & binBox.size;
      Offset itemCenter = dropPosition;
      isCorrect = currentItem['type'] == correctItemType &&
          binRect.contains(itemCenter);
    } else if (binType == 'wrong_area') {
      isCorrect = false;
    }

    if (isCorrect) {
      setState(() {
        score++;
      });
      nextItem();
    } else {
      setState(() {
        lives--;
      });

      bounceController?.forward().then((_) {
        if (mounted) bounceController?.reverse();
      });

      setState(() => showIncorrectMessage = true);
      incorrectMessageController?.forward().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            incorrectMessageController?.reverse().then((_) {
              if (mounted) setState(() => showIncorrectMessage = false);
            });
          }
        });
      });

      if (lives <= 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          showGameOverDialog(gameOverReasonKey: 'sortingGameOverOutOfLives');
        });
      } else {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && !gameOver) {
            setState(() {
              itemPosition = Offset(
                MediaQuery.of(context).size.width / 2 - itemSize / 2,
                MediaQuery.of(context).size.height * 0.7,
              );
              dragging = false;
            });
          }
        });
      }
    }
  }

  String getLocalizedItemName(AppLocalizations l10n, String nameKey) {
    switch (nameKey) {
      case 'itemNamePlasticBottle':
        return l10n.itemNamePlasticBottle;
      case 'itemNameGlassBottle':
        return l10n.itemNameGlassBottle;
      case 'itemNameNewspaper':
        return l10n.itemNameNewspaper;
      case 'itemNameCardboard':
        return l10n.itemNameCardboard;
      case 'itemNameAluminumCan':
        return l10n.itemNameAluminumCan;
      case 'itemNameBanana':
        return l10n.itemNameBanana;
      case 'itemNameApple':
        return l10n.itemNameApple;
      case 'itemNamePlasticBag':
        return l10n.itemNamePlasticBag;
      case 'itemNameTinCan':
        return l10n.itemNameTinCan;
      case 'itemNameJarGlass':
        return l10n.itemNameJarGlass;
      default:
        return nameKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double binWidth = screenWidth * 0.18;
    double binTopPosition = screenHeight * 0.15;
    double itemStartYPosition = screenHeight * 0.7;

    if (itemPosition == Offset.zero && currentItem.isNotEmpty) {
      itemPosition = Offset(
        screenWidth / 2 - itemSize / 2,
        itemStartYPosition,
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.backButtonTooltip,
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Text(l10n.sortingScore(score),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                  (index) => Icon(
                        index < lives ? Icons.favorite : Icons.favorite_border,
                        color: index < lives
                            ? Colors.red.shade400
                            : Colors.grey.shade400,
                      )),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildTrashBin(
              key: plasticBinKey,
              type: 'plastic',
              label: l10n.sortingBinPlastic,
              left: 10,
              top: binTopPosition,
              width: binWidth,
              color: Colors.deepOrangeAccent),
          _buildTrashBin(
              key: paperBinKey,
              type: 'paper',
              label: l10n.sortingBinPaper,
              left: 10 + binWidth + 5,
              top: binTopPosition,
              width: binWidth,
              color: Colors.blue),
          _buildTrashBin(
              key: glassBinKey,
              type: 'glass',
              label: l10n.sortingBinGlass,
              left: 10 + (binWidth + 5) * 2,
              top: binTopPosition,
              width: binWidth,
              color: Colors.green),
          _buildTrashBin(
              key: metalBinKey,
              type: 'metal',
              label: l10n.sortingBinMetal,
              left: 10 + (binWidth + 5) * 3,
              top: binTopPosition,
              width: binWidth,
              color: Colors.grey),
          _buildTrashBin(
              key: organicBinKey,
              type: 'organic',
              label: l10n.sortingBinOrganic,
              left: 10 + (binWidth + 5) * 4,
              top: binTopPosition,
              width: binWidth,
              color: Colors.brown),
          Positioned(
            top: binTopPosition + 300,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child));
                },
                child: Text(
                    currentItem.isNotEmpty
                        ? getLocalizedItemName(l10n, currentItem['nameKey'])
                        : '',
                    key: ValueKey<String>(currentItem['nameKey'] ??
                        Random().nextDouble().toString()),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ),
            ),
          ),
          if (showIncorrectMessage)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: incorrectMessageOpacity!,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.sortingIncorrectBasket,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ),
          if (currentItem.isNotEmpty && !gameOver)
            Positioned(
              left: itemPosition.dx,
              top: itemPosition.dy,
              child: Draggable<String>(
                data: currentItem['type'],
                feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(currentItem['image'] ?? '',
                        width: itemSize * 1.1, height: itemSize * 1.1)),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: () {
                  if (!gameOver) setState(() => dragging = true);
                },
                onDragEnd: (details) {
                  if (!gameOver) {
                    setState(() => dragging = false);
                    final dropOffset = details.offset;
                    final itemCenterOffset =
                        dropOffset + Offset(itemSize / 2, itemSize / 2);

                    if (_isPointInBin(itemCenterOffset, plasticBinKey)) {
                      checkBin(itemCenterOffset, 'plastic');
                    } else if (_isPointInBin(itemCenterOffset, paperBinKey)) {
                      checkBin(itemCenterOffset, 'paper');
                    } else if (_isPointInBin(itemCenterOffset, glassBinKey)) {
                      checkBin(itemCenterOffset, 'glass');
                    } else if (_isPointInBin(itemCenterOffset, metalBinKey)) {
                      checkBin(itemCenterOffset, 'metal');
                    } else if (_isPointInBin(itemCenterOffset, organicBinKey)) {
                      checkBin(itemCenterOffset, 'organic');
                    } else {
                      checkBin(itemCenterOffset, 'wrong_area');
                    }
                  }
                },
                child: Transform.scale(
                  scale: dragging ? 1.1 : (bounceController?.value ?? 1.0),
                  child: Image.asset(currentItem['image'] ?? '',
                      width: itemSize, height: itemSize),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrashBin(
      {required GlobalKey key,
      required String type,
      required String label,
      double? left,
      double? right,
      required double top,
      required double width,
      required Color color}) {
    final theme = Theme.of(context);
    return Positioned(
      key: key,
      top: top,
      left: left,
      right: right,
      child: SizedBox(
        width: width,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (data) => true,
          builder: (context, candidateData, rejectedData) {
            bool isHovering = candidateData.isNotEmpty;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()..scale(isHovering ? 1.1 : 1.0),
                  transformAlignment: Alignment.center,
                  child: Container(
                    width: 70,
                    height: 90,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isPointInBin(Offset globalPoint, GlobalKey binKey) {
    if (binKey.currentContext == null) return false;
    final RenderBox? renderBox =
        binKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    if (!renderBox.attached) return false;
    final Offset localPoint = renderBox.globalToLocal(globalPoint);
    return renderBox.paintBounds.contains(localPoint);
  }
}
