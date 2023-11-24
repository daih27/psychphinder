import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/routes.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:psychphinder/references.dart';
import 'package:psychphinder/search.dart';
import 'package:psychphinder/favorites.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:check_app_version/show_dialog.dart';
import 'classes/phrase_class.dart';
import 'global/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Uri _url = Uri.parse('https://github.com/daih27/psychphinder');
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PhraseAdapter());
  await Hive.openBox('favorites');
  WidgetsFlutterBinding.ensureInitialized();
  final csvData = CSVData();
  await csvData.loadDataFromCSV();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider.value(value: csvData),
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
      builder: FToastBuilder(),
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
    }
    showWhatsNew(context);
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        showUpdateLinuxWindows();
      }
    }
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    final appLink = await _appLinks.getInitialAppLink();
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

  Future<void> showWhatsNew(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    int latestAppVersion = pref.getInt("latestAppVersion") ?? buildNumber;
    if (buildNumber > latestAppVersion) {
      pref.setInt("latestAppVersion", buildNumber);
      String dialogContent = await rootBundle.loadString('assets/CHANGELOG.md');
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('What\'s new?'),
                content: SizedBox(
                    width: double.maxFinite,
                    height: 500,
                    child: Center(
                        child: Markdown(
                      data: dialogContent,
                      onTapLink: (text, url, title) {
                        launchUrl(Uri.parse(url!));
                      },
                    ))),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  showUpdateLinuxWindows() async {
    ShowDialog(
      context: context,
      jsonUrl:
          'https://raw.githubusercontent.com/daih27/psychphinder/master/app_version.json',
      updateButtonColor: Colors.green,
      onPressDecline: () => Navigator.of(context).pop(),
      onPressConfirm: () => launchUrl(_url),
      updateButtonText: 'Go to GitHub',
      laterButtonText: 'Later',
    ).checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: navigatorKey,
      appBar: AppBar(
        title: const Text(
          'psychphinder',
          style: TextStyle(
            fontSize: 38,
            color: Colors.green,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -2.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
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
        color: Provider.of<ThemeProvider>(context).currentThemeType ==
                ThemeType.black
            ? Colors.black
            : Theme.of(context).colorScheme.surface,
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
                  curve: Curves.ease);
            },
            tabBorderRadius: 15,
            tabBackgroundColor: Colors.green,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            gap: 8,
            activeColor: Colors.white,
            color: Colors.green,
            iconSize: 24,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.help_rounded,
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
