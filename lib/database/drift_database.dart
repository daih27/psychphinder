import 'package:drift/drift.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'shared.dart';
import 'connection/connection.dart' as connections;
import 'text_preprocessing.dart';
part 'drift_database.g.dart';

@DriftDatabase(tables: [Quotes, Episodes, References])
class PsychDatabase extends _$PsychDatabase implements DatabaseInterface {
  PsychDatabase() : super(connections.connect());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          try {
            await m.createAll();

            await customStatement('''
              CREATE VIRTUAL TABLE quotes_fts USING fts5(
                searchable_text,
                content='quotes',
                content_rowid='id'
              )
            ''');

            await customStatement('''
              CREATE VIRTUAL TABLE references_fts USING fts5(
                name, reference,
                content='quote_references',
                content_rowid='id'
              )
            ''');

            await customStatement('PRAGMA foreign_keys = ON');
          } catch (e) {
            rethrow;
          }
        },
        onUpgrade: (Migrator m, int from, int to) async {
          try {
            await customStatement('''
              CREATE VIRTUAL TABLE IF NOT EXISTS quotes_fts USING fts5(
                searchable_text,
                content='quotes',
                content_rowid='id'
              )
            ''');

            await customStatement('''
              CREATE VIRTUAL TABLE IF NOT EXISTS references_fts USING fts5(
                name, reference,
                content='quote_references',
                content_rowid='id'
              )
            ''');
          } catch (e) {
            //
          }
        },
        beforeOpen: (details) async {
          try {
            await customStatement('PRAGMA foreign_keys = ON');
          } catch (e) {
            //
          }
        },
      );

  Future<List<Phrase>> getAllQuotes() async {
    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      LIMIT 1000
      ''',
      readsFrom: {quotes, episodes},
    ).get();

    return results
        .map((row) => Phrase(
              id: row.read<int>('id'),
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              sequenceInEpisode: row.read<int>('sequence_in_episode'),
              name: row.read<String>('episode_name'),
              time: row.read<String>('time'),
              line: row.read<String>('line'),
              reference: row.read<String?>('reference'),
            ))
        .toList();
  }

  Future<Phrase?> getPhraseById(int id) async {
    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.id = ?
      ''',
      variables: [Variable.withInt(id)],
      readsFrom: {quotes, episodes},
    ).get();

    if (results.isEmpty) return null;

    final row = results.first;
    return Phrase(
      id: row.read<int>('id'),
      season: row.read<int>('season'),
      episode: row.read<int>('episode'),
      sequenceInEpisode: row.read<int>('sequence_in_episode'),
      name: row.read<String>('episode_name'),
      time: row.read<String>('time'),
      line: row.read<String>('line'),
      reference: row.read<String?>('reference'),
    );
  }

  Future<List<Phrase>> getRandomQuotesWithReferences({int limit = 50}) async {
    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.reference IS NOT NULL
      ORDER BY RANDOM() 
      LIMIT ?
      ''',
      variables: [Variable.withInt(limit)],
      readsFrom: {quotes, episodes},
    ).get();

    return results
        .map((row) => Phrase(
              id: row.read<int>('id'),
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              sequenceInEpisode: row.read<int>('sequence_in_episode'),
              name: row.read<String>('episode_name'),
              time: row.read<String>('time'),
              line: row.read<String>('line'),
              reference: row.read<String?>('reference'),
            ))
        .toList();
  }

  @override
  Future<List<Reference>> getAllReferences() async {
    final results = await select(references).get();
    return results
        .map((row) => Reference(
              season: row.season,
              episode: row.episode,
              name: row.name,
              reference: row.reference,
              id: row.referenceId,
              idLine: row.phraseId.toString(),
              link: row.link,
            ))
        .toList();
  }

  Future<List<Reference>> getReferencesForPhrase(int phraseId) async {
    final results = await (select(references)
          ..where((r) => r.phraseId.equals(phraseId)))
        .get();
    return results
        .map((row) => Reference(
              season: row.season,
              episode: row.episode,
              name: row.name,
              reference: row.reference,
              id: row.referenceId,
              idLine: row.phraseId.toString(),
              link: row.link,
            ))
        .toList();
  }

  Future<({Phrase phrase, List<Reference> references})?>
      getPhraseWithReferences(int phraseId) async {
    final phrase = await getPhraseById(phraseId);
    if (phrase == null) return null;

    final references = await getReferencesForPhrase(phraseId);
    return (phrase: phrase, references: references);
  }

  Future<List<Phrase>> getEpisodePhrases(int season, int episode) async {
    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.season = ? AND q.episode = ?
      ORDER BY q.sequence_in_episode
      ''',
      variables: [Variable.withInt(season), Variable.withInt(episode)],
      readsFrom: {quotes, episodes},
    ).get();

    return results
        .map((row) => Phrase(
              id: row.read<int>('id'),
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              sequenceInEpisode: row.read<int>('sequence_in_episode'),
              name: row.read<String>('episode_name'),
              time: row.read<String>('time'),
              line: row.read<String>('line'),
              reference: row.read<String?>('reference'),
            ))
        .toList();
  }

  Future<({Phrase? phrase, List<Phrase> episode, int index})>
      getPhraseWithEpisode(int phraseId) async {
    final phraseResults = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.id = ?
      ''',
      variables: [Variable.withInt(phraseId)],
      readsFrom: {quotes, episodes},
    ).get();

    if (phraseResults.isEmpty) {
      return (phrase: null, episode: <Phrase>[], index: 0);
    }

    final phraseRow = phraseResults.first;
    final phrase = Phrase(
      id: phraseRow.read<int>('id'),
      season: phraseRow.read<int>('season'),
      episode: phraseRow.read<int>('episode'),
      sequenceInEpisode: phraseRow.read<int>('sequence_in_episode'),
      name: phraseRow.read<String>('episode_name'),
      time: phraseRow.read<String>('time'),
      line: phraseRow.read<String>('line'),
      reference: phraseRow.read<String?>('reference'),
    );

    final episodeResults = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.season = ? AND q.episode = ?
      ORDER BY q.sequence_in_episode
      ''',
      variables: [
        Variable.withInt(phrase.season),
        Variable.withInt(phrase.episode)
      ],
      readsFrom: {quotes, episodes},
    ).get();

    final episodePhrases = episodeResults
        .map((row) => Phrase(
              id: row.read<int>('id'),
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              sequenceInEpisode: row.read<int>('sequence_in_episode'),
              name: row.read<String>('episode_name'),
              time: row.read<String>('time'),
              line: row.read<String>('line'),
              reference: row.read<String?>('reference'),
            ))
        .toList();

    return (
      phrase: phrase,
      episode: episodePhrases,
      index: phrase.sequenceInEpisode
    );
  }

  Future<Phrase?> getPhraseBySequence(
      int season, int episode, int sequence) async {
    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      WHERE q.season = ? AND q.episode = ? AND q.sequence_in_episode = ?
      ''',
      variables: [
        Variable.withInt(season),
        Variable.withInt(episode),
        Variable.withInt(sequence)
      ],
      readsFrom: {quotes, episodes},
    ).get();

    if (results.isEmpty) return null;

    final row = results.first;
    return Phrase(
      id: row.read<int>('id'),
      season: row.read<int>('season'),
      episode: row.read<int>('episode'),
      sequenceInEpisode: row.read<int>('sequence_in_episode'),
      name: row.read<String>('episode_name'),
      time: row.read<String>('time'),
      line: row.read<String>('line'),
      reference: row.read<String?>('reference'),
    );
  }

  String _processSearchQuery(String query) {
    return TextPreprocessing.preprocessForSearch(query);
  }

  @override
  Future<List<Phrase>> searchQuotes(String query,
      {String? season, String? episode}) async {
    if (query.trim().isEmpty) return [];

    final preprocessed = _processSearchQuery(query);
    final processedQuery = TextPreprocessing.escapeFts5Query(preprocessed);

    String whereClause = 'quotes_fts MATCH ?';
    List<Variable> variables = [Variable<String>(processedQuery)];

    if (season != null && season != "All") {
      if (season == "Movies") {
        whereClause += ' AND q.season = ?';
        variables.add(Variable<int>(999));
      } else {
        whereClause += ' AND q.season = ?';
        variables.add(Variable<int>(int.parse(season)));
      }
    }

    if (episode != null && episode != "All" && season != null) {
      if (season == "Movies") {
        final movieName =
            episode.contains(' - ') ? episode.split(' - ')[1] : episode;
        whereClause += ' AND e.name = ?';
        variables.add(Variable<String>(movieName));
      } else {
        final episodeNumber = episode.split(' - ')[0];
        whereClause += ' AND q.episode = ?';
        variables.add(Variable<int>(int.parse(episodeNumber)));
      }
    }

    final sqlQuery = '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      JOIN quotes_fts ON q.id = quotes_fts.rowid
      WHERE $whereClause
      ORDER BY q.season, q.episode, q.sequence_in_episode
      LIMIT 1000
      ''';

    final results = await customSelect(
      sqlQuery,
      variables: variables,
      readsFrom: {quotes, episodes},
    ).get();

    return results
        .map((row) => Phrase(
              id: row.read<int>('id'),
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              sequenceInEpisode: row.read<int>('sequence_in_episode'),
              name: row.read<String>('episode_name'),
              time: row.read<String>('time'),
              line: row.read<String>('line'),
              reference: row.read<String?>('reference'),
            ))
        .toList();
  }

  @override
  Future<List<int>> getAllSeasons() async {
    final result = await customSelect(
      'SELECT DISTINCT season FROM quotes ORDER BY season',
      readsFrom: {quotes},
    ).get();
    return result.map((row) => row.read<int>('season')).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getEpisodesForSeason(int season) async {
    final results = await (select(episodes)
          ..where((e) =>
              e.season.equals(season) & e.episode.isBiggerOrEqualValue(0))
          ..orderBy([(e) => OrderingTerm(expression: e.episode)]))
        .get();

    return results
        .map((ep) => {
              'season': ep.season,
              'episode': ep.episode,
              'name': ep.name,
            })
        .toList();
  }

  Future<List<Reference>> searchReferences(String query,
      {String? category, String? season, String? episode}) async {
    if (query.trim().isEmpty) return [];

    final processedQuery =
        TextPreprocessing.escapeFts5Query(_processSearchQuery(query));

    String whereClause = 'references_fts MATCH ?';
    List<Variable> variables = [Variable<String>(processedQuery)];

    // Add category filter if provided
    if (category != null && category != "All") {
      whereClause += ''' AND (
        CASE 
          WHEN LOWER(r.reference) LIKE '%movie%' OR LOWER(r.reference) LIKE '%film%' THEN 'Movies'
          WHEN LOWER(r.reference) LIKE '%actor%' OR LOWER(r.reference) LIKE '%actress%' THEN 'Actors'
          WHEN LOWER(r.reference) LIKE '%musician%' OR LOWER(r.reference) LIKE '%singer%' OR LOWER(r.reference) LIKE '%band%' THEN 'Music'
          WHEN LOWER(r.reference) LIKE '%tv show%' OR LOWER(r.reference) LIKE '%television%' THEN 'TV Shows'
          WHEN LOWER(r.reference) LIKE '%book%' OR LOWER(r.reference) LIKE '%novel%' OR LOWER(r.reference) LIKE '%writer%' OR LOWER(r.reference) LIKE '%author%' THEN 'Books'
          WHEN LOWER(r.reference) LIKE '%game%' OR LOWER(r.reference) LIKE '%sport%' THEN 'Games'
          WHEN LOWER(r.reference) LIKE '%company%' OR LOWER(r.reference) LIKE '%brand%' OR LOWER(r.reference) LIKE '%store%' THEN 'Brands'
          WHEN LOWER(r.reference) LIKE '%song%' OR LOWER(r.reference) LIKE '%album%' THEN 'Songs'
          WHEN LOWER(r.reference) LIKE '%character%' OR LOWER(r.reference) LIKE '%fictional%' THEN 'Characters'
          ELSE 'Other'
        END
      ) = ?''';
      variables.add(Variable<String>(category));
    }

    // Add season filter if provided
    if (season != null && season != "All") {
      if (season == "Movies") {
        whereClause += ' AND r.season = ?';
        variables.add(Variable<int>(999));
      } else {
        whereClause += ' AND r.season = ?';
        variables.add(Variable<int>(int.parse(season)));
      }
    }

    // Add episode filter if provided
    if (episode != null &&
        episode != "All" &&
        season != null &&
        season != "Movies") {
      final episodeNumber = episode.split(' - ')[0];
      whereClause += ' AND r.episode = ?';
      variables.add(Variable<int>(int.parse(episodeNumber)));
    }

    final results = await customSelect(
      '''
      SELECT DISTINCT r.reference_id, r.season, r.episode, r.name, r.reference, r.link, e.name as episode_name,
             (SELECT phrase_id FROM quote_references WHERE reference_id = r.reference_id AND season = r.season AND episode = r.episode LIMIT 1) as first_phrase_id
      FROM quote_references r
      JOIN episodes e ON r.season = e.season AND r.episode = e.episode
      JOIN references_fts ON r.id = references_fts.rowid
      WHERE $whereClause
      GROUP BY r.reference_id, r.season, r.episode
      ORDER BY r.season, r.episode, r.name
      LIMIT 500
      ''',
      variables: variables,
      readsFrom: {references, episodes},
    ).get();

    return results
        .map((row) => Reference(
              season: row.read<int>('season'),
              episode: row.read<int>('episode'),
              name: row.read<String>('episode_name'),
              reference: row.read<String>('reference'),
              id: row.read<String>('reference_id'),
              idLine: row.read<int?>('first_phrase_id')?.toString() ?? '0',
              link: row.read<String>('link'),
            ))
        .toList();
  }

  Future<List<String>> getReferenceSuggestions(String partial) async {
    if (partial.length < 2) return [];

    final results = await customSelect(
      '''
      SELECT DISTINCT name FROM quote_references
      WHERE LOWER(name) LIKE ?
      ORDER BY name
      LIMIT 10
      ''',
      variables: [Variable<String>('%${partial.toLowerCase()}%')],
      readsFrom: {references},
    ).get();

    return results.map((row) => row.read<String>('name')).toList();
  }

  Future<List<String>> getReferenceCategories() async {
    final results = await customSelect(
      '''
      SELECT DISTINCT 
        CASE 
          WHEN LOWER(reference) LIKE '%movie%' OR LOWER(reference) LIKE '%film%' THEN 'Movies'
          WHEN LOWER(reference) LIKE '%actor%' OR LOWER(reference) LIKE '%actress%' THEN 'Actors'
          WHEN LOWER(reference) LIKE '%musician%' OR LOWER(reference) LIKE '%singer%' OR LOWER(reference) LIKE '%band%' THEN 'Music'
          WHEN LOWER(reference) LIKE '%tv show%' OR LOWER(reference) LIKE '%television%' THEN 'TV Shows'
          WHEN LOWER(reference) LIKE '%book%' OR LOWER(reference) LIKE '%novel%' OR LOWER(reference) LIKE '%writer%' OR LOWER(reference) LIKE '%author%' THEN 'Books'
          WHEN LOWER(reference) LIKE '%game%' OR LOWER(reference) LIKE '%sport%' THEN 'Games'
          WHEN LOWER(reference) LIKE '%company%' OR LOWER(reference) LIKE '%brand%' OR LOWER(reference) LIKE '%store%' THEN 'Brands'
          WHEN LOWER(reference) LIKE '%song%' OR LOWER(reference) LIKE '%album%' THEN 'Songs'
          WHEN LOWER(reference) LIKE '%character%' OR LOWER(reference) LIKE '%fictional%' THEN 'Characters'
          ELSE 'Other'
        END as category
      FROM quote_references
      ORDER BY category
      ''',
      readsFrom: {references},
    ).get();

    return results.map((row) => row.read<String>('category')).toList();
  }
}
