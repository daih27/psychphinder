import 'package:flutter/foundation.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';

class CSVData extends ChangeNotifier {
  final List data = [];
  final List<String> seasons = [];
  final Map<String, List<String>> episodesMap = {};
  final Map<String, Map<String, List<String>>> mapData = {};
  final List referenceData = [];
  final DatabaseService _databaseService = DatabaseService();

  bool isDataLoaded = false;

  Future<void> loadDataFromCSV() async {
    if (isDataLoaded) return;

    List<Phrase> allQuotes = await _databaseService.getAllQuotes();
    data.addAll(allQuotes);

    await _loadSeasonsAndEpisodes();

    referenceData.addAll(await _databaseService.getReferences());

    _buildReferenceMap();

    isDataLoaded = true;
    notifyListeners();
  }

  Future<void> _loadSeasonsAndEpisodes() async {
    final seasonNums = await _databaseService.getSeasons();
    for (var seasonNum in seasonNums) {
      String seasonStr = seasonNum == 0 ? 'Movies' : seasonNum.toString();
      if (!seasons.contains(seasonStr)) {
        seasons.add(seasonStr);
      }

      final episodes = await _databaseService.getEpisodesForSeason(seasonNum);

      List<String> episodeList = ['All'];
      for (var episode in episodes) {
        episodeList.add("${episode['episode']} - ${episode['name']}");
      }

      episodesMap[seasonStr] = episodeList;
    }

    seasons.sort((a, b) {
      if (a == 'Movies') return -1;
      if (b == 'Movies') return 1;
      return int.parse(a).compareTo(int.parse(b));
    });
  }

  void _buildReferenceMap() {
    for (var ref in referenceData) {
      String seasonKey = ref.season == 0 ? 'Movies' : ref.season.toString();

      if (!mapData.containsKey(seasonKey)) {
        mapData[seasonKey] = {};
      }

      String episodeKey = "${ref.episode} - ${ref.name}";
      if (!mapData[seasonKey]!.containsKey(episodeKey)) {
        mapData[seasonKey]![episodeKey] = [];
      }

      mapData[seasonKey]![episodeKey]!.add(ref.reference);
    }
  }

  Future<List<Phrase>> searchQuotes(String query,
      {String? season, String? episode}) async {
    return await _databaseService.searchQuotes(query,
        season: season, episode: episode);
  }
}
