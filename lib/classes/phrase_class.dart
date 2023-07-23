import 'package:hive/hive.dart';
part 'phrase_class.g.dart';

@HiveType(typeId: 1)
class Phrase extends HiveObject{
  @HiveField(0)
  int id;
  @HiveField(1)
  int season;
  @HiveField(2)
  int episode;
  @HiveField(3)
  String name;
  @HiveField(4)
  String time;
  @HiveField(5)
  String line;
  @HiveField(6)
  String reference;

  Phrase(
      {required this.id,
      required this.season,
      required this.episode,
      required this.name,
      required this.time,
      required this.line,
      required this.reference});
}