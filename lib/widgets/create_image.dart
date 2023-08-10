// ignore_for_file: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:psychphinder/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CreateImagePage extends StatefulWidget {
  final List episode;
  final int id;

  const CreateImagePage({Key? key, required this.episode, required this.id})
      : super(key: key);

  @override
  State<CreateImagePage> createState() => _CreateImageState();
}

class _CreateImageState extends State<CreateImagePage> {
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  String mainLine = '';
  String beforeLine = '';
  String afterLine = '';
  bool beforeLineCheck = false;
  bool afterLineCheck = false;
  bool showPsychphinder = true;
  bool applyOffset = true;
  String widgetTopRight = 'Episode name';
  String widgetTopLeft = 'Psych logo';
  String widgetBottomLeft = 'Season and episode';
  String widgetBottomRight = 'Time';
  String imageType = 'Post';
  double wallpaperOffset = 16;
  double wallpaperScale = 1.07;
  final double psychLogoSize = 18;
  final double infoSize = 8;
  final double lineSize = 14;
  final double secondarylineSize = 8;
  Color bgColor = Colors.green;
  Color textColor = Colors.white;
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    mainLine = widget.episode[widget.id].line;
    if (widget.id != 0) {
      beforeLine = widget.episode[widget.id - 1].line;
    } else {
      beforeLine = "";
    }

    if (widget.id != widget.episode.length - 1) {
      afterLine = widget.episode[widget.id + 1].line;
    } else {
      afterLine = "";
    }

