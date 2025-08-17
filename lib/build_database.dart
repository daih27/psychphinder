#!/usr/bin/env dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:csv/csv.dart';
import 'package:diacritic/diacritic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'database/shared.dart';
part 'build_database.g.dart';

@DriftDatabase(tables: [Quotes, Episodes, References])
class BuildDatabase extends _$BuildDatabase {
  BuildDatabase(String path) : super(NativeDatabase(File(path)));

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
          await customStatement('''
        CREATE VIRTUAL TABLE references_fts USING fts5(
          name, reference,
          content='quote_references',
          content_rowid='id'
        )
      ''');
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  String _preprocessText(String text) {
    String processed = removeDiacritics(text).toLowerCase();
    processed = _replaceContractions(processed);
    processed = _replaceNumbersWithWords(processed);
    processed = processed.replaceAll("&", "and");
    processed = processed.replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ');
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    return processed;
  }

  String _replaceContractions(String input) {
    input = input.replaceAll('\'s', ' is');
    input = input.replaceAll('\'m', ' am');
    input = input.replaceAll('\'re', ' are');
    input = input.replaceAll('\'ll', ' will');
    input = input.replaceAll('n\'t', ' not');
    input = input.replaceAll('\'d', ' would');
    input = input.replaceAll('\'ve', ' have');
    return input;
  }

  String _replaceNumbersWithWords(String input) {
    RegExp regExp = RegExp(r'\d+');
    Iterable<Match> matches = regExp.allMatches(input);
    for (Match match in matches) {
      input = input.replaceAll(match.group(0)!,
          NumberToWordsEnglish.convert(int.parse(match.group(0)!)));
      input = "$input ${match.group(0)!}";
    }
    return input;
  }

  Future<void> populateFromCSVFiles() async {
    await transaction(() async {
      await _populateQuotes();
      await _populateEpisodes();
      await _populateReferences();
      await _createIndexes();
      await _rebuildFts();
    });
  }

  Future<void> _populateQuotes() async {
    final rawData = await File('assets/data.csv').readAsString();
    List<List<dynamic>> listData = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\r\n', shouldParseNumbers: true)
        .convert(rawData);

    Map<String, List<Map<String, dynamic>>> episodeGroups = {};

    for (var row in listData) {
      int season = row[1];
      int episode = row[2];
      String name = row[3].toString();

      if (season == 0) {
        season = 999;
        if (name.contains("Psych: The Movie")) {
          episode = 1;
        } else if (name.contains("Psych 2: Lassie Come Home")) {
          episode = 2;
        } else if (name.contains("Psych 3: This Is Gus")) {
          episode = 3;
        }
      }

      final key = '$season-$episode';

      episodeGroups[key] ??= [];
      episodeGroups[key]!.add({
        'id': row[0],
        'season': season,
        'episode': episode,
        'name': name,
        'time': row[4].toString(),
        'line': row[5].toString(),
        'reference': row[6].toString(),
      });
    }

    for (var episodeGroup in episodeGroups.values) {
      episodeGroup.sort((a, b) {
        return _parseTime(a['time']).compareTo(_parseTime(b['time']));
      });

      for (int i = 0; i < episodeGroup.length; i++) {
        final row = episodeGroup[i];
        final line = row['line'];
        final searchableText = _preprocessText(line);

        String? reference = row['reference'].toString();
        if (reference == '' || reference == 's') {
          reference = null;
        }

        await into(quotes).insert(QuotesCompanion.insert(
          id: Value(row['id']),
          season: row['season'],
          episode: row['episode'],
          sequenceInEpisode: i,
          time: row['time'],
          line: line,
          reference: Value.absentIfNull(reference),
          searchableText: searchableText,
        ));
      }
    }
  }

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 3) {
        return int.parse(parts[0]) * 3600 +
            int.parse(parts[1]) * 60 +
            int.parse(parts[2]);
      }
    } catch (e) {
      return 99999;
    }
    return 0;
  }

  Future<void> _populateEpisodes() async {
    final rawData = await File('assets/episodes.csv').readAsString();
    List<List<dynamic>> listData = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\n', shouldParseNumbers: false)
        .convert(rawData);

    for (var row in listData) {
      int seasonNum;
      int episodeNum;

      if (row[0].toString() == "All") {
        seasonNum = -1;
      } else if (row[0].toString() == "Movies") {
        seasonNum = 999;
      } else {
        seasonNum = int.parse(row[0].toString());
      }

      if (row[1].toString() == "All") {
        episodeNum = -1;
      } else {
        episodeNum = int.parse(row[1].toString());
      }

      await into(episodes).insert(
          EpisodesCompanion.insert(
            season: seasonNum,
            episode: episodeNum,
            name: row[2].toString(),
          ),
          mode: InsertMode.insertOrReplace);
    }
  }

  Future<void> _populateReferences() async {
    final rawData = await File('assets/references.csv').readAsString();
    List<List<dynamic>> listData = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\r', shouldParseNumbers: true)
        .convert(rawData);

    for (var row in listData) {
      String phraseIdsStr = row[5].toString();
      List<String> phraseIds =
          phraseIdsStr.split(',').map((e) => e.trim()).toList();

      for (String phraseIdStr in phraseIds) {
        if (phraseIdStr.isNotEmpty && phraseIdStr != '') {
          int phraseId = int.tryParse(phraseIdStr) ?? 0;
          if (phraseId > 0) {
            await into(references).insert(ReferencesCompanion.insert(
              season: row[0],
              episode: row[1],
              name: row[2].toString(),
              reference: row[3].toString(),
              referenceId: row[4].toString(),
              phraseId: phraseId,
              link: row[6].toString(),
            ));
          }
        }
      }
    }
  }

  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_quotes_season_episode ON quotes (season, episode)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_quotes_id ON quotes (id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_quotes_episode_sequence ON quotes (season, episode, sequence_in_episode)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_references_phrase_id ON quote_references (phrase_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_references_reference_id ON quote_references (reference_id)');
  }

  Future<void> _rebuildFts() async {
    await customStatement(
        'INSERT INTO quotes_fts(quotes_fts) VALUES(\'rebuild\')');
    await customStatement(
        'INSERT INTO references_fts(references_fts) VALUES(\'rebuild\')');
  }
}

Future<void> main() async {
  const outputPath = 'assets/psychphinder.db';

  final dbFile = File(outputPath);
  if (await dbFile.exists()) {
    await dbFile.delete();
  }
  final db = BuildDatabase(outputPath);
  try {
    await db.populateFromCSVFiles();
  } finally {
    await db.close();
  }
}
