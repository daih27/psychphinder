import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wallpaper_handler/wallpaper_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:psychphinder/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_saver/file_saver.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:psychphinder/classes/profile_class.dart';

class CreateImagePage extends StatefulWidget {
  final List episode;
  final int id;
  final bool isShare;

  const CreateImagePage(
      {super.key,
      required this.episode,
      required this.id,
      required this.isShare});

  @override
  State<CreateImagePage> createState() => _CreateImageState();
}

class _CreateImageState extends State<CreateImagePage> {
  WidgetsToImageController controller = WidgetsToImageController();
  TextEditingController resolutionWidthController = TextEditingController();
  TextEditingController resolutionHeightController = TextEditingController();
  Uint8List? bytes;
  String mainLine = '';
  String beforeLine = '';
  String afterLine = '';
  bool beforeLineCheck = false;
  bool afterLineCheck = false;
  bool showPsychphinder = true;
  bool applyOffset = true;
  bool applyGradient = true;
  bool showBackgroundImage = true;
  int resolutionW = 0;
  int resolutionH = 0;
  String widgetTopRight = 'Episode name';
  String widgetTopLeft = 'Psych logo';
  String widgetBottomLeft = 'Season and episode';
  String widgetBottomRight = 'Time';
  double wallpaperOffset = 16;
  double wallpaperScale = 1.07;
  double psychLogoSize = 18;
  double infoSize = 8;
  double lineSize = 14;
  double secondarylineSize = 8;
  double boxSize = 110;
  double madeWithPsychphidnerSize = 3.5;
  double backgroundSize = 30.0;
  Color bgColor = Colors.green;
  Color lineColor = Colors.white;
  Color beforeLineColor = Colors.white;
  Color afterLineColor = Colors.white;
  Color topLeftColor = Colors.white;
  Color topRightColor = Colors.white;
  Color bottomLeftColor = Colors.white;
  Color bottomRightColor = Colors.white;
  Color psychphinderColor = Colors.white;
  Color backgroundImageColor = Colors.black.withValues(alpha: 0.1);
  List<String> images = [
    'pineapple',
    'psych',
    'fistbump',
    'xmas_tree',
  ];
  List<bool> imagesSelected = [];
  FToast fToast = FToast();
  bool isImagePreviewCollapsed = false;

  @override
  void initState() {
    super.initState();
    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    mainLine = widget.episode[widget.id].line;
    imagesSelected = [for (var i = 0; i < images.length; i++) false];

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

    addFirstTimeProfile();
    !widget.isShare ? getResolution().whenComplete(() => changeOffset()) : null;
    getColors();
    getBackgroundProperties();
    getShowMadeWithPsychphinder();
    getPositions();
    getSelectedImages();
  }

