import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        String? selectedDirectory =
            await FilePicker.platform.getDirectoryPath();
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
    } else {
      var bytes = Uint8List.fromList(utf8.encode(json));
      await FileSaver.instance
          .saveFile(name: 'favorites.psychbackup', bytes: bytes);
      return "Backup successful.";
    }
  }

  Future<String> restoreBackup() async {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        final cacheDir = await getTemporaryDirectory();

        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
      }
    }
    try {
      if (!kIsWeb) {
        FilePickerResult? file = await FilePicker.platform.pickFiles();
        File sourceFile = File("");
        if (file != null) {
          if (file.files.single.path!.contains(".psychbackup")) {
            sourceFile = File(file.files.single.path.toString());
          } else {
            return "Wrong file selected.";
          }
          Hive.box('favorites').clear();
          Map<String, dynamic> map =
              jsonDecode(await sourceFile.readAsString());
          List mapList = map.values.toList();
          for (var i = 0; i < mapList.length; i++) {
            Hive.box('favorites').put(mapList[i], mapList[i]);
          }
          return "Restore successful.";
        } else {
          return "No file selected.";
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.any, allowMultiple: false);

        if (result != null && result.files.isNotEmpty) {
          final fileBytes = result.files.first.bytes;
          Map<String, dynamic> map =
              jsonDecode(utf8.decode(fileBytes!.toList()));
          Hive.box('favorites').clear();
          List mapList = map.values.toList();
          for (var object in mapList) {
            await Hive.box('favorites').put(object, object);
          }
          html.window.location.reload();
          return "Restore successful.";
        } else {
          return "No file selected.";
        }
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
            ? Theme.of(context).colorScheme.surface
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
          !kIsWeb
              ? (Platform.isAndroid
                  ? Row(
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
                    )
                  : const SizedBox())
              : const SizedBox(),
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
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "About",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PsychFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Psychphinder is a personal project that I have tried to accomplish for several years now. It started as a simple script, and then I tried to learn how to make it more usable in the form of an app, which didn't go very well. A couple of years later, I decided to give it another go, this time for real.\n\nThis app is completely free, open source, without ads, and with a ton of effort!\n\nIf you like it and want to support the project, feel free to use any of the buttons below.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 10),
          const KofiButton(
            kofiName: "daih27",
            kofiColor: KofiColor.Red,
            style: ButtonStyle(
              iconColor: WidgetStatePropertyAll(Colors.white),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse("https://github.com/daih27/psychphinder"));
                },
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(FontAwesomeIcons.github, color: Colors.white),
                  Text(
                    "    Star the repository on Github",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ])),
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
            ? Theme.of(context).colorScheme.surface
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
            ? Theme.of(context).colorScheme.surface
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
                      fixedSize: WidgetStateProperty.all(
                        const Size(120, 50),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
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
                    restoreBackup().then(
                      (value) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.green,
                            title: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.green,
                    ),
                    fixedSize: WidgetStateProperty.all(
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
