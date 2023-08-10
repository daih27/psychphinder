import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:psychphinder/references.dart';
import 'package:psychphinder/search.dart';
import 'package:psychphinder/favorites.dart';
import 'package:psychphinder/settings.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:check_app_version/show_dialog.dart';
import 'classes/phrase_class.dart';
import 'global/globals.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/daih27/psychphinder');
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PhraseAdapter());
  await Hive.openBox('favorites');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
    return ScreenUtilInit(
      designSize: Size(
          1080 / ScreenUtil().pixelRatio!, 2400 / ScreenUtil().pixelRatio!),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Provider.of<ThemeProvider>(context).currentTheme,
          home: child,
          builder: FToastBuilder(),
        );
      },
      child: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  final screens = [
    const ReferencesPage(),
    const SearchPage(),
    const FavoritesPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux) {
      init();
    }
  }

  init() async {
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
    void refreshFavoritesPage() {
      setState(() {
        // ignore: prefer_const_constructors
        screens[2] = FavoritesPage();
      });
    }

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  ).then((value) => refreshFavoritesPage());
                })
          ]),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt_rounded),
            label: 'References',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontFamily: 'PsychFont',
        ),
        selectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontFamily: 'PsychFont',
          fontWeight: FontWeight.bold,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}
