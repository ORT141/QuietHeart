import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SortingGroceriesGame extends StatefulWidget {
  const SortingGroceriesGame({super.key});

  @override
  SortingGroceriesGameState createState() => SortingGroceriesGameState();
}

class SortingGroceriesGameState extends State<SortingGroceriesGame>
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
      'nameKey': 'itemNameCarrot',
      'type': 'vegetable',
      'image': 'assets/images/products/carrot.png'
    },
    {
      'nameKey': 'itemNameBanana',
      'type': 'fruit',
      'image': 'assets/images/products/banana.png'
    },
    {
      'nameKey': 'itemNameApple',
      'type': 'fruit',
      'image': 'assets/images/products/apple.png'
    },
    {
      'nameKey': 'itemNameTomato',
      'type': 'vegetable',
      'image': 'assets/images/products/tomato.png'
    },
    {
      'nameKey': 'itemNameGrapes',
      'type': 'berry',
      'image': 'assets/images/products/grapes.png'
    },
    {
      'nameKey': 'itemNameCucumber',
      'type': 'vegetable',
      'image': 'assets/images/products/cucumber.png'
    },
    {
      'nameKey': 'itemNameOrange',
      'type': 'fruit',
      'image': 'assets/images/products/orange.png'
    },
    {
      'nameKey': 'itemNamePotato',
      'type': 'vegetable',
      'image': 'assets/images/products/potato.png'
    },
    {
      'nameKey': 'itemNameStrawberry',
      'type': 'berry',
      'image': 'assets/images/products/strawberry.png'
    },
    {
      'nameKey': 'itemNameRaspberry',
      'type': 'berry',
      'image': 'assets/images/products/raspberry.png'
    },
  ];

  List<Map<String, dynamic>> items = [];

  final GlobalKey fruitBasketKey = GlobalKey();
  final GlobalKey vegetableBasketKey = GlobalKey();
  final GlobalKey berryBasketKey = GlobalKey();

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

  void checkBasket(Offset dropPosition, String basketType) {
    if (!mounted) return;

    if (gameOver || currentItem.isEmpty) return;

    GlobalKey? targetKey;
    String? correctItemType;

    switch (basketType) {
      case 'fruit':
        targetKey = fruitBasketKey;
        correctItemType = 'fruit';
        break;
      case 'vegetable':
        targetKey = vegetableBasketKey;
        correctItemType = 'vegetable';
        break;
      case 'berry':
        targetKey = berryBasketKey;
        correctItemType = 'berry';
        break;
      case 'wrong_area':
        break;
      default:
        return;
    }

    bool isCorrect = false;
    if (basketType != 'wrong_area' &&
        targetKey != null &&
        targetKey.currentContext != null) {
      RenderBox basketBox =
          targetKey.currentContext!.findRenderObject() as RenderBox;
      Offset basketPosition = basketBox.localToGlobal(Offset.zero);
      Rect basketRect = basketPosition & basketBox.size;
      Offset itemCenter = dropPosition;
      isCorrect = currentItem['type'] == correctItemType &&
          basketRect.contains(itemCenter);
    } else if (basketType == 'wrong_area') {
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
      case 'itemNameCarrot':
        return l10n.itemNameCarrot;
      case 'itemNameBanana':
        return l10n.itemNameBanana;
      case 'itemNameApple':
        return l10n.itemNameApple;
      case 'itemNameTomato':
        return l10n.itemNameTomato;
      case 'itemNameGrapes':
        return l10n.itemNameGrapes;
      case 'itemNameCucumber':
        return l10n.itemNameCucumber;
      case 'itemNameOrange':
        return l10n.itemNameOrange;
      case 'itemNamePotato':
        return l10n.itemNamePotato;
      case 'itemNameStrawberry':
        return l10n.itemNameStrawberry;
      case 'itemNameRaspberry':
        return l10n.itemNameRaspberry;
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
    double basketWidth = (screenWidth - 60) / 3;
    double basketTopPosition = screenHeight * 0.15;
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
          _buildBasket(
              key: fruitBasketKey,
              type: 'fruit',
              label: l10n.sortingBasketFruit,
              left: 20,
              top: basketTopPosition,
              width: basketWidth),
          _buildBasket(
              key: vegetableBasketKey,
              type: 'vegetable',
              label: l10n.sortingBasketVegetable,
              left: 20 + basketWidth + 10,
              top: basketTopPosition,
              width: basketWidth),
          _buildBasket(
              key: berryBasketKey,
              type: 'berry',
              label: l10n.sortingBasketBerry,
              right: 20,
              top: basketTopPosition,
              width: basketWidth),
          Positioned(
            top: basketTopPosition + 150,
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
                          color: Colors.redAccent.withValues(alpha: .8),
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

                    if (_isPointInBasket(itemCenterOffset, fruitBasketKey)) {
                      checkBasket(itemCenterOffset, 'fruit');
                    } else if (_isPointInBasket(
                        itemCenterOffset, vegetableBasketKey)) {
                      checkBasket(itemCenterOffset, 'vegetable');
                    } else if (_isPointInBasket(
                        itemCenterOffset, berryBasketKey)) {
                      checkBasket(itemCenterOffset, 'berry');
                    } else {
                      checkBasket(itemCenterOffset, 'wrong_area');
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

  Widget _buildBasket(
      {required GlobalKey key,
      required String type,
      required String label,
      double? left,
      double? right,
      required double top,
      required double width}) {
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
                    transform: Matrix4.identity()
                      ..scale(isHovering ? 1.1 : 1.0),
                    transformAlignment: Alignment.center,
                    child: Image.asset('assets/images/basket.png',
                        width: 100, height: 100)),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isPointInBasket(Offset globalPoint, GlobalKey basketKey) {
    if (basketKey.currentContext == null) return false;
    final RenderBox? renderBox =
        basketKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    if (!renderBox.attached) return false;
    final Offset localPoint = renderBox.globalToLocal(globalPoint);
    return renderBox.paintBounds.contains(localPoint);
  }
}
