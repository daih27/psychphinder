import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/classes/reference_class.dart';

class CSVData extends ChangeNotifier {
  final List data = [];
  final List<String> seasons = [];
  final Map<String, List<String>> episodesMap = {};
  final Map<String, Map<String, List<String>>> mapData = {};
  final List referenceData = [];

  bool isDataLoaded = false;

  Future<void> loadDataFromCSV() async {
    if (isDataLoaded) return;
    final rawData = await rootBundle.loadString("assets/data.csv");
    List<List<dynamic>> listData = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\r\n', shouldParseNumbers: true)
        .convert(rawData);
    for (var i = 0; i < listData.length; i++) {
      data.add(Phrase(
        id: listData[i][0],
        season: listData[i][1],
        episode: listData[i][2],
        name: listData[i][3].toString(),
        time: listData[i][4].toString(),
        line: listData[i][5].toString(),
        reference: listData[i][6].toString(),
      ));
    }
    final rawData2 = await rootBundle.loadString("assets/episodes.csv");
    List<List<dynamic>> listData2 = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\n', shouldParseNumbers: true)
        .convert(rawData2);

    for (var i = 0; i < listData2.length; i++) {
      if (!seasons.contains(listData2[i][0].toString())) {
        seasons.add(listData2[i][0].toString());
      }
      if (episodesMap.containsKey(listData2[i][0].toString())) {
        if (listData2[i][1].toString() != "All") {
          episodesMap[listData2[i][0].toString()]?.add(
              "${listData2[i][1].toString()} - ${listData2[i][2].toString()}");
        } else {
          episodesMap[listData2[i][0].toString()]
              ?.add(listData2[i][1].toString());
        }
      } else {
        if (listData2[i][1].toString() != "All") {
          episodesMap[listData2[i][0].toString()] = [
            "${listData2[i][1].toString()} - ${listData2[i][2].toString()}"
          ];
        } else {
          episodesMap[listData2[i][0].toString()] = [
            listData2[i][1].toString()
          ];
        }
      }
    }

    final rawData3 = await rootBundle.loadString("assets/references.csv");
    List<List<dynamic>> listData3 = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\r', shouldParseNumbers: true)
        .convert(rawData3);

    for (var i = 0; i < listData3.length; i++) {
      referenceData.add(Reference(
        season: listData3[i][0],
        episode: listData3[i][1],
        name: listData3[i][2].toString(),
        reference: listData3[i][3].toString(),
        id: listData3[i][4].toString(),
        idLine: listData3[i][5].toString(),
        link: listData3[i][6].toString(),
      ));

      if (!mapData.containsKey(referenceData[i].season.toString())) {
        mapData[referenceData[i].season.toString()] = {};
      }

      if (!mapData[referenceData[i].season.toString()]!.containsKey(
          "${referenceData[i].episode} - ${referenceData[i].name}")) {
        mapData[referenceData[i].season.toString()]![
            "${referenceData[i].episode} - ${referenceData[i].name}"] = [];
      }

      mapData[referenceData[i].season.toString()]![
              "${referenceData[i].episode} - ${referenceData[i].name}"]!
          .add(referenceData[i].reference);
    }

    isDataLoaded = true;
    notifyListeners();
  }
}
