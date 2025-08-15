import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'drift_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late final PsychDatabase _db;

  factory DatabaseService() => _instance;

  DatabaseService._internal() {
    _db = PsychDatabase();
  }

  Future<List<Phrase>> searchQuotes(String query,
      {String? season, String? episode}) async {
    return await _db.searchQuotes(query, season: season, episode: episode);
  }

  Future<List<Phrase>> getAllQuotes() async {
    return await _db.getAllQuotes();
  }

  Future<Phrase?> getPhraseById(int id) async {
    return await _db.getPhraseById(id);
  }

  Future<List<Phrase>> getEpisodePhrases(int season, int episode) async {
    return await _db.getEpisodePhrases(season, episode);
  }

  Future<({Phrase? phrase, List<Phrase> episode, int index})>
      getPhraseWithEpisode(int phraseId) async {
    return await _db.getPhraseWithEpisode(phraseId);
  }

  Future<Phrase?> getPhraseBySequence(
      int season, int episode, int sequence) async {
    return await _db.getPhraseBySequence(season, episode, sequence);
  }

  Future<List<int>> getSeasons() async {
    return await _db.getAllSeasons();
  }

  Future<List<Map<String, dynamic>>> getEpisodesForSeason(int season) async {
    return await _db.getEpisodesForSeason(season);
  }

  Future<List<Phrase>> getRandomQuotesWithReferences({int limit = 50}) async {
    return await _db.getRandomQuotesWithReferences(limit: limit);
  }

  Future<List<Reference>> getReferences() async {
    return await _db.getAllReferences();
  }

  Future<List<Reference>> getReferencesForPhrase(int phraseId) async {
    return await _db.getReferencesForPhrase(phraseId);
  }

  Future<({Phrase phrase, List<Reference> references})?>
      getPhraseWithReferences(int phraseId) async {
    return await _db.getPhraseWithReferences(phraseId);
  }

  Future<void> close() async {
    await _db.close();
  }
}