  void updatePositions(String value, int selectedIndex) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (selectedIndex == 0) {
      pref.setString("widgetTopLeft", value);
      setState(() {
        widgetTopLeft = value;
      });
    } else if (selectedIndex == 1) {
      pref.setString("widgetTopRight", value);
      setState(() {
        widgetTopRight = value;
      });
    } else if (selectedIndex == 2) {
      pref.setString("widgetBottomLeft", value);
      setState(() {
        widgetBottomLeft = value;
      });
    } else if (selectedIndex == 3) {
      pref.setString("widgetBottomRight", value);
      setState(() {
        widgetBottomRight = value;
      });
    }
  }

  void updateColor(Color color, int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        setState(() {
          topLeftColor = color;
        });
        break;
      case 1:
        setState(() {
          topRightColor = color;
        });
        break;
      case 2:
        setState(() {
          bottomLeftColor = color;
        });
        break;
      case 3:
        setState(() {
          bottomRightColor = color;
        });
        break;
      case 4:
        setState(() {
          beforeLineColor = color;
        });
        break;
      case 5:
        setState(() {
          lineColor = color;
        });
        break;
      case 6:
        setState(() {
          afterLineColor = color;
        });
        break;
      case 7:
        setState(() {
          bgColor = color;
        });
        break;
      case 8:
        setState(() {
          psychphinderColor = color;
        });
        break;
      case 9:
        setState(() {
          backgroundImageColor = color;
        });
        break;
    }
  }

  @override
  void dispose() {
    resolutionWidthController.dispose();
    resolutionHeightController.dispose();
    super.dispose();
  }

  double get safeBackgroundMaxSize {
    if (widget.isShare) {
      return 1080 / 6;
    }
    double maxSize = resolutionW > 0 ? resolutionW.toDouble() / 6 : 180;
    return maxSize < 10 ? 180 : maxSize;
  }

  double get safeBackgroundSize {
    double maxSize = safeBackgroundMaxSize;
    return backgroundSize.clamp(10.0, maxSize);
  }

  Widget topLeftWidget() {
    switch (widgetTopLeft) {
      case "Psych Logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topLeftColor,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topLeftColor,
          applyOffset: applyOffset,
          isShare: widget.isShare,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: topLeftColor,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: topLeftColor,
        );
      case "None":
        return const SizedBox();
      default:
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topLeftColor,
        );
    }
  }

  Widget topRightWidget() {
    switch (widgetTopRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topRightColor,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topRightColor,
          applyOffset: applyOffset,
          isShare: widget.isShare,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: topRightColor,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: topRightColor,
        );
      case "None":
        return const SizedBox();
      default:
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topRightColor,
          applyOffset: applyOffset,
          isShare: widget.isShare,
          box: boxSize,
        );
    }
  }

  Widget bottomRightWidget() {
    switch (widgetBottomRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: bottomRightColor,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: bottomRightColor,
          applyOffset: applyOffset,
          isShare: widget.isShare,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomRightColor,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomRightColor,
        );
      case "None":
        return const SizedBox();
      default:
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomRightColor,
        );
    }
  }

  Widget bottomLeftWidget() {
    switch (widgetBottomLeft) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: bottomLeftColor,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: bottomLeftColor,
          applyOffset: applyOffset,
          isShare: widget.isShare,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomLeftColor,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomLeftColor,
        );
      case "None":
        return const SizedBox();
      default:
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomLeftColor,
        );
    }
  }

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
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

  Future<void> getResolution() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    int? storedWidth = pref.getInt("ResolutionWidth");
    int? storedHeight = pref.getInt("ResolutionHeight");

    if (storedWidth != null && storedHeight != null) {
      setState(() {
        resolutionW = storedWidth;
        resolutionH = storedHeight;
        resolutionWidthController.text = resolutionW.toString();
        resolutionHeightController.text = resolutionH.toString();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final size = MediaQuery.of(context).size;
          final pixelRatio = MediaQuery.of(context).devicePixelRatio;
          final padding = MediaQuery.of(context).padding;

          setState(() {
            resolutionW = (size.width * pixelRatio).toInt();
            resolutionH =
                ((size.height + padding.bottom + padding.top) * pixelRatio)
                    .toInt();
            resolutionWidthController.text = resolutionW.toString();
            resolutionHeightController.text = resolutionH.toString();
          });

          pref.setInt("ResolutionWidth", resolutionW);
          pref.setInt("ResolutionHeight", resolutionH);
        }
      });
    }
  }

  Future<void> setResolutionHeight(int resolutionHeight) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ResolutionHeight", resolutionHeight);
  }

  Future<void> setResolutionWidth(int resolutionWidth) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ResolutionWidth", resolutionWidth);
  }

  Future<void> setShowBackgoundImage(bool showBackgroundImage) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("showBackgroundImage", showBackgroundImage);
  }

  Future<void> setBackgroundImageSize(double size) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("backgroundSize", backgroundSize);
  }

  Future<void> setApplyGradient(bool applyGradient) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("applyGradient", applyGradient);
  }

  Future<void> setShowMadeWithPsychphinder(
      bool showMadeWithPsychphinder) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("showMadeWithPsychphinder", showMadeWithPsychphinder);
  }

  Future<void> getPositions() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        widgetTopRight = pref.getString("widgetTopRight") ?? "Episode name";
        widgetTopLeft = pref.getString("widgetTopLeft") ?? "Psych logo";
        widgetBottomRight = pref.getString("widgetBottomRight") ?? "Time";
        widgetBottomLeft =
            pref.getString("widgetBottomLeft") ?? "Season and episode";
      },
    );
  }

  Future<void> getShowMadeWithPsychphinder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        showPsychphinder = pref.getBool("showMadeWithPsychphinder") ?? true;
      },
    );
  }

  Future<void> getBackgroundProperties() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        showBackgroundImage = pref.getBool("showBackgroundImage") ?? true;
        backgroundSize = pref.getDouble("backgroundSize") ?? 30.0;
        applyGradient = pref.getBool("applyGradient") ?? true;
      },
    );
  }

  Future<void> getColors() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        bottomRightColor = pref.getInt("bottomRightColor") == null
            ? const Color(0xFFFFEA00)
            : Color(pref.getInt("bottomRightColor")!);
        bottomLeftColor = pref.getInt("bottomLeftColor") == null
            ? const Color(0xFFFFEA00)
            : Color(pref.getInt("bottomLeftColor")!);
        topRightColor = pref.getInt("topRightColor") == null
            ? const Color(0xFFFFEA00)
            : Color(pref.getInt("topRightColor")!);
        topLeftColor = pref.getInt("topLeftColor") == null
            ? const Color(0xFFFFEA00)
            : Color(pref.getInt("topLeftColor")!);
        lineColor = pref.getInt("lineColor") == null
            ? Colors.white
            : Color(pref.getInt("lineColor")!);
        beforeLineColor = pref.getInt("beforeLineColor") == null
            ? Colors.white
            : Color(pref.getInt("beforeLineColor")!);
        afterLineColor = pref.getInt("afterLineColor") == null
            ? Colors.white
            : Color(pref.getInt("afterLineColor")!);
        bgColor = pref.getInt("bgColor") == null
            ? const Color(0xFF39A43D)
            : Color(pref.getInt("bgColor")!);
        psychphinderColor = pref.getInt("psychphinderColor") == null
            ? const Color(0xFFFFEA00)
            : Color(pref.getInt("psychphinderColor")!);
        backgroundImageColor = pref.getInt("backgroundImageColor") == null
            ? Colors.black.withValues(alpha: 0.1)
            : Color(pref.getInt("backgroundImageColor")!);
      },
    );
  }

  Future<void> setColors(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  void reduceSizeBelow1080() {
    if (widget.isShare == false) {
      if (resolutionW < 1080) {
        double ratio = resolutionW / 1080;
        setState(() {
          psychLogoSize = 18 * ratio;
          infoSize = 8 * ratio;
          lineSize = 14 * ratio;
          secondarylineSize = 8 * ratio;
          boxSize = 70;
          madeWithPsychphidnerSize = 3.5 * ratio;
        });
      } else {
        setState(() {
          psychLogoSize = 18;
          infoSize = 8;
          lineSize = 14;
          secondarylineSize = 8;
          boxSize = 110;
          madeWithPsychphidnerSize = 3.5;
        });
      }
    } else {
      setState(() {
        psychLogoSize = 18;
        infoSize = 8;
        lineSize = 14;
        secondarylineSize = 8;
        boxSize = 110;
        madeWithPsychphidnerSize = 3.5;
      });
    }
  }

  Future<void> changeOffset() async {
    setState(() {
      if (resolutionW / resolutionH > 1) {
        applyOffset = false;
      } else {
        applyOffset = true;
      }

      if (applyOffset) {
        wallpaperOffset = 16;
        wallpaperScale = 1.07;
      } else {
        wallpaperOffset = 0;
        wallpaperScale = 1;
      }
    });
  }

  Color darkenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lightenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Future<void> addProfile(String name) async {
    final box = Hive.box("profiles");
    box.add(
      Profile(
        name: name,
        widgetTopLeft: widgetTopLeft,
        widgetTopRight: widgetTopRight,
        widgetBottomLeft: widgetBottomLeft,
        widgetBottomRight: widgetBottomRight,
        bgColor: bgColor.value,
        topLeftColor: topLeftColor.value,
        topRightColor: topRightColor.value,
        bottomLeftColor: bottomLeftColor.value,
        bottomRightColor: bottomRightColor.value,
        lineColor: lineColor.value,
        beforeLineColor: beforeLineColor.value,
        afterLineColor: afterLineColor.value,
        psychphinderColor: psychphinderColor.value,
        backgroundImageColor: backgroundImageColor.value,
        showMadeWithPsychphinder: showPsychphinder,
        applyGradient: applyGradient,
        showBackgroundImage: showBackgroundImage,
        backgroundSize: backgroundSize,
        selectedImgs: List.from(imagesSelected),
      ),
    );
  }

  Future<void> loadProfile(Profile profile) async {
    List<bool> newSelectedImages = [];
    if (images.length != profile.selectedImgs.length) {
      for (int i = 0; i < images.length; i++) {
        if (i < profile.selectedImgs.length) {
          newSelectedImages.add(profile.selectedImgs[i]);
        } else {
          newSelectedImages.add(false);
        }
      }
    } else {
      newSelectedImages = List.from(profile.selectedImgs);
    }
    setState(
      () {
        widgetTopLeft = profile.widgetTopLeft;
        widgetTopRight = profile.widgetTopRight;
        widgetBottomLeft = profile.widgetBottomLeft;
        widgetBottomRight = profile.widgetBottomRight;
        bgColor = Color(profile.bgColor);
        topLeftColor = Color(profile.topLeftColor);
        topRightColor = Color(profile.topRightColor);
        bottomLeftColor = Color(profile.bottomLeftColor);
        bottomRightColor = Color(profile.bottomRightColor);
        lineColor = Color(profile.lineColor);
        beforeLineColor = Color(profile.beforeLineColor);
        afterLineColor = Color(profile.afterLineColor);
        backgroundImageColor = Color(profile.backgroundImageColor);
        showPsychphinder = profile.showMadeWithPsychphinder;
        applyGradient = profile.applyGradient;
        showBackgroundImage = profile.showBackgroundImage;
        backgroundSize = profile.backgroundSize;
        psychphinderColor = Color(profile.psychphinderColor);
        imagesSelected = newSelectedImages;
      },
    );
    setColors("bgColor", profile.bgColor);
    setColors("topLeftColor", profile.topLeftColor);
    setColors("topRightColor", profile.topRightColor);
    setColors("bottomLeftColor", profile.bottomLeftColor);
    setColors("bottomRightColor", profile.bottomRightColor);
    setColors("lineColor", profile.lineColor);
    setColors("beforeLineColor", profile.beforeLineColor);
    setColors("afterLineColor", profile.afterLineColor);
    setColors("psychphinderColor", profile.psychphinderColor);
    setColors("backgroundImageColor", profile.backgroundImageColor);
    setShowBackgoundImage(profile.showBackgroundImage);
    setApplyGradient(profile.applyGradient);
    setShowMadeWithPsychphinder(profile.showMadeWithPsychphinder);
    setBackgroundImageSize(profile.backgroundSize);
    updatePositions(profile.widgetTopLeft, 0);
    updatePositions(profile.widgetTopRight, 1);
    updatePositions(profile.widgetBottomLeft, 2);
    updatePositions(profile.widgetBottomRight, 3);
    setSelectedImages(newSelectedImages);
  }

  Future<void> setSelectedImages(List<bool> imagesSelected) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    for (int i = 0; i < imagesSelected.length; i++) {
      pref.setBool(images[i], imagesSelected[i]);
    }
  }

  Future<void> getSelectedImages() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    for (int i = 0; i < imagesSelected.length; i++) {
      if (i == 3) {
        imagesSelected[i] = pref.getBool(images[i]) ?? false;
      } else {
        imagesSelected[i] = pref.getBool(images[i]) ?? true;
      }
    }
  }

  List<String> getTrueList() {
    List<String> list = [];
    for (int i = 0; i < imagesSelected.length; i++) {
      if (imagesSelected[i] == true) {
        list.add(images[i]);
      }
    }
    return list;
  }

  void addFirstTimeProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final box = Hive.box("profiles");
    if (pref.getBool("firstTimeImage") == null) {
      await pref.setBool("firstTimeImage", true);
      box.add(
        Profile(
          name: "Christmas",
          widgetTopLeft: "Psych logo",
          widgetTopRight: "Episode name",
          widgetBottomLeft: "Season and episode",
          widgetBottomRight: "Time",
          bgColor: const Color(0xFF146B3A).value,
          topLeftColor: const Color(0xFFF8B229).value,
          topRightColor: const Color(0xFFF8B229).value,
          bottomLeftColor: const Color(0xFFF8B229).value,
          bottomRightColor: const Color(0xFFF8B229).value,
          lineColor: const Color(0xFFEA4630).value,
          beforeLineColor: const Color(0xFFFFFFFF).value,
          afterLineColor: const Color(0xFFFFFFFF).value,
          psychphinderColor: const Color(0xFFF8B229).value,
          backgroundImageColor: const Color(0x3B000000).value,
          showMadeWithPsychphinder: true,
          applyGradient: true,
          showBackgroundImage: true,
          backgroundSize: 44.0,
          selectedImgs: [true, true, false, true],
        ),
      );
      box.add(
        Profile(
          name: "Christmas 2",
          widgetTopLeft: "Psych logo",
          widgetTopRight: "Episode name",
          widgetBottomLeft: "Season and episode",
          widgetBottomRight: "Time",
          bgColor: const Color(0xFFA22C2B).value,
          topLeftColor: const Color(0xFF209954).value,
          topRightColor: const Color(0xFF209954).value,
          bottomLeftColor: const Color(0xFF209954).value,
          bottomRightColor: const Color(0xFF209954).value,
          lineColor: const Color(0xFFF8B229).value,
          beforeLineColor: const Color(0xFFFFFFFF).value,
          afterLineColor: const Color(0xFFFFFFFF).value,
          psychphinderColor: const Color(0xFF209954).value,
          backgroundImageColor: const Color(0x2C000000).value,
          showMadeWithPsychphinder: true,
          applyGradient: true,
          showBackgroundImage: true,
          backgroundSize: 35.5,
          selectedImgs: [true, true, true, true],
        ),
      );
    }
  }

  Widget _buildImageContent() {
    List<String> selectedBackgroundImage = getTrueList();
    int counter = 0;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        gradient: applyGradient
            ? LinearGradient(
                colors: [
                  lightenColor(bgColor, 0.1),
                  bgColor,
                  darkenColor(bgColor, 0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
      ),
      child: Stack(
        children: [
          showBackgroundImage
              ? GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: backgroundSize,
                    mainAxisExtent: backgroundSize,
                  ),
                  itemBuilder: (context, index) {
                    if (selectedBackgroundImage.isNotEmpty) {
                      counter++;
                      if (counter == selectedBackgroundImage.length) {
                        counter = 0;
                      }
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          "assets/background/${selectedBackgroundImage[counter]}.png",
                          color: backgroundImageColor,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              : Container(),
          Positioned(
            top: widget.isShare == true
                ? (widgetTopLeft == 'Psych logo' ? -2 : 5)
                : (widgetTopLeft == 'Psych logo'
                    ? (9 + wallpaperOffset)
                    : (17 + wallpaperOffset)),
            left: widget.isShare == true ? 5 : (5 + wallpaperOffset),
            child: topLeftWidget(),
          ),
          Positioned(
              top: widget.isShare == true
                  ? (widgetTopRight == 'Psych logo' ? -2 : 5)
                  : (widgetTopRight == 'Psych logo'
                      ? (9 + wallpaperOffset)
                      : (17 + wallpaperOffset)),
              right: widget.isShare == true ? 5 : (5 + wallpaperOffset),
              child: topRightWidget()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                beforeLineCheck
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                        child: ConstrainedBox(
                          constraints: widget.isShare == false
                              ? applyOffset
                                  ? const BoxConstraints(maxWidth: 155)
                                  : const BoxConstraints()
                              : const BoxConstraints(),
                          child: TextWidget(
                            text: beforeLine,
                            size: widget.isShare == false
                                ? secondarylineSize / wallpaperScale
                                : secondarylineSize,
                            textColor: beforeLineColor,
                          ),
                        ))
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: ConstrainedBox(
                    constraints: widget.isShare == false
                        ? applyOffset
                            ? const BoxConstraints(maxWidth: 155)
                            : const BoxConstraints()
                        : const BoxConstraints(),
                    child: TextWidget(
                      text: mainLine,
                      size: widget.isShare == false
                          ? lineSize / wallpaperScale
                          : lineSize,
                      textColor: lineColor,
                    ),
                  ),
                ),
                afterLineCheck
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                        child: ConstrainedBox(
                          constraints: widget.isShare == false
                              ? applyOffset
                                  ? const BoxConstraints(maxWidth: 155)
                                  : const BoxConstraints()
                              : const BoxConstraints(),
                          child: TextWidget(
                            text: afterLine,
                            size: widget.isShare == false
                                ? secondarylineSize / wallpaperScale
                                : secondarylineSize,
                            textColor: afterLineColor,
                          ),
                        ))
                    : const SizedBox(),
              ],
            ),
          ),
          Positioned(
            bottom: widget.isShare == true
                ? (widgetBottomLeft == 'Psych logo' ? 0 : 5)
                : (widgetBottomLeft == 'Psych logo'
                    ? (5 + wallpaperOffset)
                    : (10 + wallpaperOffset)),
            left: widget.isShare == true ? 5 : (5 + wallpaperOffset),
            child: bottomLeftWidget(),
          ),
          Positioned(
            bottom: widget.isShare == true
                ? (widgetBottomRight == 'Psych logo' ? 2 : 5)
                : (widgetBottomRight == 'Psych logo'
                    ? (7 + wallpaperOffset)
                    : (10 + wallpaperOffset)),
            right: widget.isShare == true ? 5 : (5 + wallpaperOffset),
            child: bottomRightWidget(),
          ),
          showPsychphinder
              ? Positioned(
                  bottom: widget.isShare == true ? 1 : (6 + wallpaperOffset),
                  right: widget.isShare == true ? 1 : (1 + wallpaperOffset),
                  child: Text(
                    "Made with psychphinder",
                    style: TextStyle(
                      fontSize: madeWithPsychphidnerSize,
                      fontFamily: 'PsychFont',
                      color: psychphinderColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      child: WidgetsToImage(
        controller: controller,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildOptionsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Customization', Icons.palette),
          const SizedBox(height: 12),
          _buildCustomizationCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Profiles', Icons.bookmark),
          const SizedBox(height: 12),
          _buildProfilesCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Actions', Icons.share),
          const SizedBox(height: 12),
          _buildActionButtons(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    reduceSizeBelow1080();
    !widget.isShare
        ? resolutionW == 0
            ? resolutionW = 1080
            : null
        : null;
    !widget.isShare
        ? resolutionH == 0
            ? resolutionH = 1920
            : null
        : null;

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isLargeScreen = screenSize.width > 800;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.isShare ? 'Share' : 'Create image',
          style: TextStyle(
            fontSize: 25,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: isLandscape && isLargeScreen
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.isShare == true
                            ? 1080 / 1080
                            : resolutionW / resolutionH,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.7,
                            maxWidth: screenSize.width * 0.4,
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              height: widget.isShare == true
                                  ? 1080 / 6
                                  : (resolutionH) / 6,
                              width: widget.isShare == true
                                  ? 1080 / 6
                                  : (resolutionW) / 6,
                              child: _buildImagePreview(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildOptionsPanel(),
                ),
              ],
            )
          : Column(
              children: [
                if (!isImagePreviewCollapsed)
                  Container(
                    height: isLandscape
                        ? screenSize.height * 0.4
                        : screenSize.height * 0.35,
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.isShare == true
                            ? 1080 / 1080
                            : resolutionW / resolutionH,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            height: widget.isShare == true
                                ? 1080 / 6
                                : (resolutionH) / 6,
                            width: widget.isShare == true
                                ? 1080 / 6
                                : (resolutionW) / 6,
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Image Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            isImagePreviewCollapsed = !isImagePreviewCollapsed;
                          });
                        },
                        tooltip: isImagePreviewCollapsed
                            ? 'Show Preview'
                            : 'Hide Preview',
                        child: AnimatedRotation(
                          turns: isImagePreviewCollapsed ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isImagePreviewCollapsed
                                ? Icons.expand_more
                                : Icons.expand_less,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildOptionsPanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'PsychFont',
          ),
        ),
        const Spacer(),
        Container(
          height: 2,
          width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isShare) ...[
              _buildResolutionSection(),
              const SizedBox(height: 24),
            ],
            _buildTextPositionsSection(context),
            const SizedBox(height: 24),
            _buildQuoteCustomizationSection(context),
            const SizedBox(height: 24),
            _buildBackgroundSection(context),
            const SizedBox(height: 24),
            _buildMiscellaneousSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: profiles(context),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: buttonOptions(context),
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildStyledTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    Function(String)? onSubmitted,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLength: keyboardType == TextInputType.number ? 4 : null,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }

  Widget _buildTextPositionRow(String label, String currentValue,
      Color currentColor, int index, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          modernColorPickerWidget(
              context, currentColor, index, _getColorKey(index)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: modernDropdownButton(context, currentValue, index),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteLineRow(String label, String value, bool isEnabled,
      Color color, int colorIndex, String colorKey,
      {bool isMain = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMain
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMain
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor,
          width: isMain ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$label Line',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (!isMain)
                Checkbox(
                  value: isEnabled,
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.onPrimary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.outline),
                  onChanged: (value) {
                    setState(() {
                      if (label == 'Before') {
                        beforeLineCheck = value!;
                      } else if (label == 'After') {
                        afterLineCheck = value!;
                      }
                    });
                  },
                ),
              if (isEnabled || isMain)
                modernColorPickerWidget(context, color, colorIndex, colorKey),
            ],
          ),
          const SizedBox(height: 8),
          _buildStyledTextField(
            label: '$label line text',
            initialValue: value,
            onChanged: (newValue) {
              setState(() {
                if (label == 'Before') {
                  beforeLine = newValue;
                } else if (label == 'Main') {
                  mainLine = newValue;
                } else if (label == 'After') {
                  afterLine = newValue;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, Color color, int index, String colorKey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          modernColorPickerWidget(context, color, index, colorKey),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Theme.of(context).colorScheme.primary,
            activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
            inactiveThumbColor: Theme.of(context).colorScheme.outline,
            inactiveTrackColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImageCustomization() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Image Overlay Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              modernColorPickerWidget(
                  context, backgroundImageColor, 9, 'backgroundImageColor',
                  showAlpha: true),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Image Size',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
            child: Slider(
              value: safeBackgroundSize,
              max: safeBackgroundMaxSize,
              min: 10,
              divisions: 20,
              onChanged: (double value) {
                setState(() {
                  backgroundSize = value;
                });
              },
              onChangeEnd: (double value) {
                setBackgroundImageSize(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Background Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: imagesSelected[index]
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                      width: imagesSelected[index] ? 3 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          imagesSelected[index] = !imagesSelected[index];
                          setSelectedImages(imagesSelected);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/background/${images[index]}.png',
                          color: imagesSelected[index]
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getColorKey(int index) {
    switch (index) {
      case 0:
        return 'topLeftColor';
      case 1:
        return 'topRightColor';
      case 2:
        return 'bottomLeftColor';
      case 3:
        return 'bottomRightColor';
      default:
        return 'topLeftColor';
    }
  }

  Widget modernColorPickerWidget(
      BuildContext context, Color currentColor, int index, String key,
      {bool showAlpha = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: currentColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _showModernColorPicker(
              context, currentColor, index, key, showAlpha),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: currentColor,
            ),
            child: Icon(
              Icons.palette,
              color: _getContrastColor(currentColor),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget modernDropdownButton(BuildContext context, String current, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: current,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem(
            value: 'Psych logo',
            child: Text('Psych logo'),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Episode name'
                : 'Movie name',
            child: Text(widget.episode[widget.id].season != 0
                ? 'Episode name'
                : 'Movie name'),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Season and episode'
                : 'Movie',
            child: Text(widget.episode[widget.id].season != 0
                ? 'Season and episode'
                : 'Movie'),
          ),
          const DropdownMenuItem(
            value: 'Time',
            child: Text('Time'),
          ),
          const DropdownMenuItem(
            value: 'None',
            child: Text('None'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            updatePositions(value!, index);
          });
        },
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showModernColorPicker(BuildContext context, Color currentColor,
      int index, String key, bool showAlpha) {
    Color selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Pick a Color',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: HueRingPicker(
              portraitOnly: true,
              pickerColor: selectedColor,
              displayThumbColor: true,
              enableAlpha: showAlpha,
              onColorChanged: (color) {
                selectedColor = color;
                updateColor(color, index);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setColors(key, selectedColor.value);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
          if (key != 'bgColor' && key != 'backgroundImageColor') ...[
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (key == 'beforeLineColor' ||
                    key == 'lineColor' ||
                    key == 'afterLineColor') {
                  updateColor(selectedColor, 4);
                  updateColor(selectedColor, 5);
                  updateColor(selectedColor, 6);
                  setColors('beforeLineColor', selectedColor.value);
                  setColors('lineColor', selectedColor.value);
                  setColors('afterLineColor', selectedColor.value);
                } else {
                  updateColor(selectedColor, 0);
                  updateColor(selectedColor, 1);
                  updateColor(selectedColor, 2);
                  updateColor(selectedColor, 3);
                  updateColor(selectedColor, 8);
                  setColors('topLeftColor', selectedColor.value);
                  setColors('topRightColor', selectedColor.value);
                  setColors('bottomLeftColor', selectedColor.value);
                  setColors('bottomRightColor', selectedColor.value);
                  setColors('psychphinderColor', selectedColor.value);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                key == 'beforeLineColor' ||
                        key == 'lineColor' ||
                        key == 'afterLineColor'
                    ? 'Apply to All Text'
                    : 'Apply to All Corners',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResolutionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader('Resolution'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: resolutionWidthController,
                decoration: InputDecoration(
                  labelText: 'Width',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  counterText: "",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setState(() {
                        resolutionW = parsed;
                        setResolutionWidth(resolutionW);
                        changeOffset();
                      });
                    }
                  }
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setState(() {
                        resolutionW = parsed;
                        backgroundSize =
                            backgroundSize.clamp(10.0, safeBackgroundMaxSize);
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            const Text('×',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: resolutionHeightController,
                decoration: InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  counterText: "",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setState(() {
                        resolutionH = parsed;
                        setResolutionHeight(resolutionH);
                        changeOffset();
                      });
                    }
                  }
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      setState(() {
                        resolutionH = parsed;
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextPositionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader('Text Positions'),
        const SizedBox(height: 16),
        _buildTextPositionRow(
            'Top Left', widgetTopLeft, topLeftColor, 0, context),
        const SizedBox(height: 12),
        _buildTextPositionRow(
            'Top Right', widgetTopRight, topRightColor, 1, context),
        const SizedBox(height: 12),
        _buildTextPositionRow(
            'Bottom Left', widgetBottomLeft, bottomLeftColor, 2, context),
        const SizedBox(height: 12),
        _buildTextPositionRow(
            'Bottom Right', widgetBottomRight, bottomRightColor, 3, context),
      ],
    );
  }

  Widget _buildQuoteCustomizationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader('Quote Text'),
        const SizedBox(height: 16),
        _buildQuoteLineRow('Before', beforeLine, beforeLineCheck,
            beforeLineColor, 4, 'beforeLineColor'),
        const SizedBox(height: 12),
        _buildQuoteLineRow('Main', mainLine, true, lineColor, 5, 'lineColor',
            isMain: true),
        const SizedBox(height: 12),
        _buildQuoteLineRow('After', afterLine, afterLineCheck, afterLineColor,
            6, 'afterLineColor'),
      ],
    );
  }

  Widget _buildBackgroundSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader('Background'),
        const SizedBox(height: 16),
        _buildColorRow('Background Color', bgColor, 7, 'bgColor'),
        const SizedBox(height: 16),
        _buildSwitchRow('Apply Gradient', applyGradient, (value) {
          setState(() {
            applyGradient = value;
            setApplyGradient(applyGradient);
          });
        }),
        const SizedBox(height: 16),
        _buildSwitchRow('Show Background Images', showBackgroundImage, (value) {
          setState(() {
            showBackgroundImage = value;
            setShowBackgoundImage(showBackgroundImage);
          });
        }),
        if (showBackgroundImage) ...[
          const SizedBox(height: 16),
          _buildBackgroundImageCustomization(),
        ],
      ],
    );
  }

  Widget _buildMiscellaneousSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader('Additional Options'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSwitchRow(
                  'Show \"Made with psychphinder\"', showPsychphinder, (value) {
                setState(() {
                  showPsychphinder = value;
                  setShowMadeWithPsychphinder(showPsychphinder);
                });
              }),
            ),
            if (showPsychphinder)
              modernColorPickerWidget(
                  context, psychphinderColor, 8, 'psychphinderColor'),
          ],
        ),
        if (!widget.isShare) ...[
          const SizedBox(height: 16),
          _buildSwitchRow('Apply Offset Fix', applyOffset, (value) {
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
          }),
        ],
      ],
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    String name = '';
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.bookmark_add_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Create Profile',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'PsychFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a name for your profile to save current settings:',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Profile name',
                  hintText: 'e.g., Dark Mode Setup',
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.bookmark_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  name = value;
                },
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    addProfile(value.trim());
                    Navigator.pop(context);
                    _showToast('Profile \"$value\" created!');
                  }
                },
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (name.trim().isNotEmpty) {
                addProfile(name.trim());
                Navigator.pop(context);
                _showToast('Profile \"$name\" created!');
              }
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProfileDialog(BuildContext context, dynamic box, int index) {
    final profileName = box.getAt(index).name;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Profile',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the profile \"$profileName\"?\\n\\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await box.deleteAt(index);
              Navigator.pop(context);
              _showToast('Profile \"$profileName\" deleted!');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget profiles(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("profiles").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        final profilesList = box.values.toList();
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profilesList.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 48,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No profiles found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create your first profile to save your settings",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.bookmark,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              profilesList[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Tap to apply this profile',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () =>
                                  _showDeleteProfileDialog(context, box, index),
                            ),
                            onTap: () async {
                              await loadProfile(profilesList[index]);
                              _showToast(
                                  'Profile \"${profilesList[index].name}\" applied!');
                            },
                          ),
                        );
                      },
                      itemCount: profilesList.length,
                    ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => _showAddProfileDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Create New Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buttonOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _modernShareButton()),
            if (!kIsWeb && Platform.isAndroid) ...[
              const SizedBox(width: 12),
              Expanded(child: _modernSaveToGalleryButton()),
            ],
          ],
        ),
        if (!kIsWeb && !widget.isShare && Platform.isAndroid) ...[
          const SizedBox(height: 12),
          _modernWallpaperButton(context),
        ],
      ],
    );
  }

  Widget _modernShareButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => _handleShareImage(),
      icon: Icon(_getShareIcon()),
      label: Text(
        _getShareText(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _modernSaveToGalleryButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => _handleSaveToGallery(),
      icon: const Icon(Icons.photo_library_rounded),
      label: const Text(
        'Gallery',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _modernWallpaperButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => _handleSetWallpaper(context),
      icon: const Icon(Icons.wallpaper_rounded),
      label: const Text(
        'Set as Wallpaper',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getShareIcon() {
    if (kIsWeb) return Icons.download_rounded;
    return Platform.isAndroid ? Icons.share_rounded : Icons.save_rounded;
  }

  String _getShareText() {
    if (kIsWeb) return 'Download';
    return Platform.isAndroid ? 'Share' : 'Save';
  }

  Future<void> _handleShareImage() async {
    final bytes = await controller.capture();
    setState(() {
      this.bytes = bytes;
    });

    if (!kIsWeb) {
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
    } else {
      await FileSaver.instance
          .saveFile(name: 'psychphinder.png', bytes: bytes!);
      _showToast("Downloaded image!");
    }
  }

  Future<void> _handleSaveToGallery() async {
    final bytes = await controller.capture();
    setState(() {
      this.bytes = bytes;
    });

    if (!kIsWeb && Platform.isAndroid) {
      final cacheDir = await getTemporaryDirectory();
      await Gal.putImageBytes(bytes!);
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      _showToast("Saved to gallery!");
    }
  }

  Future<void> _handleSetWallpaper(BuildContext context) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Set Wallpaper',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose where to set the wallpaper:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildWallpaperOption('Home Screen', Icons.home_rounded,
                WallpaperLocation.homeScreen),
            const SizedBox(height: 12),
            _buildWallpaperOption('Lock Screen', Icons.lock_rounded,
                WallpaperLocation.lockScreen),
            const SizedBox(height: 12),
            _buildWallpaperOption('Both Screens', Icons.phone_android_rounded,
                WallpaperLocation.bothScreens),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperOption(
      String title, IconData icon, WallpaperLocation location) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
          bool result = await WallpaperHandler.instance
              .setWallpaperFromFile(fileName, location);
          if (result) {
            _showToast("Set as wallpaper!");
            if (cacheDir.existsSync()) {
              cacheDir.deleteSync(recursive: true);
            }
          }
          Navigator.pop(context);
        },
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget customization(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: const Text(
            'Customization',
          ),
          children: [
            widget.isShare == false
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Resolution',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: resolutionWidthController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Width',
                              counterText: "",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed > 0) {
                                  setState(() {
                                    resolutionW = parsed;
                                    setResolutionWidth(resolutionW);
                                    changeOffset();
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'x',
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: resolutionHeightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Height',
                              counterText: "",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed > 0) {
                                  setState(() {
                                    resolutionH = parsed;
                                    setResolutionHeight(resolutionH);
                                    changeOffset();
                                  });
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Top left text',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      colorPickerWidget(
                          context, topLeftColor, 0, "topLeftColor"),
                      dropdownButton(context, widgetTopLeft, 0),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Top right text',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      colorPickerWidget(
                          context, topRightColor, 1, "topRightColor"),
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
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                    onChanged: (value) {
                      setState(() {
                        beforeLineCheck = value!;
                      });
                    },
                  ),
                  beforeLineCheck
                      ? colorPickerWidget(
                          context,
                          beforeLineColor,
                          4,
                          "beforeLineColor",
                          size: 12,
                        )
                      : const SizedBox(),
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
                  colorPickerWidget(
                    context,
                    lineColor,
                    5,
                    "lineColor",
                    size: 12,
                  )
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
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                    onChanged: (value) {
                      setState(() {
                        afterLineCheck = value!;
                      });
                    },
                  ),
                  afterLineCheck
                      ? colorPickerWidget(
                          context,
                          afterLineColor,
                          6,
                          "afterLineColor",
                          size: 12,
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bottom left text',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      colorPickerWidget(
                          context, bottomLeftColor, 2, "bottomLeftColor"),
                      dropdownButton(context, widgetBottomLeft, 2),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Bottom right text',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      colorPickerWidget(
                          context, bottomRightColor, 3, "bottomRightColor"),
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
                  ),
                  const Spacer(),
                  colorPickerWidget(context, bgColor, 7, "bgColor"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "Apply gradient to background",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch(
                    value: applyGradient,
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    inactiveThumbColor: Theme.of(context).colorScheme.outline,
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    onChanged: (bool value) {
                      setState(() {
                        applyGradient = value;
                        setApplyGradient(applyGradient);
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
                  const Text(
                    "Show background image",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch(
                    value: showBackgroundImage,
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    inactiveThumbColor: Theme.of(context).colorScheme.outline,
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    onChanged: (bool value) {
                      setState(() {
                        showBackgroundImage = value;
                        setShowBackgoundImage(showBackgroundImage);
                      });
                    },
                  ),
                ],
              ),
            ),
            showBackgroundImage
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Background image color/size",
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            colorPickerWidget(context, backgroundImageColor, 9,
                                "backgroundImageColor",
                                showAlpha: true),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTickMarkColor: Colors.transparent,
                            inactiveTickMarkColor: Colors.transparent,
                            trackHeight: 20,
                          ),
                          child: Slider(
                            value: safeBackgroundSize,
                            max: safeBackgroundMaxSize,
                            min: 10,
                            divisions: 20,
                            onChanged: (double value) {
                              setState(() {
                                backgroundSize = value;
                              });
                            },
                            onChangeEnd: (double value) {
                              setBackgroundImageSize(value);
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "Background image",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int index = 0;
                                      index < images.length;
                                      index++)
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Center(
                                        child: ListTile(
                                          title: Image.asset(
                                            "assets/background/${images[index]}.png",
                                            color: imagesSelected[index]
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              setSelectedImages(imagesSelected);
                                              imagesSelected[index] =
                                                  !imagesSelected[index];
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "Show \"Made with psychphinder\"",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  showPsychphinder
                      ? colorPickerWidget(
                          context, psychphinderColor, 8, "psychphinderColor")
                      : const SizedBox(),
                  Switch(
                    value: showPsychphinder,
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    inactiveThumbColor: Theme.of(context).colorScheme.outline,
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    onChanged: (bool value) {
                      setState(() {
                        showPsychphinder = value;
                        setShowMadeWithPsychphinder(showPsychphinder);
                      });
                    },
                  ),
                ],
              ),
            ),
            widget.isShare == false
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          "Apply offset fix",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Switch(
                          value: applyOffset,
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.outline,
                          inactiveTrackColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
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
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Padding colorPickerWidget(
      BuildContext context, Color currentColor, int index, String key,
      {double size = 16, bool showAlpha = false}) {
    Color newColor = currentColor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Pick a color",
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: PopScope(
                      onPopInvokedWithResult: (bool didPop, Object? result) {
                        setColors(key, newColor.value);
                        if (didPop) {
                          return;
                        }
                      },
                      child: HueRingPicker(
                        portraitOnly: true,
                        pickerColor: newColor,
                        displayThumbColor: true,
                        enableAlpha: showAlpha,
                        onColorChanged: (value) {
                          setState(() {
                            newColor = value;
                            updateColor(newColor, index);
                          });
                        },
                      )),
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    setColors(key, newColor.value);
                    Navigator.of(context).pop();
                  },
                ),
                key != "bgColor" && key != "backgroundImageColor"
                    ? key == "beforeLineColor" ||
                            key == "lineColor" ||
                            key == "afterLineColor"
                        ? ElevatedButton(
                            child: const Text('Apply to all center text'),
                            onPressed: () {
                              updateColor(newColor, 4);
                              updateColor(newColor, 5);
                              updateColor(newColor, 6);
                              setColors("beforeLineColor", newColor.value);
                              setColors("lineColor", newColor.value);
                              setColors("afterLineColor", newColor.value);
                              Navigator.of(context).pop();
                            },
                          )
                        : ElevatedButton(
                            child: const Text('Apply to all border text'),
                            onPressed: () {
                              updateColor(newColor, 0);
                              updateColor(newColor, 1);
                              updateColor(newColor, 2);
                              updateColor(newColor, 3);
                              updateColor(newColor, 8);
                              setColors("topLeftColor", newColor.value);
                              setColors("topRightColor", newColor.value);
                              setColors("bottomLeftColor", newColor.value);
                              setColors("bottomRightColor", newColor.value);
                              setColors("psychphinderColor", newColor.value);
                              Navigator.of(context).pop();
                            },
                          )
                    : const SizedBox(),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size.fromRadius(size),
            maximumSize: Size.fromRadius(size),
            backgroundColor: newColor,
            shape: CircleBorder(
              side: BorderSide(
                  color: Provider.of<ThemeProvider>(context).currentThemeType ==
                          ThemeType.light
                      ? Colors.black
                      : Colors.white,
                  width: 2),
            )),
        child: CircleAvatar(
          backgroundColor: newColor,
          radius: size,
        ),
      ),
    );
  }

  SizedBox dropdownButton(BuildContext context, String current, int index) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        iconSize: 30,
        iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
        dropdownColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        value: current,
        items: [
          DropdownMenuItem(
            value: 'Psych logo',
            child: Text(
              'Psych logo',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              overflow: TextOverflow.ellipsis,
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
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              overflow: TextOverflow.ellipsis,
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
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const DropdownMenuItem(
            value: 'Time',
            child: Text(
              'Time',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const DropdownMenuItem(
            value: 'None',
            child: Text(
              'None',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            updatePositions(value!, index);
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
  });

  final String text;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.time,
    required this.size,
    required this.textColor,
  });
  final String time;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: time[0] == '0' ? time.substring(2) : time,
        size: size,
        textColor: textColor,
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
  });
  final String season;
  final String episode;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: season == "999" || season == "0"
            ? "Movie"
            : "Season $season, Episode $episode",
        size: size,
        textColor: textColor,
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
    required this.isShare,
    required this.box,
  });
  final String name;
  final double size;
  final Color textColor;
  final bool applyOffset;
  final bool isShare;
  final double box;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
          constraints: isShare == false
              ? (applyOffset
                  ? BoxConstraints(maxWidth: box - 20)
                  : BoxConstraints(maxWidth: box))
              : BoxConstraints(maxWidth: box),
          child: TextWidget(
            text: name,
            size: size,
            textColor: textColor,
          )),
    );
  }
}

class PsychLogoWidget extends StatelessWidget {
  const PsychLogoWidget({
    super.key,
    required this.size,
    required this.textColor,
  });
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      "psych",
      style: TextStyle(
        fontSize: size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: -1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}
