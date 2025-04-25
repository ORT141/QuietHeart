import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ColorPaletteGame extends StatefulWidget {
  const ColorPaletteGame({super.key});

  @override
  ColorPaletteGameState createState() => ColorPaletteGameState();
}

class ColorPaletteGameState extends State<ColorPaletteGame> {
  List<Color> targetColors = [];
  List<List<Color>> choiceColors = [];
  int score = 0;
  final int maxScore = 12;
  bool isColorSelected = false;
  List<Color>? selectedColors;
  bool? isCorrectSelection;

  @override
  void initState() {
    super.initState();
    startRound();
  }

  static List<Color> generateTargetColors() {
    Color color1 = HSVColor.fromAHSV(
      1.0,
      Random().nextDouble() * 360,
      0.6 + Random().nextDouble() * 0.4,
      0.7 + Random().nextDouble() * 0.3,
    ).toColor();

    HSVColor hsv1 = HSVColor.fromColor(color1);
    double hue2;
    do {
      hue2 = Random().nextDouble() * 360;
    } while ((hsv1.hue - hue2).abs() < 60 || (hsv1.hue - hue2).abs() > 300);

    Color color2 = HSVColor.fromAHSV(
      1.0,
      hue2,
      0.6 + Random().nextDouble() * 0.4,
      0.7 + Random().nextDouble() * 0.3,
    ).toColor();

    return [color1, color2];
  }

  List<List<Color>> generateChoiceColors(List<Color> targetColors) {
    List<List<Color>> choices = [];

    List<Color> correctPair = List.from(targetColors)..shuffle(Random());
    choices.add(correctPair);

    int attempts = 0;
    while (choices.length < 6 && attempts < 100) {
      attempts++;
      List<Color> distractorPair = [];
      for (int j = 0; j < 2; j++) {
        int targetIndex = Random().nextInt(2);
        HSVColor baseHsv = HSVColor.fromColor(targetColors[targetIndex]);

        double hueDiff = (Random().nextDouble() * 120 + 45);
        if (Random().nextBool()) hueDiff *= -1;
        double newHue = (baseHsv.hue + hueDiff) % 360;
        if (newHue < 0) newHue += 360;

        double newSaturation =
            baseHsv.saturation + (Random().nextDouble() - 0.5) * 0.2;
        newSaturation = newSaturation.clamp(0.5, 1.0);

        double newValue = baseHsv.value + (Random().nextDouble() - 0.5) * 0.2;
        newValue = newValue.clamp(0.6, 1.0);

        distractorPair.add(
            HSVColor.fromAHSV(1.0, newHue, newSaturation, newValue).toColor());
      }
      if (!((distractorPair[0] == targetColors[0] &&
              distractorPair[1] == targetColors[1]) ||
          (distractorPair[0] == targetColors[1] &&
              distractorPair[1] == targetColors[0]))) {
        bool alreadyExists = choices.any((existingPair) =>
            (existingPair[0] == distractorPair[0] &&
                existingPair[1] == distractorPair[1]) ||
            (existingPair[0] == distractorPair[1] &&
                existingPair[1] == distractorPair[0]));

        if (!alreadyExists) {
          choices.add(distractorPair);
        }
      }
    }
    while (choices.length < 6) {
      choices.add(generateTargetColors());
    }

    choices.shuffle(Random());
    return choices;
  }

  void startRound() {
    if (score >= maxScore) {
      showGameOverDialog(true);
      return;
    }

    setState(() {
      targetColors = generateTargetColors();
      choiceColors = generateChoiceColors(targetColors);
      isColorSelected = false;
      selectedColors = null;
      isCorrectSelection = null;
    });
  }

  void _checkAnswer(List<Color> chosenColors) {
    if (isColorSelected) return;

    bool correct = (chosenColors.contains(targetColors[0]) &&
        chosenColors.contains(targetColors[1]));

    setState(() {
      isColorSelected = true;
      selectedColors = chosenColors;
      isCorrectSelection = correct;

      if (correct) {
        score++;
        if (score >= maxScore) {
          Future.delayed(const Duration(milliseconds: 500), () {
            showGameOverDialog(true);
          });
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            startRound();
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          showGameOverDialog(false);
        });
      }
    });
  }

  void startGame() {
    setState(() {
      score = 0;
      isColorSelected = false;
      selectedColors = null;
      isCorrectSelection = null;
      targetColors = generateTargetColors();
      choiceColors = generateChoiceColors(targetColors);
    });
  }

  void showGameOverDialog(bool win) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(win ? l10n.gameWinTitle : l10n.gameOverTitle),
          content: Text(win ? l10n.gameWinMessage : l10n.gameTryAgainMessage),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
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
        title: Text(l10n.scoreDisplay(score, maxScore),
            style: TextStyle(color: theme.colorScheme.onPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.colorPaletteInstruction,
              style: TextStyle(
                  fontSize: 18, color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorContainer(
                    targetColors.isNotEmpty ? targetColors[0] : Colors.grey,
                    isLeft: true),
                _buildColorContainer(
                    targetColors.length > 1 ? targetColors[1] : Colors.grey,
                    isLeft: false),
              ],
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3,
              ),
              itemCount: choiceColors.length,
              itemBuilder: (context, index) {
                final colorPair = choiceColors[index];
                bool isCurrentChoiceSelected =
                    isColorSelected && selectedColors == colorPair;

                return GestureDetector(
                  onTap: isColorSelected ? null : () => _checkAnswer(colorPair),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isCurrentChoiceSelected
                                ? (isCorrectSelection!
                                    ? Colors.green.shade400
                                    : Colors.red.shade400)
                                : theme.dividerColor.withValues(alpha: .2),
                            width: isCurrentChoiceSelected ? 4 : 1.5),
                        boxShadow: isCurrentChoiceSelected
                            ? [
                                BoxShadow(
                                  color: (isCorrectSelection!
                                          ? Colors.green
                                          : Colors.red)
                                      .withValues(alpha: .3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Row(
                          children: [
                            _buildChoiceColorHalf(colorPair[0],
                                isCurrentChoiceSelected, isCorrectSelection,
                                isLeft: true),
                            _buildChoiceColorHalf(
                                colorPair.length > 1
                                    ? colorPair[1]
                                    : Colors.grey,
                                isCurrentChoiceSelected,
                                isCorrectSelection,
                                isLeft: false),
                          ],
                        ),
                      )),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorContainer(Color color, {required bool isLeft}) {
    final theme = Theme.of(context);
    const double width = 60;
    const double height = 120;
    const Radius cornerRadius = Radius.circular(16);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: isLeft
            ? const BorderRadius.only(
                topLeft: cornerRadius, bottomLeft: cornerRadius)
            : const BorderRadius.only(
                topRight: cornerRadius, bottomRight: cornerRadius),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .5)),
      ),
    );
  }

  Widget _buildChoiceColorHalf(Color color, bool isSelected, bool? isCorrect,
      {required bool isLeft}) {
    const Radius cornerRadius = Radius.circular(11);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: isLeft
              ? const BorderRadius.only(
                  topLeft: cornerRadius, bottomLeft: cornerRadius)
              : const BorderRadius.only(
                  topRight: cornerRadius, bottomRight: cornerRadius),
        ),
        child: isSelected
            ? Center(
                child: Icon(
                isCorrect! ? Icons.check_circle_outline : Icons.highlight_off,
                color: Colors.white.withValues(alpha: .8),
                size: 24,
              ))
            : null,
      ),
    );
  }
}
