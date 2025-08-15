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
  ValueNotifier<String> selectedSeason = ValueNotifier<String>('All');
  ValueNotifier<String> selectedEpisode = ValueNotifier<String>('All');
  final TextEditingController textEditingController = TextEditingController();
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

      List<String> episodeList = ['All'];
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
        final String referenceName = data['referenceName'];
        final String line = data['line'];
        final Phrase phrase = data['phrase'];

        Widget randomReference = Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  referenceName,
                  style: const TextStyle(
                    fontFamily: 'PsychFont',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  phrase.season == 999
                      ? phrase.name
                      : "Season ${phrase.season}, Episode ${phrase.episode}",
                  style: const TextStyle(
                    fontFamily: 'PsychFont',
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer),
                  onPressed: () {
                    context.go(
                      '/s${phrase.season}/e${phrase.episode}/p${phrase.sequenceInEpisode}',
                    );
                  },
                  child: Text(line, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        phrase.time[0] == '0'
                            ? phrase.time.substring(2)
                            : phrase.time,
                        style: const TextStyle(
                          fontFamily: 'PsychFont',
                        ),
                      ),
                    ),
                    const Expanded(
                        flex: 2, child: Center(child: Text("Random quote"))),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh_rounded)),
                    ),
                  ],
                ),
              ],
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
        'referenceName': randomQuote.name,
        'line': randomQuote.line,
        'phrase': randomQuote,
        'referenceId': randomQuote.reference ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  Widget didYouKnow() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Did you know?",
              style: TextStyle(
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DYK.didYouKnowOptions[randomIndexDYK],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 8),
            const Text(
              "Welcome to psychphinder!",
              style: TextStyle(
                fontFamily: "PsychFont",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            showUpdate ? const Spacer() : const SizedBox(),
            showUpdate ? showUpdateWidget() : const SizedBox(),
            const Spacer(),
            didYouKnow(),
            const Spacer(),
            randomReference(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  ExpansionTile searchOptions(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    return ExpansionTile(
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Search options"),
      ),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const Text("Season"),
                    ValueListenableBuilder<String>(
                      valueListenable: selectedSeason,
                      builder: (context, value, _) {
                        return DropdownButtonFormField(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 30,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Colors.green,
                          decoration: InputDecoration(
                            fillColor: Colors.green,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                          ),
                          value: value,
                          items: seasons.map((season) {
                            return DropdownMenuItem<String>(
                              value: season,
                              child: Text(season,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (season) {
                            setState(() {
                              selectedSeason.value = season!;
                              selectedEpisode.value = "All";
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    selectedSeason.value == "Movies"
                        ? const Text("Movie")
                        : const Text("Episode"),
                    ValueListenableBuilder<String>(
                      valueListenable: selectedEpisode,
                      builder: (context, value, _) {
                        final selectedSeasonValue = selectedSeason.value;
                        final episodes = episodesMap[selectedSeasonValue];
                        return DropdownButtonFormField(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 30,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Colors.green,
                          isExpanded: true,
                          decoration: InputDecoration(
                            fillColor: Colors.green,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                          ),
                          value: value,
                          items: episodes!.map((episode) {
                            return DropdownMenuItem<String>(
                              value: episode,
                              child: Text(episode,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (episode) {
                            setState(() {
                              selectedEpisode.value = episode!;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding searchBar(List<dynamic> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
      child: TextField(
        controller: textEditingController,
        style: const TextStyle(color: Colors.white),
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
            season: selectedSeason.value == "All" ? null : selectedSeason.value,
            episode:
                selectedEpisode.value == "All" ? null : selectedEpisode.value,
          );
          setState(() {
            isLoading = false;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          fillColor: Colors.green,
          filled: true,
          labelText: 'Search',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              input = textEditingController.text;
              setState(() {
                isLoading = true;
                isSearching = true;
              });
              var databaseService =
                  Provider.of<DatabaseService>(context, listen: false);
              searched = await databaseService.searchQuotes(
                textEditingController.text,
                season:
                    selectedSeason.value == "All" ? null : selectedSeason.value,
                episode: selectedEpisode.value == "All"
                    ? null
                    : selectedEpisode.value,
              );
              setState(() {
                isLoading = false;
              });
            },
          ),
          suffixIconColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.white),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
      ),
    );
  }
}
