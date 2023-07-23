import 'package:psychphinder/classes/phrase_class.dart';

class EpisodeUtil {
  static List<Phrase> full = <Phrase>[];
  static int index = 0;

  static void fullEpisode(List data, int episode, int season, String line) {
    full = <Phrase>[];
    
    for (var i = 0; i < data.length; i++) {
      if (data[i].episode == episode && data[i].season == season) {
        full.add(data[i]);
      }
    }
    for (var i = 0; i < full.length; i++) {
      if (full[i].line == line) {
        index = i;
      }
    }
  }
  
}
