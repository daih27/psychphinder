import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String?> createBackup() async {
    if (Hive.box('favorites').isEmpty) {
      return "No favorites stored";
    }
    Map<String, dynamic> map = Hive.box('favorites')
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));
    String json = jsonEncode(map);
    if (Platform.isAndroid) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      if (selectedDirectory != null) {
        try {
          final destinationPath =
              path.join(selectedDirectory, 'favorites.psychbackup');
          final destinationFile = File(destinationPath);
          await destinationFile.writeAsString(json);
          return "Backup successful.";
        } catch (e) {
          return "Choose another directory, preferably in the folder Documents or Download";
        }
      } else {
        return "No directory selected.";
      }
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'favorites.psychbackup',
      );
      if (outputFile != null) {
        try {
          final destinationFile = File(outputFile);
          if (await destinationFile.exists()) {
            await destinationFile.delete();
          }
          await destinationFile.writeAsString(json);
          return "Backup successful.";
        } catch (e) {
          return "Error during backup: $e";
        }
      } else {
        return "No directory selected.";
      }
    }
  }

  Future<String> restoreBackup() async {
    if (Platform.isAndroid) {
      final cacheDir = await getTemporaryDirectory();

      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    }
    try {
      FilePickerResult? file = await FilePicker.platform.pickFiles();
      File sourceFile = File("");
      if (file != null) {
        if (file.files.single.path!.contains(".psychbackup")) {
          sourceFile = File(file.files.single.path.toString());
        } else {
          return "Wrong file selected.";
        }
        Hive.box('favorites').clear();
        Map<String, dynamic> map = jsonDecode(await sourceFile.readAsString());
        List mapList = map.values.toList();
        for (var i = 0; i < mapList.length; i++) {
          Hive.box('favorites').put(mapList[i], mapList[i]);
        }
        return "Restore successful.";
      } else {
        return "No file selected.";
      }
    } catch (e) {
      return "Error during restore: $e";
    }
  }

  Future<String?> restoreBackupOld<T>(String boxName) async {
    if (Platform.isAndroid) {
      final cacheDir = await getTemporaryDirectory();

      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      File sourceFile = File("");

      if (result != null) {
        if (result.files.single.path!.contains(".psychbackup")) {
          sourceFile = File(result.files.single.path!);
        } else {
          return "Wrong file selected.";
        }
      }
      await Hive.close();
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      final destinationPath =
          path.join(appDocumentDirectory.path, 'favorites.hive');
      final destinationFile = File(destinationPath);

      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationFile.path);
        await Hive.openBox('favorites');
        return "Restore successful.";
      } else {
        await Hive.openBox('favorites');
        return "No file selected.";
      }
    } catch (e) {
      return "Error during restore: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final searchEngineProvider = Provider.of<SearchEngineProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            color: Colors.green,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            backupRestoreFav(context, themeProvider),
            const SizedBox(height: 10),
            themeSelection(themeProvider),
            const SizedBox(height: 10),
            searchEngineSelection(searchEngineProvider, themeProvider),
            const SizedBox(height: 10),
            about(themeProvider),
          ],
        ),
      ),
    );
  }

  Container searchEngineSelection(
      SearchEngineProvider searchEngineProvider, ThemeProvider themeProvider) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: themeProvider.currentThemeType == ThemeType.black
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Search engine",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Set your favorite search engine to use when clicking on the search icon while looking for a reference.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                const Text("Search engine", style: TextStyle(fontSize: 16)),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<SearchEngineType>(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    iconSize: 30,
                    iconEnabledColor: Colors.white,
                    dropdownColor: Colors.green,
                    decoration: InputDecoration(
                      fillColor: Colors.green,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                    value: searchEngineProvider.currentSearchEngineType,
                    items: const [
                      DropdownMenuItem(
                        value: SearchEngineType.google,
                        child: Text('Google',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: SearchEngineType.ddg,
                        child: Text('DuckDuckGo',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: SearchEngineType.bing,
                        child:
                            Text('Bing', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: SearchEngineType.startpage,
                        child: Text('Startpage',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: SearchEngineType.brave,
                        child: Text('Brave',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      searchEngineProvider.setSearchEngine(value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Text("Open links inside the app",
                  style: TextStyle(fontSize: 16)),
              const Spacer(),
              Switch(
                value: searchEngineProvider.openLinks,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    searchEngineProvider.saveSwitchState(value);
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Container about(ThemeProvider themeProvider) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: themeProvider.currentThemeType == ThemeType.black
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Psychphinder is a personal project that I have tried to accomplish for several years now. It started as a simple script, and then I tried to learn how to make it more usable in the form of an app, which didn't go very well. A couple of years later, I decided to give it another go, this time for real.\n\nThis app is completely free, open source, without ads, and with a ton of effort!\n\nIf you like it and want to support the project, feel free to donate using the button below!",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          KofiButton(
            kofiName: "daih27",
            kofiColor: KofiColor.Red,
            style: ButtonStyle(
              iconColor: MaterialStatePropertyAll(Colors.white),
              foregroundColor: MaterialStatePropertyAll(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Container themeSelection(ThemeProvider themeProvider) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: themeProvider.currentThemeType == ThemeType.black
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        children: [
          const Text(
            "Theme",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                const Text("Theme", style: TextStyle(fontSize: 16)),
                const Spacer(),
                SizedBox(
                  width: 125,
                  child: DropdownButtonFormField<ThemeType>(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    iconSize: 30,
                    iconEnabledColor: Colors.white,
                    dropdownColor: Colors.green,
                    decoration: InputDecoration(
                      fillColor: Colors.green,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                    value: themeProvider.currentThemeType,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeType.light,
                        child: Text('Light',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: ThemeType.dark,
                        child:
                            Text('Dark', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: ThemeType.black,
                        child: Text('Black',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      themeProvider.setTheme(value!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container backupRestoreFav(
      BuildContext context, ThemeProvider themeProvider) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: themeProvider.currentThemeType == ThemeType.black
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        children: [
          const Text(
            "Backup/restore favorites",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    createBackup().then(
                      (value) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.green,
                            title: Text(value!,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                        const Size(120, 50),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.green,
                      )),
                  child: const Text(
                    'Backup',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: Colors.green,
                        title: const Text(
                          "Choose method",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              onPressed: () {
                                restoreBackup().then(
                                  (value) {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor: Colors.green,
                                        title: Text(value,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                "New method",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              onPressed: () {
                                restoreBackupOld("favorites").then(
                                  (value) {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor: Colors.green,
                                        title: Text(value!,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                "Old method",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green,
                    ),
                    fixedSize: MaterialStateProperty.all(
                      const Size(120, 50),
                    ),
                  ),
                  child: const Text(
                    'Restore',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
