// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:psychphinder/main.dart';
import 'package:psychphinder/references.dart';
import 'package:psychphinder/settings.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';
import 'package:psychphinder/widgets/create_image.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const Home(),
      routes: [
        GoRoute(path: 'settings', builder: (_, __) => const SettingsPage()),
        GoRoute(
          path: 'references/season:season',
          builder: (context, state) {
            final season = state.pathParameters['season']!;
            var csvData = Provider.of<CSVData>(context);
            final Map<String, Map<String, List<String>>> data = csvData.mapData;
            Map<String, List<String>>? episodesData =
                data[data.keys.elementAt(int.parse(season) - 1)];
            return EpisodesRoute(episodesData!, season.toString());
          },
          routes: [
            GoRoute(
              path: 'episode:episode',
              builder: (context, state) {
                final episode = state.pathParameters['episode']!;
                return ReferencesRoute(
                  state.pathParameters['season']!,
                  episode,
                );
              },
              routes: [
                GoRoute(
                  path: ':idRef/:id',
                  pageBuilder: (context, state) {
                    var csvData = Provider.of<CSVData>(context);
                    final List data = csvData.data;
                    EpisodeUtil.fullEpisode(
                        data, data[int.parse(state.pathParameters['id']!)]);
                    return customBottomSheet(context,
                        referenceId: state.pathParameters['idRef']!);
                  },
                  routes: [
                    GoRoute(
                      path: 'shareimage',
                      builder: (context, state) {
                        return imageRoute(context, state, isShare: true);
                      },
                    ),
                    GoRoute(
                      path: 'wallpaper',
                      builder: (context, state) {
                        return imageRoute(context, state, isShare: false);
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: ':id',
          pageBuilder: (context, state) {
            var csvData = Provider.of<CSVData>(context);
            final List data = csvData.data;
            EpisodeUtil.fullEpisode(
                data, data[int.parse(state.pathParameters['id']!)]);
            return customBottomSheet(context);
          },
          routes: [
            GoRoute(
              path: 'shareimage',
              builder: (context, state) {
                return imageRoute(context, state, isShare: true);
              },
            ),
            GoRoute(
              path: 'wallpaper',
              builder: (context, state) {
                return imageRoute(context, state, isShare: false);
              },
            )
          ],
        ),
      ],
    ),
  ],
);

Widget imageRoute(context, state, {bool isShare = false}) {
  var csvData = Provider.of<CSVData>(context);
  final List data = csvData.data;
  EpisodeUtil.fullEpisode(data, data[int.parse(state.pathParameters['id']!)]);
  return CreateImagePage(
      episode: EpisodeUtil.full, id: EpisodeUtil.index, isShare: isShare);
}

SheetPage<dynamic> customBottomSheet(BuildContext context,
    {String referenceId = ""}) {
  return SheetPage(
    decorationBuilder: (context, child) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 1080 / MediaQuery.of(context).devicePixelRatio,
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: child),
          ),
        ),
      );
    },
    fit: SheetFit.loose,
    draggable: true,
    barrierDismissible: true,
    child: Material(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.15),
        body: BottomSheetEpisode(
          indexLine: EpisodeUtil.index,
          fullEpisode: EpisodeUtil.full,
          referenceId: referenceId,
        ),
      ),
    ),
  );
}
