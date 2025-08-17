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
import 'package:psychphinder/utils/responsive.dart';

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
                                  ? phrase.time[0] == '0'
                                      ? phrase.time.substring(2)
                                      : phrase.time
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

        final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
        final isTablet = ResponsiveUtils.isTablet(context);

        return Scaffold(
          body: !isSearching
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
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
              : isLargeScreen
                  ? Row(
                      children: [
                        Container(
                          width: isTablet ? 280 : 320,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              right: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildCompactSearchBar(),
                              _buildCompactFilters(seasons, episodesMap),
                            ],
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : searched.isNotEmpty
                                  ? ItemList(lines: searched, input: input)
                                  : const Center(
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
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveUtils.getHorizontalPadding(context)),
                          child: _buildHeroSearchBarWithFilters(
                              seasons, episodesMap),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : searched.isNotEmpty
                                  ? ItemList(lines: searched, input: input)
                                  : const Center(
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
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            if (showUpdate) ...[
              SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
              showUpdateWidget(),
            ],
            SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
            if (isLargeScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: didYouKnow()),
                  SizedBox(
                      width: ResponsiveUtils.getHorizontalPadding(context)),
                  Expanded(child: randomReference()),
                ],
              )
            else
              Column(
                children: [
                  didYouKnow(),
                  SizedBox(
                      height: ResponsiveUtils.getVerticalPadding(context) * 2),
                  randomReference(),
                ],
              ),
            SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: padding.horizontal * 0.5,
        vertical: ResponsiveUtils.getVerticalPadding(context),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "🍍 Find your favorite Psych quotes",
              style: TextStyle(
                fontFamily: "PsychFont",
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 32 : 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
          Text(
            "Search through thousands of quotes from 8 seasons and 3 movies",
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
          FutureBuilder<Map<String, dynamic>>(
            future: _loadSeasonEpisodeData(_databaseService),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHeroSearchBar();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _buildHeroSearchBar();
              }
              final data = snapshot.data!;
              final List<String> seasons = data['seasons'];
              final Map<String, List<String>> episodesMap = data['episodesMap'];
              return _buildHeroSearchBarWithFilters(seasons, episodesMap);
            },
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildHeroSearchBar() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.isDesktop(context) ? 600 : double.infinity,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              ResponsiveUtils.isDesktop(context) ? 28 : 24),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: textEditingController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
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
            hintText: 'Search for "pineapple", "psychic", or any quote...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
            ),
            prefixIcon: Container(
              margin:
                  EdgeInsets.all(ResponsiveUtils.isDesktop(context) ? 12 : 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveUtils.getIconSize(context) + 4,
              ),
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
                    margin: EdgeInsets.all(
                        ResponsiveUtils.isDesktop(context) ? 8 : 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.isDesktop(context) ? 16 : 12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: ResponsiveUtils.getIconSize(context),
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
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 28 : 24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 28 : 24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 28 : 24),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context) + 8,
              vertical: ResponsiveUtils.getVerticalPadding(context) + 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSearchBarWithFilters(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 700 : double.infinity,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: textEditingController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
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
                hintText: 'Search for "pineapple", "psychic", or any quote...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.all(isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: ResponsiveUtils.getIconSize(context) + 4,
                  ),
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
                        margin: EdgeInsets.all(isDesktop ? 8 : 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(isDesktop ? 16 : 12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: ResponsiveUtils.getIconSize(context),
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
                              season: selectedSeason == "All"
                                  ? null
                                  : selectedSeason,
                              episode: selectedEpisode == "All"
                                  ? null
                                  : selectedEpisode,
                            );
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context) + 8,
                  vertical: ResponsiveUtils.getVerticalPadding(context) + 8,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 1.5),
          _buildHeroFilters(seasons, episodesMap),
        ],
      ),
    );
  }

  Widget _buildHeroFilters(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        controller: expansionController,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: ResponsiveUtils.getVerticalPadding(context) * 0.8,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          ResponsiveUtils.getHorizontalPadding(context),
          0,
          ResponsiveUtils.getHorizontalPadding(context),
          ResponsiveUtils.getVerticalPadding(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Search filters",
              style: TextStyle(
                fontSize: ResponsiveUtils.getSmallFontSize(context) + 2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selectedSeason != 'All' || selectedEpisode != 'All')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSmallFontSize(context) - 1,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        children: [
          StatefulBuilder(
            builder: (context, setFilterState) {
              return Column(
                children: [
                  if (isLargeScreen)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildFilterDropdown(
                              "Season", selectedSeason, ['All', ...seasons],
                              (value) {
                            setFilterState(() {
                              selectedSeason = value!;
                              selectedEpisode = "All";
                            });
                            setState(() {});
                          }),
                        ),
                        SizedBox(
                            width:
                                ResponsiveUtils.getHorizontalPadding(context)),
                        Expanded(
                          flex: 2,
                          child: _buildFilterDropdown(
                              selectedSeason == "Movies" ? "Movie" : "Episode",
                              selectedEpisode,
                              _buildEpisodeItems(selectedSeason, episodesMap)
                                  .map((item) => item.value!)
                                  .toList(), (value) {
                            setFilterState(() {
                              selectedEpisode = value!;
                            });
                            setState(() {});
                          }),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildFilterDropdown(
                            "Season", selectedSeason, ['All', ...seasons],
                            (value) {
                          setFilterState(() {
                            selectedSeason = value!;
                            selectedEpisode = "All";
                          });
                          setState(() {});
                        }),
                        SizedBox(
                            height:
                                ResponsiveUtils.getVerticalPadding(context)),
                        _buildFilterDropdown(
                            selectedSeason == "Movies" ? "Movie" : "Episode",
                            selectedEpisode,
                            _buildEpisodeItems(selectedSeason, episodesMap)
                                .map((item) => item.value!)
                                .toList(), (value) {
                          setFilterState(() {
                            selectedEpisode = value!;
                          });
                          setState(() {});
                        }),
                      ],
                    ),
                  if (selectedSeason != 'All' || selectedEpisode != 'All') ...[
                    SizedBox(
                        height: ResponsiveUtils.getVerticalPadding(context)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setFilterState(() {
                            selectedSeason = 'All';
                            selectedEpisode = 'All';
                          });
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          'Clear filters',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getSmallFontSize(context),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            fontWeight: FontWeight.w500,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      "suck it",
      "c'mon son",
      "pluto",
      "company car",
      "boneless",
      "this is my partner"
    ];

    return Column(
      children: [
        Text(
          "💡 Try searching for:",
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context) + 1,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
        Wrap(
          spacing: ResponsiveUtils.getHorizontalPadding(context) * 0.5,
          runSpacing: ResponsiveUtils.getVerticalPadding(context) * 0.5,
          children: suggestions
              .map((suggestion) => _buildSuggestionChip(suggestion))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        textEditingController.text = text;
        setState(() {
          input = text;
          isLoading = true;
          isSearching = true;
        });
        Provider.of<DatabaseService>(context, listen: false)
            .searchQuotes(
          text,
          season: selectedSeason == "All" ? null : selectedSeason,
          episode: selectedEpisode == "All" ? null : selectedEpisode,
        )
            .then((results) {
          setState(() {
            searched = results;
            isLoading = false;
          });
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: ResponsiveUtils.getVerticalPadding(context) * 0.5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
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

  Widget _buildCompactSearchBar() {
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

  Widget _buildCompactFilters(
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
              return Column(
                children: [
                  _buildFilterDropdown(
                      "Season", selectedSeason, ['All', ...seasons], (value) {
                    setDropdownState(() {
                      selectedSeason = value!;
                      selectedEpisode = "All";
                    });
                    setState(() {});
                  }),
                  const SizedBox(height: 16),
                  _buildFilterDropdown(
                      selectedSeason == "Movies" ? "Movie" : "Episode",
                      selectedEpisode,
                      _buildEpisodeItems(selectedSeason, episodesMap)
                          .map((item) => item.value!)
                          .toList(), (value) {
                    setDropdownState(() {
                      selectedEpisode = value!;
                    });
                    setState(() {});
                  }),
                  if (selectedSeason != 'All' || selectedEpisode != 'All') ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setDropdownState(() {
                            selectedSeason = 'All';
                            selectedEpisode = 'All';
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        label: const Text('Clear filters',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
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
