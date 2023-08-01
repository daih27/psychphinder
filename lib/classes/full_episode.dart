import 'package:psychphinder/classes/phrase_class.dart';

class EpisodeUtil {
  static List<Phrase> full = <Phrase>[];
  static int index = 0;

  static void fullEpisode(List data, Phrase phrase) {
    full = <Phrase>[];

    for (var i = 0; i < data.length; i++) {
      if (data[i].episode == phrase.episode &&
          data[i].season == phrase.season) {
        full.add(data[i]);
      }
    }
    for (var i = 0; i < full.length; i++) {
      if (full[i].id == phrase.id) {
        index = i;
      }
    }
  }
}
