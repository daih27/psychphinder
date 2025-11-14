import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/utils/reference_type_detector.dart';
import 'package:psychphinder/utils/responsive.dart';

class ReferenceCard extends StatelessWidget {
  final Reference reference;
  final int index;

  const ReferenceCard({
    super.key,
    required this.reference,
    required this.index,
  });

  Future<int> _getReferencesCount(BuildContext context) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final episodePhrases = await databaseService.getEpisodePhrases(
        reference.season, reference.episode);

    final phrasesWithReference = episodePhrases
        .where((phrase) =>
            phrase.reference?.split(',').contains(reference.id) ?? false)
        .toList();

    return phrasesWithReference.length;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = reference.reference.split("(").first.trim();
    final subtitleText =
        reference.reference.split("(").last.replaceAll(')', '').trim();
    final hasVideo = reference.link.isNotEmpty;
    final referenceTypeInfo =
        ReferenceTypeDetector.getReferenceTypeInfo(subtitleText);

    return FutureBuilder<int>(
      future: _getReferencesCount(context),
      builder: (context, countSnapshot) {
        final referencesCount = countSnapshot.data ?? 1;

        return Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 16 : 12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 16 : 12),
              onTap: () async {
                final databaseService =
                    Provider.of<DatabaseService>(context, listen: false);
                final goRouter = GoRouter.of(context);

                final episodePhrases = await databaseService.getEpisodePhrases(
                    reference.season, reference.episode);

                final phrasesWithReference = episodePhrases
                    .where((phrase) =>
                        phrase.reference?.split(',').contains(reference.id) ??
                        false)
                    .toList();

                if (!context.mounted) return;

                if (phrasesWithReference.isNotEmpty) {
                  phrasesWithReference.sort((a, b) =>
                      a.sequenceInEpisode.compareTo(b.sequenceInEpisode));
                  final targetPhrase = phrasesWithReference.first;

                  final route =
                      '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}/r${reference.id}';
                  goRouter.push(route);
                }
              },
              child: Padding(
                padding: ResponsiveUtils.getCardPadding(context),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          ResponsiveUtils.isDesktop(context) ? 10 : 8),
                      decoration: BoxDecoration(
                        color:
                            referenceTypeInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        referenceTypeInfo['icon'],
                        color: referenceTypeInfo['color'],
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtils.getHorizontalPadding(context) *
                            0.75),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                  ),
                                  maxLines:
                                      ResponsiveUtils.isLargeScreen(context)
                                          ? 2
                                          : 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveUtils.isDesktop(context)
                                            ? 8
                                            : 6,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color: referenceTypeInfo['color'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  referenceTypeInfo['type'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getSmallFontSize(
                                            context) -
                                        2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  ResponsiveUtils.getVerticalPadding(context) *
                                      0.5),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subtitleText,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize:
                                            ResponsiveUtils.getSmallFontSize(
                                                context),
                                      ),
                                      maxLines:
                                          ResponsiveUtils.isLargeScreen(context)
                                              ? 2
                                              : 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height:
                                            ResponsiveUtils.getVerticalPadding(
                                                    context) *
                                                0.25),
                                    Text(
                                      reference.season == 999
                                          ? reference.name
                                          : "S${reference.season}E${reference.episode} • ${reference.name}",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize:
                                            ResponsiveUtils.getSmallFontSize(
                                                    context) -
                                                1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (hasVideo)
                                Container(
                                  padding: EdgeInsets.all(
                                      ResponsiveUtils.isDesktop(context)
                                          ? 4
                                          : 3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: ResponsiveUtils.isDesktop(context)
                                        ? 14
                                        : 12,
                                  ),
                                ),
                              SizedBox(
                                  width: ResponsiveUtils.getHorizontalPadding(
                                          context) *
                                      0.5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveUtils.isDesktop(context)
                                            ? 10
                                            : 8,
                                    vertical: ResponsiveUtils.isDesktop(context)
                                        ? 6
                                        : 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  referencesCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.getSmallFontSize(
                                        context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
