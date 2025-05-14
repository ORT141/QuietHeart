import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quietheart/tabs/breath.dart';
import 'package:quietheart/tabs/games.dart';
import 'package:quietheart/tabs/motions.dart';
import 'package:quietheart/tabs/tales.dart';
import 'package:quietheart/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uk');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeMode();
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
  }
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (context) => ThemeProvider()..loadThemeMode()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      theme: MaterialTheme(MaterialTheme.createShantellSansTextTheme()).light(),
      darkTheme:
          MaterialTheme(MaterialTheme.createShantellSansTextTheme()).dark(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showWelcomeScreen = true;

  static final List<Widget> widgetOptions = <Widget>[
    TalesWidget(),
    GamesWidget(),
    BreatheWidget(),
    MotionsWidget(),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('firstLaunch') ?? true;
    const forceFirstLaunch = false;

    if (!mounted) return;

    if (firstLaunch || forceFirstLaunch) {
      setState(() {
        _showWelcomeScreen = true;
        selectedIndex = -1;
      });
      await prefs.setBool('firstLaunch', false);
      _initializeApp(playIntro: true);
    } else {
      setState(() {
        _showWelcomeScreen = false;
        selectedIndex = 0;
      });
      _initializeApp(playIntro: false);
    }
  }

  void _initializeApp({required bool playIntro}) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (!kDebugMode && playIntro) {
      try {
        await _audioPlayer.play(AssetSource('sounds/intro.mp3'));
      } catch (e) {
        if (!mounted) return;

        Fluttertoast.showToast(
          msg: l10n.errorPlaySound(e.toString()),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    await Future.delayed(Duration(seconds: playIntro ? 3 : 1));
    FlutterNativeSplash.remove();

    if (mounted) {
      _animationController.forward();
    }
  }

  void onItemTapped(int index) {
    if (selectedIndex == index) return;
    setState(() {
      selectedIndex = index;
      if (_showWelcomeScreen) {
        _showWelcomeScreen = false;
        _animationController.reset();
        _animationController.forward();
      } else {}
    });
  }

  void _dismissWelcomeScreen() {
    if (!_showWelcomeScreen) return;
    setState(() {
      _showWelcomeScreen = false;
      selectedIndex = 0;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _showWelcomeScreen
          ? null
          : AppBar(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0,
            ),
      drawer: _showWelcomeScreen ? null : _buildAppDrawer(context, l10n),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _showWelcomeScreen
            ? _buildWelcomeScreen(context, l10n)
            : _buildMainContent(context, l10n),
      ),
      bottomNavigationBar: _showWelcomeScreen
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onItemTapped,
              currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSurface.withAlpha(153),
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontSize: 16),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              items: [
                _buildNavItem(
                    Theme.of(context).brightness == Brightness.dark
                        ? "assets/images/icons/tales_dark.svg"
                        : "assets/images/icons/tales.svg",
                    l10n.tabTales,
                    0),
                _buildNavItem(
                    Theme.of(context).brightness == Brightness.dark
                        ? "assets/images/icons/games_dark.svg"
                        : "assets/images/icons/games.svg",
                    l10n.tabGames,
                    1),
                _buildNavItem(
                    Theme.of(context).brightness == Brightness.dark
                        ? "assets/images/icons/breath_dark.svg"
                        : "assets/images/icons/breath.svg",
                    l10n.tabBreathe,
                    2),
                _buildNavItem(
                    Theme.of(context).brightness == Brightness.dark
                        ? "assets/images/icons/moving_dark.svg"
                        : "assets/images/icons/moving.svg",
                    l10n.tabMotions,
                    3),
              ],
            ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, AppLocalizations l10n) {
    return KeyedSubtree(
      key: const ValueKey('welcomeScreen'),
      child: Center(
        child: GestureDetector(
          onTap: _dismissWelcomeScreen,
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Text(
                    l10n.welcomeMessage,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/breathe_black.png'
                          : 'assets/images/breathe_white.png',
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 3),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                    l10n.welcomeSubMessage,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 4),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.onboardingTapPrompt,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n) {
    final contentIndex =
        (selectedIndex >= 0 && selectedIndex < widgetOptions.length)
            ? selectedIndex
            : 0;

    return KeyedSubtree(
      key: ValueKey('mainContent_$contentIndex'),
      child: FadeTransition(
        opacity: _animation,
        child: widgetOptions.elementAt(contentIndex),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, AppLocalizations l10n) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = Provider.of<LocaleProvider>(context).locale;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 32.0),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      l10n.appTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(indent: 24.0, endIndent: 24.0, thickness: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionTitle(context, l10n.language),
                  _buildLanguageOption(
                    context,
                    "Українська",
                    'uk',
                    currentLocale,
                    localeProvider,
                  ),
                  _buildLanguageOption(
                    context,
                    "English",
                    'en',
                    currentLocale,
                    localeProvider,
                  ),
                  _buildLanguageOption(
                      context, "Hebrew", 'he', currentLocale, localeProvider),
                  Divider(indent: 24.0, endIndent: 24.0, thickness: 1),
                  _buildSectionTitle(context, l10n.themeMode),
                  _buildThemeOption(
                    context,
                    l10n.systemTheme,
                    Icons.brightness_auto,
                    ThemeMode.system,
                    themeProvider,
                  ),
                  _buildThemeOption(
                    context,
                    l10n.lightTheme,
                    Icons.light_mode,
                    ThemeMode.light,
                    themeProvider,
                  ),
                  _buildThemeOption(
                    context,
                    l10n.darkTheme,
                    Icons.dark_mode,
                    ThemeMode.dark,
                    themeProvider,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© 2025 QuietHeart',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String languageCode,
    Locale currentLocale,
    LocaleProvider localeProvider,
  ) {
    final isSelected = currentLocale.languageCode == languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          leading: const Icon(Icons.language),
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            localeProvider.setLocale(Locale(languageCode));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          leading: Icon(icon),
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            themeProvider.setThemeMode(mode);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String imagePath, String label, int index) {
    bool isSelected = selectedIndex == index;
    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(
            begin: isSelected ? 0.8 : 1.0, end: isSelected ? 1.0 : 0.8),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 54 : 42,
            height: isSelected ? 54 : 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withAlpha(60)
                  : Colors.transparent,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(40),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            padding: EdgeInsets.all(isSelected ? 6 : 0),
            margin: const EdgeInsets.only(bottom: 4),
            child: Transform.scale(
              scale: value,
              child: SvgPicture.asset(
                imagePath,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }
}
