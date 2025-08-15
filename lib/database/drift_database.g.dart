// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $QuotesTable extends Quotes with TableInfo<$QuotesTable, QuoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
      'season', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _episodeMeta =
      const VerificationMeta('episode');
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sequenceInEpisodeMeta =
      const VerificationMeta('sequenceInEpisode');
  @override
  late final GeneratedColumn<int> sequenceInEpisode = GeneratedColumn<int>(
      'sequence_in_episode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  @override
  late final GeneratedColumn<String> line = GeneratedColumn<String>(
      'line', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _searchableTextMeta =
      const VerificationMeta('searchableText');
  @override
  late final GeneratedColumn<String> searchableText = GeneratedColumn<String>(
      'searchable_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        season,
        episode,
        sequenceInEpisode,
        time,
        line,
        reference,
        searchableText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(Insertable<QuoteData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(_episodeMeta,
          episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta));
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('sequence_in_episode')) {
      context.handle(
          _sequenceInEpisodeMeta,
          sequenceInEpisode.isAcceptableOrUnknown(
              data['sequence_in_episode']!, _sequenceInEpisodeMeta));
    } else if (isInserting) {
      context.missing(_sequenceInEpisodeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('line')) {
      context.handle(
          _lineMeta, line.isAcceptableOrUnknown(data['line']!, _lineMeta));
    } else if (isInserting) {
      context.missing(_lineMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('searchable_text')) {
      context.handle(
          _searchableTextMeta,
          searchableText.isAcceptableOrUnknown(
              data['searchable_text']!, _searchableTextMeta));
    } else if (isInserting) {
      context.missing(_searchableTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season'])!,
      episode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode'])!,
      sequenceInEpisode: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}sequence_in_episode'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      line: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      searchableText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}searchable_text'])!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class QuoteData extends DataClass implements Insertable<QuoteData> {
  final int id;
  final int season;
  final int episode;
  final int sequenceInEpisode;
  final String time;
  final String line;
  final String? reference;
  final String searchableText;
  const QuoteData(
      {required this.id,
      required this.season,
      required this.episode,
      required this.sequenceInEpisode,
      required this.time,
      required this.line,
      this.reference,
      required this.searchableText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['season'] = Variable<int>(season);
    map['episode'] = Variable<int>(episode);
    map['sequence_in_episode'] = Variable<int>(sequenceInEpisode);
    map['time'] = Variable<String>(time);
    map['line'] = Variable<String>(line);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['searchable_text'] = Variable<String>(searchableText);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      season: Value(season),
      episode: Value(episode),
      sequenceInEpisode: Value(sequenceInEpisode),
      time: Value(time),
      line: Value(line),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      searchableText: Value(searchableText),
    );
  }

  factory QuoteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteData(
      id: serializer.fromJson<int>(json['id']),
      season: serializer.fromJson<int>(json['season']),
      episode: serializer.fromJson<int>(json['episode']),
      sequenceInEpisode: serializer.fromJson<int>(json['sequenceInEpisode']),
      time: serializer.fromJson<String>(json['time']),
      line: serializer.fromJson<String>(json['line']),
      reference: serializer.fromJson<String?>(json['reference']),
      searchableText: serializer.fromJson<String>(json['searchableText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'season': serializer.toJson<int>(season),
      'episode': serializer.toJson<int>(episode),
      'sequenceInEpisode': serializer.toJson<int>(sequenceInEpisode),
      'time': serializer.toJson<String>(time),
      'line': serializer.toJson<String>(line),
      'reference': serializer.toJson<String?>(reference),
      'searchableText': serializer.toJson<String>(searchableText),
    };
  }

  QuoteData copyWith(
          {int? id,
          int? season,
          int? episode,
          int? sequenceInEpisode,
          String? time,
          String? line,
          Value<String?> reference = const Value.absent(),
          String? searchableText}) =>
      QuoteData(
        id: id ?? this.id,
        season: season ?? this.season,
        episode: episode ?? this.episode,
        sequenceInEpisode: sequenceInEpisode ?? this.sequenceInEpisode,
        time: time ?? this.time,
        line: line ?? this.line,
        reference: reference.present ? reference.value : this.reference,
        searchableText: searchableText ?? this.searchableText,
      );
  QuoteData copyWithCompanion(QuotesCompanion data) {
    return QuoteData(
      id: data.id.present ? data.id.value : this.id,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      sequenceInEpisode: data.sequenceInEpisode.present
          ? data.sequenceInEpisode.value
          : this.sequenceInEpisode,
      time: data.time.present ? data.time.value : this.time,
      line: data.line.present ? data.line.value : this.line,
      reference: data.reference.present ? data.reference.value : this.reference,
      searchableText: data.searchableText.present
          ? data.searchableText.value
          : this.searchableText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteData(')
          ..write('id: $id, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('sequenceInEpisode: $sequenceInEpisode, ')
          ..write('time: $time, ')
          ..write('line: $line, ')
          ..write('reference: $reference, ')
          ..write('searchableText: $searchableText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, season, episode, sequenceInEpisode, time,
      line, reference, searchableText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteData &&
          other.id == this.id &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.sequenceInEpisode == this.sequenceInEpisode &&
          other.time == this.time &&
          other.line == this.line &&
          other.reference == this.reference &&
          other.searchableText == this.searchableText);
}

class QuotesCompanion extends UpdateCompanion<QuoteData> {
  final Value<int> id;
  final Value<int> season;
  final Value<int> episode;
  final Value<int> sequenceInEpisode;
  final Value<String> time;
  final Value<String> line;
  final Value<String?> reference;
  final Value<String> searchableText;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.sequenceInEpisode = const Value.absent(),
    this.time = const Value.absent(),
    this.line = const Value.absent(),
    this.reference = const Value.absent(),
    this.searchableText = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required int season,
    required int episode,
    required int sequenceInEpisode,
    required String time,
    required String line,
    this.reference = const Value.absent(),
    required String searchableText,
  })  : season = Value(season),
        episode = Value(episode),
        sequenceInEpisode = Value(sequenceInEpisode),
        time = Value(time),
        line = Value(line),
        searchableText = Value(searchableText);
  static Insertable<QuoteData> custom({
    Expression<int>? id,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<int>? sequenceInEpisode,
    Expression<String>? time,
    Expression<String>? line,
    Expression<String>? reference,
    Expression<String>? searchableText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (sequenceInEpisode != null) 'sequence_in_episode': sequenceInEpisode,
      if (time != null) 'time': time,
      if (line != null) 'line': line,
      if (reference != null) 'reference': reference,
      if (searchableText != null) 'searchable_text': searchableText,
    });
  }

  QuotesCompanion copyWith(
      {Value<int>? id,
      Value<int>? season,
      Value<int>? episode,
      Value<int>? sequenceInEpisode,
      Value<String>? time,
      Value<String>? line,
      Value<String?>? reference,
      Value<String>? searchableText}) {
    return QuotesCompanion(
      id: id ?? this.id,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      sequenceInEpisode: sequenceInEpisode ?? this.sequenceInEpisode,
      time: time ?? this.time,
      line: line ?? this.line,
      reference: reference ?? this.reference,
      searchableText: searchableText ?? this.searchableText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (sequenceInEpisode.present) {
      map['sequence_in_episode'] = Variable<int>(sequenceInEpisode.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (line.present) {
      map['line'] = Variable<String>(line.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (searchableText.present) {
      map['searchable_text'] = Variable<String>(searchableText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('sequenceInEpisode: $sequenceInEpisode, ')
          ..write('time: $time, ')
          ..write('line: $line, ')
          ..write('reference: $reference, ')
          ..write('searchableText: $searchableText')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes
    with TableInfo<$EpisodesTable, EpisodeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
      'season', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _episodeMeta =
      const VerificationMeta('episode');
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [season, episode, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(Insertable<EpisodeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(_episodeMeta,
          episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta));
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {season, episode};
  @override
  EpisodeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeData(
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season'])!,
      episode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class EpisodeData extends DataClass implements Insertable<EpisodeData> {
  final int season;
  final int episode;
  final String name;
  const EpisodeData(
      {required this.season, required this.episode, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['season'] = Variable<int>(season);
    map['episode'] = Variable<int>(episode);
    map['name'] = Variable<String>(name);
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      season: Value(season),
      episode: Value(episode),
      name: Value(name),
    );
  }

  factory EpisodeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeData(
      season: serializer.fromJson<int>(json['season']),
      episode: serializer.fromJson<int>(json['episode']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'season': serializer.toJson<int>(season),
      'episode': serializer.toJson<int>(episode),
      'name': serializer.toJson<String>(name),
    };
  }

  EpisodeData copyWith({int? season, int? episode, String? name}) =>
      EpisodeData(
        season: season ?? this.season,
        episode: episode ?? this.episode,
        name: name ?? this.name,
      );
  EpisodeData copyWithCompanion(EpisodesCompanion data) {
    return EpisodeData(
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeData(')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(season, episode, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeData &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.name == this.name);
}

class EpisodesCompanion extends UpdateCompanion<EpisodeData> {
  final Value<int> season;
  final Value<int> episode;
  final Value<String> name;
  final Value<int> rowid;
  const EpisodesCompanion({
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodesCompanion.insert({
    required int season,
    required int episode,
    required String name,
    this.rowid = const Value.absent(),
  })  : season = Value(season),
        episode = Value(episode),
        name = Value(name);
  static Insertable<EpisodeData> custom({
    Expression<int>? season,
    Expression<int>? episode,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodesCompanion copyWith(
      {Value<int>? season,
      Value<int>? episode,
      Value<String>? name,
      Value<int>? rowid}) {
    return EpisodesCompanion(
      season: season ?? this.season,
      episode: episode ?? this.episode,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferencesTable extends References
    with TableInfo<$ReferencesTable, ReferenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
      'season', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _episodeMeta =
      const VerificationMeta('episode');
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phraseIdMeta =
      const VerificationMeta('phraseId');
  @override
  late final GeneratedColumn<int> phraseId = GeneratedColumn<int>(
      'phrase_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, season, episode, name, reference, referenceId, phraseId, link];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quote_references';
  @override
  VerificationContext validateIntegrity(Insertable<ReferenceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(_episodeMeta,
          episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta));
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
    }
    if (data.containsKey('phrase_id')) {
      context.handle(_phraseIdMeta,
          phraseId.isAcceptableOrUnknown(data['phrase_id']!, _phraseIdMeta));
    } else if (isInserting) {
      context.missing(_phraseIdMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season'])!,
      episode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id'])!,
      phraseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phrase_id'])!,
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link'])!,
    );
  }

  @override
  $ReferencesTable createAlias(String alias) {
    return $ReferencesTable(attachedDatabase, alias);
  }
}

class ReferenceData extends DataClass implements Insertable<ReferenceData> {
  final int id;
  final int season;
  final int episode;
  final String name;
  final String reference;
  final String referenceId;
  final int phraseId;
  final String link;
  const ReferenceData(
      {required this.id,
      required this.season,
      required this.episode,
      required this.name,
      required this.reference,
      required this.referenceId,
      required this.phraseId,
      required this.link});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['season'] = Variable<int>(season);
    map['episode'] = Variable<int>(episode);
    map['name'] = Variable<String>(name);
    map['reference'] = Variable<String>(reference);
    map['reference_id'] = Variable<String>(referenceId);
    map['phrase_id'] = Variable<int>(phraseId);
    map['link'] = Variable<String>(link);
    return map;
  }

  ReferencesCompanion toCompanion(bool nullToAbsent) {
    return ReferencesCompanion(
      id: Value(id),
      season: Value(season),
      episode: Value(episode),
      name: Value(name),
      reference: Value(reference),
      referenceId: Value(referenceId),
      phraseId: Value(phraseId),
      link: Value(link),
    );
  }

  factory ReferenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceData(
      id: serializer.fromJson<int>(json['id']),
      season: serializer.fromJson<int>(json['season']),
      episode: serializer.fromJson<int>(json['episode']),
      name: serializer.fromJson<String>(json['name']),
      reference: serializer.fromJson<String>(json['reference']),
      referenceId: serializer.fromJson<String>(json['referenceId']),
      phraseId: serializer.fromJson<int>(json['phraseId']),
      link: serializer.fromJson<String>(json['link']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'season': serializer.toJson<int>(season),
      'episode': serializer.toJson<int>(episode),
      'name': serializer.toJson<String>(name),
      'reference': serializer.toJson<String>(reference),
      'referenceId': serializer.toJson<String>(referenceId),
      'phraseId': serializer.toJson<int>(phraseId),
      'link': serializer.toJson<String>(link),
    };
  }

  ReferenceData copyWith(
          {int? id,
          int? season,
          int? episode,
          String? name,
          String? reference,
          String? referenceId,
          int? phraseId,
          String? link}) =>
      ReferenceData(
        id: id ?? this.id,
        season: season ?? this.season,
        episode: episode ?? this.episode,
        name: name ?? this.name,
        reference: reference ?? this.reference,
        referenceId: referenceId ?? this.referenceId,
        phraseId: phraseId ?? this.phraseId,
        link: link ?? this.link,
      );
  ReferenceData copyWithCompanion(ReferencesCompanion data) {
    return ReferenceData(
      id: data.id.present ? data.id.value : this.id,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      name: data.name.present ? data.name.value : this.name,
      reference: data.reference.present ? data.reference.value : this.reference,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      phraseId: data.phraseId.present ? data.phraseId.value : this.phraseId,
      link: data.link.present ? data.link.value : this.link,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceData(')
          ..write('id: $id, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('referenceId: $referenceId, ')
          ..write('phraseId: $phraseId, ')
          ..write('link: $link')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, season, episode, name, reference, referenceId, phraseId, link);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceData &&
          other.id == this.id &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.name == this.name &&
          other.reference == this.reference &&
          other.referenceId == this.referenceId &&
          other.phraseId == this.phraseId &&
          other.link == this.link);
}

class ReferencesCompanion extends UpdateCompanion<ReferenceData> {
  final Value<int> id;
  final Value<int> season;
  final Value<int> episode;
  final Value<String> name;
  final Value<String> reference;
  final Value<String> referenceId;
  final Value<int> phraseId;
  final Value<String> link;
  const ReferencesCompanion({
    this.id = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.name = const Value.absent(),
    this.reference = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.phraseId = const Value.absent(),
    this.link = const Value.absent(),
  });
  ReferencesCompanion.insert({
    this.id = const Value.absent(),
    required int season,
    required int episode,
    required String name,
    required String reference,
    required String referenceId,
    required int phraseId,
    required String link,
  })  : season = Value(season),
        episode = Value(episode),
        name = Value(name),
        reference = Value(reference),
        referenceId = Value(referenceId),
        phraseId = Value(phraseId),
        link = Value(link);
  static Insertable<ReferenceData> custom({
    Expression<int>? id,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<String>? name,
    Expression<String>? reference,
    Expression<String>? referenceId,
    Expression<int>? phraseId,
    Expression<String>? link,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (name != null) 'name': name,
      if (reference != null) 'reference': reference,
      if (referenceId != null) 'reference_id': referenceId,
      if (phraseId != null) 'phrase_id': phraseId,
      if (link != null) 'link': link,
    });
  }

  ReferencesCompanion copyWith(
      {Value<int>? id,
      Value<int>? season,
      Value<int>? episode,
      Value<String>? name,
      Value<String>? reference,
      Value<String>? referenceId,
      Value<int>? phraseId,
      Value<String>? link}) {
    return ReferencesCompanion(
      id: id ?? this.id,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      referenceId: referenceId ?? this.referenceId,
      phraseId: phraseId ?? this.phraseId,
      link: link ?? this.link,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (phraseId.present) {
      map['phrase_id'] = Variable<int>(phraseId.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferencesCompanion(')
          ..write('id: $id, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('referenceId: $referenceId, ')
          ..write('phraseId: $phraseId, ')
          ..write('link: $link')
          ..write(')'))
        .toString();
  }
}

abstract class _$PsychDatabase extends GeneratedDatabase {
  _$PsychDatabase(QueryExecutor e) : super(e);
  $PsychDatabaseManager get managers => $PsychDatabaseManager(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $ReferencesTable references = $ReferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [quotes, episodes, references];
}

typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  required int season,
  required int episode,
  required int sequenceInEpisode,
  required String time,
  required String line,
  Value<String?> reference,
  required String searchableText,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  Value<int> season,
  Value<int> episode,
  Value<int> sequenceInEpisode,
  Value<String> time,
  Value<String> line,
  Value<String?> reference,
  Value<String> searchableText,
});

class $$QuotesTableFilterComposer
    extends Composer<_$PsychDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceInEpisode => $composableBuilder(
      column: $table.sequenceInEpisode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get line => $composableBuilder(
      column: $table.line, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchableText => $composableBuilder(
      column: $table.searchableText,
      builder: (column) => ColumnFilters(column));
}

class $$QuotesTableOrderingComposer
    extends Composer<_$PsychDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceInEpisode => $composableBuilder(
      column: $table.sequenceInEpisode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get line => $composableBuilder(
      column: $table.line, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchableText => $composableBuilder(
      column: $table.searchableText,
      builder: (column) => ColumnOrderings(column));
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$PsychDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<int> get sequenceInEpisode => $composableBuilder(
      column: $table.sequenceInEpisode, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get line =>
      $composableBuilder(column: $table.line, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get searchableText => $composableBuilder(
      column: $table.searchableText, builder: (column) => column);
}

class $$QuotesTableTableManager extends RootTableManager<
    _$PsychDatabase,
    $QuotesTable,
    QuoteData,
    $$QuotesTableFilterComposer,
    $$QuotesTableOrderingComposer,
    $$QuotesTableAnnotationComposer,
    $$QuotesTableCreateCompanionBuilder,
    $$QuotesTableUpdateCompanionBuilder,
    (QuoteData, BaseReferences<_$PsychDatabase, $QuotesTable, QuoteData>),
    QuoteData,
    PrefetchHooks Function()> {
  $$QuotesTableTableManager(_$PsychDatabase db, $QuotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> season = const Value.absent(),
            Value<int> episode = const Value.absent(),
            Value<int> sequenceInEpisode = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<String> line = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String> searchableText = const Value.absent(),
          }) =>
              QuotesCompanion(
            id: id,
            season: season,
            episode: episode,
            sequenceInEpisode: sequenceInEpisode,
            time: time,
            line: line,
            reference: reference,
            searchableText: searchableText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int season,
            required int episode,
            required int sequenceInEpisode,
            required String time,
            required String line,
            Value<String?> reference = const Value.absent(),
            required String searchableText,
          }) =>
              QuotesCompanion.insert(
            id: id,
            season: season,
            episode: episode,
            sequenceInEpisode: sequenceInEpisode,
            time: time,
            line: line,
            reference: reference,
            searchableText: searchableText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuotesTableProcessedTableManager = ProcessedTableManager<
    _$PsychDatabase,
    $QuotesTable,
    QuoteData,
    $$QuotesTableFilterComposer,
    $$QuotesTableOrderingComposer,
    $$QuotesTableAnnotationComposer,
    $$QuotesTableCreateCompanionBuilder,
    $$QuotesTableUpdateCompanionBuilder,
    (QuoteData, BaseReferences<_$PsychDatabase, $QuotesTable, QuoteData>),
    QuoteData,
    PrefetchHooks Function()>;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  required int season,
  required int episode,
  required String name,
  Value<int> rowid,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> season,
  Value<int> episode,
  Value<String> name,
  Value<int> rowid,
});

class $$EpisodesTableFilterComposer
    extends Composer<_$PsychDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$PsychDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$PsychDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$EpisodesTableTableManager extends RootTableManager<
    _$PsychDatabase,
    $EpisodesTable,
    EpisodeData,
    $$EpisodesTableFilterComposer,
    $$EpisodesTableOrderingComposer,
    $$EpisodesTableAnnotationComposer,
    $$EpisodesTableCreateCompanionBuilder,
    $$EpisodesTableUpdateCompanionBuilder,
    (EpisodeData, BaseReferences<_$PsychDatabase, $EpisodesTable, EpisodeData>),
    EpisodeData,
    PrefetchHooks Function()> {
  $$EpisodesTableTableManager(_$PsychDatabase db, $EpisodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> season = const Value.absent(),
            Value<int> episode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EpisodesCompanion(
            season: season,
            episode: episode,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int season,
            required int episode,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              EpisodesCompanion.insert(
            season: season,
            episode: episode,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EpisodesTableProcessedTableManager = ProcessedTableManager<
    _$PsychDatabase,
    $EpisodesTable,
    EpisodeData,
    $$EpisodesTableFilterComposer,
    $$EpisodesTableOrderingComposer,
    $$EpisodesTableAnnotationComposer,
    $$EpisodesTableCreateCompanionBuilder,
    $$EpisodesTableUpdateCompanionBuilder,
    (EpisodeData, BaseReferences<_$PsychDatabase, $EpisodesTable, EpisodeData>),
    EpisodeData,
    PrefetchHooks Function()>;
typedef $$ReferencesTableCreateCompanionBuilder = ReferencesCompanion Function({
  Value<int> id,
  required int season,
  required int episode,
  required String name,
  required String reference,
  required String referenceId,
  required int phraseId,
  required String link,
});
typedef $$ReferencesTableUpdateCompanionBuilder = ReferencesCompanion Function({
  Value<int> id,
  Value<int> season,
  Value<int> episode,
  Value<String> name,
  Value<String> reference,
  Value<String> referenceId,
  Value<int> phraseId,
  Value<String> link,
});

class $$ReferencesTableFilterComposer
    extends Composer<_$PsychDatabase, $ReferencesTable> {
  $$ReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get phraseId => $composableBuilder(
      column: $table.phraseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnFilters(column));
}

class $$ReferencesTableOrderingComposer
    extends Composer<_$PsychDatabase, $ReferencesTable> {
  $$ReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get phraseId => $composableBuilder(
      column: $table.phraseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnOrderings(column));
}

class $$ReferencesTableAnnotationComposer
    extends Composer<_$PsychDatabase, $ReferencesTable> {
  $$ReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<int> get phraseId =>
      $composableBuilder(column: $table.phraseId, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);
}

class $$ReferencesTableTableManager extends RootTableManager<
    _$PsychDatabase,
    $ReferencesTable,
    ReferenceData,
    $$ReferencesTableFilterComposer,
    $$ReferencesTableOrderingComposer,
    $$ReferencesTableAnnotationComposer,
    $$ReferencesTableCreateCompanionBuilder,
    $$ReferencesTableUpdateCompanionBuilder,
    (
      ReferenceData,
      BaseReferences<_$PsychDatabase, $ReferencesTable, ReferenceData>
    ),
    ReferenceData,
    PrefetchHooks Function()> {
  $$ReferencesTableTableManager(_$PsychDatabase db, $ReferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> season = const Value.absent(),
            Value<int> episode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> reference = const Value.absent(),
            Value<String> referenceId = const Value.absent(),
            Value<int> phraseId = const Value.absent(),
            Value<String> link = const Value.absent(),
          }) =>
              ReferencesCompanion(
            id: id,
            season: season,
            episode: episode,
            name: name,
            reference: reference,
            referenceId: referenceId,
            phraseId: phraseId,
            link: link,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int season,
            required int episode,
            required String name,
            required String reference,
            required String referenceId,
            required int phraseId,
            required String link,
          }) =>
              ReferencesCompanion.insert(
            id: id,
            season: season,
            episode: episode,
            name: name,
            reference: reference,
            referenceId: referenceId,
            phraseId: phraseId,
            link: link,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferencesTableProcessedTableManager = ProcessedTableManager<
    _$PsychDatabase,
    $ReferencesTable,
    ReferenceData,
    $$ReferencesTableFilterComposer,
    $$ReferencesTableOrderingComposer,
    $$ReferencesTableAnnotationComposer,
    $$ReferencesTableCreateCompanionBuilder,
    $$ReferencesTableUpdateCompanionBuilder,
    (
      ReferenceData,
      BaseReferences<_$PsychDatabase, $ReferencesTable, ReferenceData>
    ),
    ReferenceData,
    PrefetchHooks Function()>;

class $PsychDatabaseManager {
  final _$PsychDatabase _db;
  $PsychDatabaseManager(this._db);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$ReferencesTableTableManager get references =>
      $$ReferencesTableTableManager(_db, _db.references);
}
