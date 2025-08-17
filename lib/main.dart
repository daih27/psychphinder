import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/profile_class.dart';
import 'package:psychphinder/global/routes.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:psychphinder/references.dart';
import 'package:psychphinder/search.dart';
import 'package:psychphinder/favorites.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:check_app_version/check_app_version.dart';
import 'classes/phrase_class.dart';
import 'database/database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

final Uri _url = Uri.parse('https://github.com/daih27/psychphinder');
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PhraseAdapter());
  Hive.registerAdapter(ProfileAdapter());
  await Hive.openBox('favorites');
  await Hive.openBox('profiles');
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();

  runApp(
    MultiProvider(providers: [
      Provider.value(value: databaseService),
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: SearchEngineProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return Builder(
          builder: (BuildContext context) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: FToastBuilder()(context, child),
            );
          },
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppLinks _appLinks;
  // ignore: unused_field
  StreamSubscription<Uri>? _linkSubscription;
  int _selectedIndex = 1;
  PageController _pageController = PageController();
  final screens = [
    const ReferencesPage(),
    const SearchPage(),
    const FavoritesPage()
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedIndex);
    super.initState();
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        initDeepLinks();
      }
      if (Platform.isWindows || Platform.isLinux) {
        showUpdateLinuxWindows();
      }
    }
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      openAppLink(appLink);
    }
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    if (uri.toString() == "https://daih27.github.io/psychphinder" ||
        uri.toString() == "https://daih27.github.io/psychphinder/") {
      context.go(
        "/",
      );
    } else if (uri
        .toString()
        .startsWith("https://daih27.github.io/psychphinder/#")) {
      context.go(
        uri
            .toString()
            .replaceAll("https://daih27.github.io/psychphinder/#", ""),
      );
    } else {
      context.go("/");
    }
  }

  void showUpdateLinuxWindows() async {
    AppVersionDialog(
      context: context,
      jsonUrl:
          'https://raw.githubusercontent.com/daih27/psychphinder/master/app_version.json',
      updateButtonColor: Colors.green,
      onPressDecline: () => Navigator.of(context).pop(),
      onPressConfirm: () => launchUrl(_url),
      updateButtonText: 'Go to GitHub',
      laterButtonText: 'Later',
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: navigatorKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'psychphinder',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                context.go('/settings');
              },
            ),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).currentThemeType ==
                  ThemeType.black
              ? Colors.black
              : Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: GNav(
            backgroundColor:
                Provider.of<ThemeProvider>(context).currentThemeType ==
                        ThemeType.black
                    ? Colors.black
                    : Theme.of(context).colorScheme.surface,
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            tabBorderRadius: 20,
            tabBackgroundColor: Theme.of(context).colorScheme.primary,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            gap: 10,
            activeColor: Colors.white,
            color: Theme.of(context).colorScheme.primary,
            iconSize: 26,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            tabs: const [
              GButton(
                icon: Icons.movie_rounded,
                text: 'References',
              ),
              GButton(
                icon: Icons.search_rounded,
                text: 'Search',
              ),
              GButton(
                icon: Icons.favorite_rounded,
                text: 'Favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
