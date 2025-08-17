import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_md/flutter_md.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'global/did_you_know.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;
  List searched = <Phrase>[];
  Map map = {};
  bool isLoading = false;
  bool isSearching = false;
  bool showUpdate = false;
  String input = "";
  late int randomIndex;
  late int randomIndexDYK;
  Random rng = Random();
  String selectedSeason = 'All';
  String selectedEpisode = 'All';
  final TextEditingController textEditingController = TextEditingController();
  final ExpansibleController expansionController = ExpansibleController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    randomIndex = rng.nextInt(2606);
    randomIndexDYK = rng.nextInt(DYK.didYouKnowOptions.length);
    checkUpdate();
  }

  Future<Map<String, dynamic>> _loadSeasonEpisodeData(
      DatabaseService databaseService) async {
    final seasonNums = await databaseService.getSeasons();
    List<String> seasons = [];
    Map<String, List<String>> episodesMap = {};

    for (var seasonNum in seasonNums) {
      String seasonStr = seasonNum == 999 ? 'Movies' : seasonNum.toString();
      if (!seasons.contains(seasonStr)) {
        seasons.add(seasonStr);
      }

      final episodes = await databaseService.getEpisodesForSeason(seasonNum);

      List<String> episodeList = [];
      for (var episode in episodes) {
        episodeList.add("${episode['episode']} - ${episode['name']}");
      }

      episodesMap[seasonStr] = episodeList;
    }

    seasons.sort((a, b) {
      if (a == 'Movies') return 1;
      if (b == 'Movies') return -1;
      return int.parse(a).compareTo(int.parse(b));
    });

    return {
      'seasons': seasons,
      'episodesMap': episodesMap,
    };
  }

  Widget randomReference() {
    return FutureBuilder(
      future: _getRandomReference(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final data = snapshot.data as Map<String, dynamic>;
        final String line = data['line'];
        final Phrase phrase = data['phrase'];

        Widget randomReference = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 8,
            shadowColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.format_quote_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Random Reference",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            Text(
                              phrase.season == 999
                                  ? phrase.time[0] == '0' ? phrase.time.substring(2) : phrase.time
                                  : "S${phrase.season}E${phrase.episode} • ${phrase.time[0] == '0' ? phrase.time.substring(2) : phrase.time}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    phrase.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PsychFont',
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.go(
                          '/s${phrase.season}/e${phrase.episode}/p${phrase.sequenceInEpisode}',
                        );
                      },
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return randomReference;
      },
    );
  }

  Future<Map<String, dynamic>?> _getRandomReference() async {
    try {
      final quotesWithReferences =
          await _databaseService.getRandomQuotesWithReferences(limit: 100);
      if (quotesWithReferences.isEmpty) return null;

      final randomQuote =
          quotesWithReferences[Random().nextInt(quotesWithReferences.length)];

      return {
        'referenceName': randomQuote.reference ?? 'Unknown Reference',
        'line': randomQuote.line,
        'phrase': randomQuote,
        'referenceId': randomQuote.reference ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  Widget didYouKnow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shadowColor:
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Did you know?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PsychFont',
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DYK.didYouKnowOptions[randomIndexDYK],
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildEpisodeItems(
      String season, Map<String, List<String>> episodesMap) {
    final episodeList = episodesMap[season] ?? [];
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: 'All',
        child: Text(
          'All',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    ];

    for (final episode in episodeList) {
      items.add(DropdownMenuItem<String>(
        value: episode,
        child: Text(
          episode,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ));
    }

    return items;
  }

  Future<void> checkUpdate() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    if (pref.getInt("latestAppVersion") == null) {
      pref.setInt("latestAppVersion", 16);
    }
    int latestAppVersion = pref.getInt("latestAppVersion") ?? buildNumber;
    if (buildNumber > latestAppVersion) {
      setState(() {
        showUpdate = true;
      });
    }
  }

  Widget showUpdateWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "psychphinder just got updated!",
              style: TextStyle(
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  showUpdate = false;
                });
                whatsNewDialog(context);
              },
              child: Text(
                "See what's new",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'PsychFont',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> whatsNewDialog(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    String dialogContent = await rootBundle.loadString('assets/CHANGELOG.md');
    pref.setInt("latestAppVersion", buildNumber);
    if (!context.mounted) return;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('What\'s new?'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Center(
              child: SingleChildScrollView(
                child: MarkdownTheme(
                  data: MarkdownThemeData(
                    textStyle: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                    h1Style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    h2Style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    quoteStyle: TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    onLinkTap: (url, title) {
                      launchUrl(Uri.parse(title));
                    },
                    spanFilter: (span) =>
                        !span.style.contains(MD$Style.spoiler),
                  ),
                  child: MarkdownWidget(
                    markdown: Markdown.fromString(dialogContent),
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSeasonEpisodeData(databaseService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final data = snapshot.data!;
        final List<String> seasons = data['seasons'];
        final Map<String, List<String>> episodesMap = data['episodesMap'];

        return Scaffold(
          body: !isSearching
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          searchBar([]),
                          searchOptions(seasons, episodesMap),
                          isLoading
                              ? const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : searched.isNotEmpty
                                  ? Expanded(
                                      child: ItemList(
                                          lines: searched, input: input))
                                  : isSearching
                                      ? const Expanded(
                                          child: Center(
                                            child: Text(
                                              "No results found.",
                                              style: TextStyle(
                                                fontFamily: "PsychFont",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : welcomeWidgets(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    searchBar([]),
                    searchOptions(seasons, episodesMap),
                    isLoading
                        ? const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : searched.isNotEmpty
                            ? Expanded(
                                child: ItemList(lines: searched, input: input))
                            : const Expanded(
                                child: Center(
                                  child: Text(
                                    "No results found.",
                                    style: TextStyle(
                                      fontFamily: "PsychFont",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                  ],
                ),
        );
      },
    );
  }

  Expanded welcomeWidgets() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 4,
                shadowColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome to psychphinder!",
                        style: TextStyle(
                          fontFamily: "PsychFont",
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Search through thousands of quotes from the TV show Psych",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showUpdate) ...[
              const SizedBox(height: 8),
              showUpdateWidget(),
            ],
            const SizedBox(height: 16),
            didYouKnow(),
            const SizedBox(height: 16),
            randomReference(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget searchOptions(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        controller: expansionController,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Search filters",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        children: [
          StatefulBuilder(
            builder: (context, setDropdownState) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Season",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            value: selectedSeason,
                            items: ['All', ...seasons].map((season) {
                              return DropdownMenuItem<String>(
                                value: season,
                                child: Text(
                                  season,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (season) {
                              if (season != null) {
                                setDropdownState(() {
                                  selectedSeason = season;
                                  selectedEpisode = "All";
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedSeason == "Movies" ? "Movie" : "Episode",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            value: selectedEpisode,
                            items:
                                _buildEpisodeItems(selectedSeason, episodesMap),
                            onChanged: (episode) {
                              if (episode != null) {
                                setDropdownState(() {
                                  selectedEpisode = episode;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget searchBar(List<dynamic> data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 7),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: textEditingController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          onSubmitted: (text) async {
            input = text;
            setState(() {
              isLoading = true;
              isSearching = true;
            });
            var databaseService =
                Provider.of<DatabaseService>(context, listen: false);
            searched = await databaseService.searchQuotes(
              text,
              season: selectedSeason == "All" ? null : selectedSeason,
              episode: selectedEpisode == "All" ? null : selectedEpisode,
            );
            setState(() {
              isLoading = false;
            });
          },
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintText: 'Search for quotes...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            suffixIcon: textEditingController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      textEditingController.clear();
                      setState(() {
                        searched.clear();
                        isSearching = false;
                        input = "";
                      });
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        input = textEditingController.text;
                        setState(() {
                          isLoading = true;
                          isSearching = true;
                        });
                        var databaseService = Provider.of<DatabaseService>(
                            context,
                            listen: false);
                        searched = await databaseService.searchQuotes(
                          textEditingController.text,
                          season:
                              selectedSeason == "All" ? null : selectedSeason,
                          episode:
                              selectedEpisode == "All" ? null : selectedEpisode,
                        );
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