    if (widget.episode[widget.id].season == 0) {
      widgetTopRight = "Movie name";
    }
    if (widget.episode[widget.id].season == 0) {
      widgetBottomLeft = "Movie";
    }
  }

  void update(String value, int selectedIndex) {
    if (selectedIndex == 0) {
      setState(() {
        widgetTopLeft = value;
      });
    } else if (selectedIndex == 1) {
      setState(() {
        widgetTopRight = value;
      });
    } else if (selectedIndex == 2) {
      setState(() {
        widgetBottomLeft = value;
      });
    } else if (selectedIndex == 3) {
      setState(() {
        widgetBottomRight = value;
      });
    }
  }

  Widget topLeftWidget() {
    switch (widgetTopLeft) {
      case "Psych Logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: textColor,
          applyOffset: applyOffset,
          imageType: imageType,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: textColor,
          imageType: imageType,
        );
    }
  }

  Widget topRightWidget() {
    switch (widgetTopRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: textColor,
          applyOffset: applyOffset,
          imageType: imageType,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: textColor,
          applyOffset: applyOffset,
          imageType: imageType,
        );
    }
  }

  Widget bottomRightWidget() {
    switch (widgetBottomRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: textColor,
          applyOffset: applyOffset,
          imageType: imageType,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
    }
  }

  Widget bottomLeftWidget() {
    switch (widgetBottomLeft) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: textColor,
          applyOffset: applyOffset,
          imageType: imageType,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: textColor,
          imageType: imageType,
        );
    }
  }

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          12.horizontalSpace,
          Text(
            text,
            style: const TextStyle(color: Colors.white),
            textScaleFactor: 1.0,
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(
          1080 / ScreenUtil().pixelRatio!, 2400 / ScreenUtil().pixelRatio!),
    );
    print(ScreenUtil().pixelRatio!);
    print(ScreenUtil().screenWidth * ScreenUtil().pixelRatio!);
    print(ScreenUtil().screenHeight * ScreenUtil().pixelRatio!);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Share',
              style: TextStyle(
                fontSize: 25,
                color: Colors.green,
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textScaleFactor: 1.0),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: imageType == 'Post'
                    ? 1
                    : ScreenUtil().screenWidth / ((ScreenUtil().screenHeight)),
                child: Transform.scale(
                  scale: imageType == 'Post'
                      ? ScreenUtil().screenWidth / (1080 / 6)
                      : ScreenUtil().screenWidth /
                          ((ScreenUtil().screenWidth *
                                  ScreenUtil().pixelRatio!) *
                              wallpaperScale /
                              6),
                  alignment: Alignment.center,
                  child: Center(
                    child: UnconstrainedBox(
                      child: SizedBox(
                        height: imageType == 'Post'
                            ? 1080 / 6
                            : (ScreenUtil().screenHeight *
                                    ScreenUtil().pixelRatio!) *
                                wallpaperScale /
                                6,
                        width: imageType == 'Post'
                            ? 1080 / 6
                            : (ScreenUtil().screenWidth *
                                    ScreenUtil().pixelRatio!) *
                                wallpaperScale /
                                6,
                        child: WidgetsToImage(
                          controller: controller,
                          child: Container(
                            color: bgColor,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: imageType == 'Post'
                                      ? (widgetTopLeft == 'Psych logo' ? -2 : 5)
                                          .h
                                      : (widgetTopLeft == 'Psych logo'
                                              ? (9 + wallpaperOffset)
                                              : (17 + wallpaperOffset))
                                          .h,
                                  left: imageType == 'Post'
                                      ? 5.w
                                      : (5 + wallpaperOffset).w,
                                  child: topLeftWidget(),
                                ),
                                Positioned(
                                    top: imageType == 'Post'
                                        ? (widgetTopRight == 'Psych logo'
                                                ? -2
                                                : 5)
                                            .h
                                        : (widgetTopRight == 'Psych logo'
                                                ? (9 + wallpaperOffset)
                                                : (17 + wallpaperOffset))
                                            .h,
                                    right: imageType == 'Post'
                                        ? 5.w
                                        : (5 + wallpaperOffset).w,
                                    child: topRightWidget()),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      beforeLineCheck
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                          8, 2, 8, 2)
                                                      .w,
                                              child: ConstrainedBox(
                                                constraints: imageType ==
                                                        'Wallpaper'
                                                    ? BoxConstraints(
                                                        maxWidth: ScreenUtil()
                                                                .screenWidth *
                                                            0.9)
                                                    : const BoxConstraints(),
                                                child: TextWidget(
                                                  text: beforeLine,
                                                  size: imageType == 'Wallpaper'
                                                      ? secondarylineSize /
                                                          wallpaperScale
                                                      : secondarylineSize,
                                                  textColor: textColor,
                                                  imageType: imageType,
                                                ),
                                              ))
                                          : Container(),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                                8, 2, 8, 2)
                                            .w,
                                        child: ConstrainedBox(
                                          constraints: imageType == 'Wallpaper'
                                              ? BoxConstraints(
                                                  maxWidth:
                                                      ScreenUtil().screenWidth *
                                                          0.85)
                                              : const BoxConstraints(),
                                          child: TextWidget(
                                            text: mainLine,
                                            size: imageType == 'Wallpaper'
                                                ? lineSize / wallpaperScale
                                                : lineSize,
                                            textColor: textColor,
                                            imageType: imageType,
                                          ),
                                        ),
                                      ),
                                      afterLineCheck
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                          8, 2, 8, 2)
                                                      .w,
                                              child: ConstrainedBox(
                                                constraints: imageType ==
                                                        'Wallpaper'
                                                    ? BoxConstraints(
                                                        maxWidth: ScreenUtil()
                                                                .screenWidth *
                                                            0.9)
                                                    : const BoxConstraints(),
                                                child: TextWidget(
                                                  text: afterLine,
                                                  size: imageType == 'Wallpaper'
                                                      ? secondarylineSize /
                                                          wallpaperScale
                                                      : secondarylineSize,
                                                  textColor: textColor,
                                                  imageType: imageType,
                                                ),
                                              ))
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: imageType == 'Post'
                                      ? (widgetBottomLeft == 'Psych logo'
                                              ? 0
                                              : 5)
                                          .h
                                      : (widgetBottomLeft == 'Psych logo'
                                              ? (5 + wallpaperOffset)
                                              : (10 + wallpaperOffset))
                                          .h,
                                  left: imageType == 'Post'
                                      ? 5.w
                                      : (5 + wallpaperOffset).w,
                                  child: bottomLeftWidget(),
                                ),
                                Positioned(
                                  bottom: imageType == 'Post'
                                      ? (widgetBottomRight == 'Psych logo'
                                              ? 2
                                              : 5)
                                          .h
                                      : (widgetBottomRight == 'Psych logo'
                                              ? (7 + wallpaperOffset)
                                              : (10 + wallpaperOffset))
                                          .h,
                                  right: imageType == 'Post'
                                      ? 5.w
                                      : (5 + wallpaperOffset).w,
                                  child: bottomRightWidget(),
                                ),
                                showPsychphinder
                                    ? Positioned(
                                        bottom: imageType == 'Post'
                                            ? 1.h
                                            : (6 + wallpaperOffset).h,
                                        right: imageType == 'Post'
                                            ? 1.w
                                            : (1 + wallpaperOffset).w,
                                        child: Text(
                                          "Made with psychphinder",
                                          style: TextStyle(
                                            fontSize: imageType == 'Wallpaper'
                                                ? 3.5.sp
                                                : 3.5,
                                            fontFamily: 'PsychFont',
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing:
                                                imageType == 'Wallpaper'
                                                    ? -0.2.sp
                                                    : -0.2,
                                          ),
                                          textScaleFactor: 1.0,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              typeSelection(),
              customization(context),
              20.verticalSpace,
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      shareImage(),
                      Platform.isAndroid
                          ? 15.horizontalSpace
                          : const SizedBox(),
                      Platform.isAndroid ? saveToGallery() : const SizedBox(),
                    ],
                  ),
                  Platform.isAndroid ? 15.verticalSpace : const SizedBox(),
                  imageType == 'Wallpaper' && Platform.isAndroid
                      ? saveAsWallpaper(context)
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding typeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            "Type",
            style: TextStyle(fontSize: 16),
            textScaleFactor: 1.0,
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 30,
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.green,
              decoration: InputDecoration(
                fillColor: Colors.green,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
              value: imageType,
              items: const [
                DropdownMenuItem(
                  value: 'Post',
                  child: Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1.0,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Wallpaper',
                  child: Text(
                    'Wallpaper',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1.0,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  imageType = value!;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton shareImage() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Platform.isAndroid ? "Share" : "Save",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textScaleFactor: 1.0,
          ),
          5.horizontalSpace,
          Icon(
            Platform.isAndroid ? Icons.share_rounded : Icons.save_rounded,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        final bytes = await controller.capture();
        setState(() {
          this.bytes = bytes;
        });
        if (Platform.isAndroid) {
          final cacheDir = await getTemporaryDirectory();
          final fileName = path.join(cacheDir.path, 'image.png');
          await File(fileName).writeAsBytes(bytes!);
          final result = await Share.shareXFiles([XFile(fileName)]);
          if (cacheDir.existsSync()) {
            cacheDir.deleteSync(recursive: true);
          }
          if (result.status == ShareResultStatus.success) {
            _showToast("Shared image!");
          }
        } else {
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Please select an output file:',
            fileName: 'image.png',
          );
          if (outputFile != null) {
            File(outputFile).writeAsBytes(bytes!);
            _showToast("Saved image!");
          }
        }
      },
    );
  }

  ElevatedButton saveToGallery() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Save to gallery",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textScaleFactor: 1.0,
          ),
          5.horizontalSpace,
          const Icon(
            Icons.save_rounded,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        final bytes = await controller.capture();
        setState(() {
          this.bytes = bytes;
        });
        if (Platform.isAndroid) {
          final cacheDir = await getTemporaryDirectory();
          await Gal.putImageBytes(bytes!);
          if (cacheDir.existsSync()) {
            cacheDir.deleteSync(recursive: true);
          }
          _showToast("Saved image!");
        }
      },
    );
  }

  ElevatedButton saveAsWallpaper(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Set as wallpaper",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textScaleFactor: 1.0,
          ),
          5.horizontalSpace,
          const Icon(
            Icons.wallpaper,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: Colors.green,
            title: const Center(
              child: Text(
                'Set wallpaper in',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PsychFont',
                    fontWeight: FontWeight.bold),
                textScaleFactor: 1.0,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.HOME_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Home screen",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textScaleFactor: 1.0,
                  ),
                ),
                10.horizontalSpace,
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.LOCK_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Lock screen",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textScaleFactor: 1.0,
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.BOTH_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Both",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textScaleFactor: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ExpansionTile customization(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Customization',
        textScaleFactor: 1.0,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    'Top Left',
                    style: TextStyle(fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                  dropdownButton(context, widgetTopLeft, 0),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'Top Right',
                    style: TextStyle(fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                  dropdownButton(context, widgetTopRight, 1),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Line before',
                  ),
                  initialValue: beforeLine,
                  onChanged: (value) {
                    setState(() {
                      beforeLine = value;
                    });
                  },
                ),
              ),
              Checkbox(
                value: beforeLineCheck,
                onChanged: (value) {
                  setState(() {
                    beforeLineCheck = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Line',
            ),
            initialValue: mainLine,
            onChanged: (value) {
              setState(() {
                mainLine = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Line after',
                  ),
                  initialValue: afterLine,
                  onChanged: (value) {
                    setState(() {
                      afterLine = value;
                    });
                  },
                ),
              ),
              Checkbox(
                value: afterLineCheck,
                onChanged: (value) {
                  setState(() {
                    afterLineCheck = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    'Bottom Left',
                    style: TextStyle(fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                  dropdownButton(context, widgetBottomLeft, 2),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'Bottom Right',
                    style: TextStyle(fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                  dropdownButton(context, widgetBottomRight, 3),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Background color",
                style: TextStyle(fontSize: 16),
                textScaleFactor: 1.0,
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<Color>(
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 30,
                  iconEnabledColor: Colors.white,
                  dropdownColor: Colors.green,
                  decoration: InputDecoration(
                    fillColor: Colors.green,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                  value: bgColor,
                  items: const [
                    DropdownMenuItem(
                      value: Colors.green,
                      child: Text(
                        'Green',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Colors.black,
                      child: Text(
                        'Black',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Colors.white,
                      child: Text(
                        'White',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      bgColor = value!;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Text color",
                style: TextStyle(fontSize: 16),
                textScaleFactor: 1.0,
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<Color>(
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 30,
                  iconEnabledColor: Colors.white,
                  dropdownColor: Colors.green,
                  decoration: InputDecoration(
                    fillColor: Colors.green,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                  value: textColor,
                  items: const [
                    DropdownMenuItem(
                      value: Colors.green,
                      child: Text(
                        'Green',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Colors.black,
                      child: Text(
                        'Black',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Colors.white,
                      child: Text(
                        'White',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      textColor = value!;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Show \"Made with psychphinder\"",
                style: TextStyle(fontSize: 16),
                textScaleFactor: 1.0,
              ),
              const Spacer(),
              Switch(
                value: showPsychphinder,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    showPsychphinder = value;
                  });
                },
              )
            ],
          ),
        ),
        imageType == 'Wallpaper'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      "Apply offset fix",
                      style: TextStyle(fontSize: 16),
                      textScaleFactor: 1.0,
                    ),
                    const Spacer(),
                    Switch(
                      value: applyOffset,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() {
                          applyOffset = value;
                          if (applyOffset) {
                            wallpaperOffset = 16;
                            wallpaperScale = 1.07;
                          } else {
                            wallpaperOffset = 0;
                            wallpaperScale = 1;
                          }
                        });
                      },
                    )
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  SizedBox dropdownButton(BuildContext context, String current, int index) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        iconSize: 30,
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.green,
        decoration: InputDecoration(
          fillColor: Colors.green,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
        value: current,
        items: [
          const DropdownMenuItem(
            value: 'Psych logo',
            child: Text(
              'Psych logo',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
            ),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Episode name'
                : 'Movie name',
            child: Text(
              widget.episode[widget.id].season != 0
                  ? 'Episode name'
                  : 'Movie name',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
            ),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Season and episode'
                : 'Movie',
            child: Text(
              widget.episode[widget.id].season != 0
                  ? 'Season and episode'
                  : 'Movie',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
            ),
          ),
          const DropdownMenuItem(
            value: 'Time',
            child: Text(
              'Time',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
            ),
          ),
          const DropdownMenuItem(
            value: 'None',
            child: Text(
              'None',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            update(value!, index);
          });
        },
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    required this.size,
    required this.textColor,
    required this.imageType,
  });

  final String text;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: imageType == 'Wallpaper' ? size.sp : size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: imageType == 'Wallpaper' ? -0.5.sp : -0.5,
      ),
      textAlign: TextAlign.center,
      textScaleFactor: 1.0,
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.time,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final String time;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: time[0] == '0' ? time.substring(2) : time,
        size: size,
        textColor: textColor,
        imageType: imageType,
      ),
    );
  }
}

class SeasonAndEpisodeWidget extends StatelessWidget {
  const SeasonAndEpisodeWidget({
    super.key,
    required this.season,
    required this.episode,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final String season;
  final String episode;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: season != "0" ? "Season $season, Episode $episode" : "Movie",
        size: size,
        textColor: textColor,
        imageType: imageType,
      ),
    );
  }
}

class EpisodeNameWidget extends StatelessWidget {
  const EpisodeNameWidget({
    super.key,
    required this.name,
    required this.size,
    required this.textColor,
    required this.applyOffset,
    required this.imageType,
  });
  final String name;
  final double size;
  final Color textColor;
  final bool applyOffset;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
          constraints: imageType == 'Wallpaper'
              ? applyOffset
                  ? BoxConstraints(maxWidth: 90.w)
                  : BoxConstraints(maxWidth: 110.w)
              : const BoxConstraints(maxWidth: 110),
          child: TextWidget(
            text: name,
            size: size,
            textColor: textColor,
            imageType: imageType,
          )),
    );
  }
}

class PsychLogoWidget extends StatelessWidget {
  const PsychLogoWidget({
    super.key,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Text(
      "psych",
      style: TextStyle(
        fontSize: imageType == 'Wallpaper' ? size.sp : size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: imageType == 'Wallpaper' ? -1.6.sp : -1.6,
      ),
      textScaleFactor: 1.0,
      textAlign: TextAlign.center,
    );
  }
}
