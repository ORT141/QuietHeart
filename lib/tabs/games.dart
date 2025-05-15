import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../games/ColorPallete.dart';
import '../games/MatchingSounds.dart';
import '../games/SortingGarbage.dart';

class GamesWidget extends StatefulWidget {
  const GamesWidget({super.key});

  @override
  State<GamesWidget> createState() => _GamesWidgetState();
}

class _GamesWidgetState extends State<GamesWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    int crossAxisCount = isLargeScreen ? 3 : 2;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 20.0 : 12.0,
              vertical: 16.0,
            ),
            child: Text(
              l10n.tabGames,
              style: TextStyle(
                fontSize: isLargeScreen ? 28.0 : 24.0,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? theme.colorScheme.surfaceContainerLow
                        : theme.colorScheme.primaryContainer.withOpacity(0.3),
                    isDark
                        ? theme.colorScheme.surfaceContainerLowest
                        : theme.colorScheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(isLargeScreen ? 32 : 24),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                mainAxisSpacing: isLargeScreen ? 24 : 16,
                crossAxisSpacing: isLargeScreen ? 24 : 16,
                children: [
                  _buildGameButton(
                    context,
                    l10n.gameSortingGarbageTitle,
                    Icons.recycling_outlined,
                    const SortingGarbageGame(),
                    0,
                    isDark,
                  ),
                  _buildGameButton(
                    context,
                    l10n.gameMatchingSoundsTitle,
                    Icons.volume_up_outlined,
                    const MatchingSoundsGame(),
                    200,
                    isDark,
                  ),
                  _buildGameButton(
                    context,
                    l10n.gameColorPaletteTitle,
                    Icons.palette_outlined,
                    const ColorPaletteGame(),
                    400,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String title, IconData icon,
      Widget gameWidget, int delay, bool isDark) {
    return GameButton(
      title: title,
      icon: icon,
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => gameWidget,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      delay: delay,
      isDark: isDark,
    );
  }
}

class GameButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final int delay;
  final bool isDark;

  const GameButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.delay,
    required this.isDark,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double smallestDimension =
            constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;

        final double iconSize = smallestDimension * 0.28;
        final double fontSize = smallestDimension * 0.1;
        final double buttonPadding = smallestDimension * 0.06;
        final double borderRadius = smallestDimension * 0.18;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDark
                        ? [
                            theme.colorScheme.surfaceContainerHighest,
                            theme.colorScheme.surfaceContainerHigh,
                          ]
                        : [
                            theme.colorScheme.primaryContainer.withOpacity(0.6),
                            theme.colorScheme.secondaryContainer
                                .withOpacity(0.8),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor
                          .withOpacity(_isHovering ? 0.25 : 0.15),
                      spreadRadius: _isHovering ? 2 : 0,
                      blurRadius: _isHovering ? 12 : 8,
                      offset: Offset(0, _isHovering ? 5 : 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(borderRadius),
                    splashColor: theme.colorScheme.primary.withOpacity(0.1),
                    highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                    onTap: widget.onPressed,
                    child: Padding(
                      padding: EdgeInsets.all(buttonPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(smallestDimension * 0.06),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              size: iconSize,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: smallestDimension * 0.06),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
