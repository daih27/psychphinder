import 'package:drift/drift.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'shared.dart';
import 'connection/connection.dart' as connections;
part 'drift_database.g.dart';

@DriftDatabase(tables: [Quotes, Episodes, References])
class PsychDatabase extends _$PsychDatabase implements DatabaseInterface {
  PsychDatabase() : super(connections.connect());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await customStatement('''
        CREATE VIRTUAL TABLE quotes_fts USING fts5(
          searchable_text,
          content='quotes',
          content_rowid='id'
        )
      ''');
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS quotes_fts USING fts5(
              searchable_text,
              content='quotes',
              content_rowid='id'
            )
          ''');
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
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

  @override
  Future<List<Phrase>> searchQuotes(String query,
      {String? season, String? episode}) async {
    if (query.trim().isEmpty) return [];

    final searchQuery = query.toLowerCase().trim();

    String whereClause = 'quotes_fts MATCH ?';
    List<Variable> variables = [Variable<String>(searchQuery)];

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

    final results = await customSelect(
      '''
      SELECT q.*, e.name as episode_name FROM quotes q
      JOIN episodes e ON q.season = e.season AND q.episode = e.episode
      JOIN quotes_fts ON q.id = quotes_fts.rowid
      WHERE $whereClause
      ORDER BY q.season, q.episode, q.sequence_in_episode
      LIMIT 1000
      ''',
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
}
