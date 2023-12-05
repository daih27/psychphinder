// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';
part 'profile_class.g.dart';

@HiveType(typeId: 2)
class Profile extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String widgetTopLeft;
  @HiveField(2)
  String widgetTopRight;
  @HiveField(3)
  String widgetBottomLeft;
  @HiveField(4)
  String widgetBottomRight;
  @HiveField(5)
  int bgColor;
  @HiveField(6)
  int topLeftColor;
  @HiveField(7)
  int topRightColor;
  @HiveField(8)
  int bottomLeftColor;
  @HiveField(9)
  int bottomRightColor;
  @HiveField(10)
  int lineColor;
  @HiveField(11)
  int beforeLineColor;
  @HiveField(12)
  int afterLineColor;
  @HiveField(13)
  int psychphinderColor;
  @HiveField(14)
  int backgroundImageColor;
  @HiveField(15)
  bool showMadeWithPsychphinder;
  @HiveField(16)
  bool applyGradient;
  @HiveField(17)
  bool showBackgroundImage;
  @HiveField(18)
  double backgroundSize;
  @HiveField(19)
  List<bool> selectedImgs;

  Profile({
    required this.name,
    required this.widgetTopLeft,
    required this.widgetTopRight,
    required this.widgetBottomLeft,
    required this.widgetBottomRight,
    required this.bgColor,
    required this.topLeftColor,
    required this.topRightColor,
    required this.bottomLeftColor,
    required this.bottomRightColor,
    required this.lineColor,
    required this.beforeLineColor,
    required this.afterLineColor,
    required this.psychphinderColor,
    required this.backgroundImageColor,
    required this.showMadeWithPsychphinder,
    required this.applyGradient,
    required this.showBackgroundImage,
    required this.backgroundSize,
    required this.selectedImgs,
  });
}
