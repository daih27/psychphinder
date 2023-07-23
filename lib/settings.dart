import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  Future<String?> backupHiveBox<T>(String boxName) async {
    if (Platform.isAndroid) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      final cacheDir = await getTemporaryDirectory();

      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      if (selectedDirectory != null) {
        try {
          final Directory appDocumentDirectory =
              await getApplicationDocumentsDirectory();
          final sourcePath =
              path.join(appDocumentDirectory.path, 'favorites.hive');
          final destinationPath =
              path.join(selectedDirectory, 'favorites.psychbackup');
          final sourceFile = File(sourcePath);
          final destinationFile = File(destinationPath);
          // if (await destinationFile.exists()) {
          //   await destinationFile.delete();
          // }

          if (await sourceFile.exists()) {
            await sourceFile.copy(destinationFile.path);
            return "Backup successful.";
          } else {
            return "Error: Source file does not exist.";
          }
        } catch (e) {
          // return "Error during backup: $e";
          return "Choose another directory, preferably in the folder Documents or Download";
        }
      } else {
        return "No directory selected.";
      }
      // }
      // else {
      //   return "Permission denied";
      // }
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'favorites.psychbackup',
      );
      if (outputFile != null) {
        try {
          final appDocumentDirectory = await getApplicationDocumentsDirectory();
          final sourcePath =
              path.join(appDocumentDirectory.path, 'favorites.hive');
          final sourceFile = File(sourcePath);
          final destinationFile = File(outputFile);
          if (await destinationFile.exists()) {
            await destinationFile.delete();
          }
          if (await sourceFile.exists()) {
            await sourceFile.copy(destinationFile.path);
            return "Backup successful.";
          } else {
            return "Error: Source file does not exist.";
          }
        } catch (e) {
          return "Error during backup: $e";
        }
      } else {
        return "No directory selected.";
      }
    }
  }

  Future<String?> restoreHiveBox<T>(String boxName) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            color: themeProvider.currentThemeType == ThemeType.dark
                ? Colors.green
                : Colors.white,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(15),
              width: double.infinity,
              height: 130,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white10,
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
                            backupHiveBox("favorites").then(
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
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size(100, 50),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.green,
                              )),
                          child: const Text(
                            'Backup',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            restoreHiveBox("favorites").then(
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
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green,
                            ),
                            fixedSize: MaterialStateProperty.all(
                              const Size(100, 50),
                            ),
                          ),
                          child: const Text(
                            'Restore',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(15),
              width: double.infinity,
              height: 130,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white10,
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
                        const Text("Select theme:",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
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
                                borderSide:
                                    const BorderSide(color: Colors.green),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: Colors.green),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: Colors.green),
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
                                child: Text('Dark',
                                    style: TextStyle(color: Colors.white)),
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
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(15),
              // width: double.infinity,
              // height: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white10,
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
                  ),
                  SizedBox(height: 10),
                  KofiButton(
                    kofiName: "daih27",
                    kofiColor: KofiColor.Red,
                  ),
                ],
              ),
            ),
            // const KofiButton(
            //   kofiName: "daih27",
            //   kofiColor: KofiColor.Red,
            // )
            // onDonation: () {
            //   print("On Donation!");
            // }),
          ],
        ),
      ),
    );
  }
}
