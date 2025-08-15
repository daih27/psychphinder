import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';

class EpisodeUtil {
  static List<Phrase> full = <Phrase>[];
  static int index = 0;
  static final DatabaseService _databaseService = DatabaseService();

  static Future<void> loadEpisode(Phrase phrase) async {
    full =
        await _databaseService.getEpisodePhrases(phrase.season, phrase.episode);

    index = 0;
    for (var i = 0; i < full.length; i++) {
      if (full[i].id == phrase.id) {
        index = i;
        break;
      }
    }
  }

  static Future<void> loadEpisodeById(int phraseId) async {
    final result = await _databaseService.getPhraseWithEpisode(phraseId);
    if (result.phrase != null) {
      full = result.episode;
      index = result.index;
    }
  }

  // New optimized method using direct sequence access
  static Future<void> loadEpisodeBySequence(int season, int episode, int sequence) async {
    full = await _databaseService.getEpisodePhrases(season, episode);
    index = sequence; // Sequence IS the index!
  }
}
