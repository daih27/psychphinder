import 'package:drift/drift.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/classes/reference_class.dart';

@DataClassName('QuoteData')
class Quotes extends Table {
  IntColumn get id => integer()();
  IntColumn get season => integer()();
  IntColumn get episode => integer()();
  IntColumn get sequenceInEpisode => integer().named('sequence_in_episode')();
  TextColumn get time => text()();
  TextColumn get line => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get searchableText => text().named('searchable_text')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EpisodeData')
class Episodes extends Table {
  IntColumn get season => integer()();
  IntColumn get episode => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {season, episode};
}

@DataClassName('ReferenceData')
class References extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get season => integer()();
  IntColumn get episode => integer()();
  TextColumn get name => text()();
  TextColumn get reference => text()();
  TextColumn get referenceId => text().named('reference_id')();
  IntColumn get phraseId => integer().named('phrase_id')();
  TextColumn get link => text()();

  @override
  String get tableName => 'quote_references';
}


abstract class DatabaseInterface {
  Future<List<Phrase>> searchQuotes(String query,
      {String? season, String? episode});
  Future<List<int>> getAllSeasons();
  Future<List<Map<String, dynamic>>> getEpisodesForSeason(int season);
  Future<List<Reference>> getAllReferences();
  Future<void> close();
}
